import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  // Getters for different categories
  List<Note> get activeNotes =>
      _notes.where((n) => !n.isArchived && !n.isDeleted).toList()..sort((a, b) {
        // Pinned first, then by creation time desc
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.createdTime.compareTo(a.createdTime);
      });

  List<Note> get archivedNotes =>
      _notes.where((n) => n.isArchived && !n.isDeleted).toList()..sort((a, b) {
        // Pinned first, then by archived time desc
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return (b.archivedTime ?? b.createdTime).compareTo(
          a.archivedTime ?? a.createdTime,
        );
      });

  List<Note> get trashNotes => _notes.where((n) => n.isDeleted).toList()
    ..sort(
      (a, b) => (b.deletedTime ?? b.createdTime).compareTo(
        a.deletedTime ?? a.createdTime,
      ),
    );

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await DatabaseHelper.instance.readAllNotes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      title: title,
      content: content,
      createdTime: DateTime.now(),
      updatedTime: DateTime.now(),
    );

    final newNote = await DatabaseHelper.instance.create(note);
    _notes.add(newNote);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedTime: DateTime.now());
    await DatabaseHelper.instance.update(updatedNote);

    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  Future<void> moveToArchive(Note note) async {
    final updatedNote = note.copyWith(
      isArchived: true,
      isDeleted: false,
      archivedTime: DateTime.now(),
    );
    await updateNote(updatedNote);
  }

  Future<void> unarchive(Note note) async {
    final updatedNote = note.copyWith(isArchived: false, archivedTime: null);
    await updateNote(updatedNote);
  }

  Future<void> moveToTrash(Note note) async {
    final updatedNote = note.copyWith(
      isDeleted: true,
      deletedTime: DateTime.now(),
    );
    await updateNote(updatedNote);
  }

  Future<void> restoreFromTrash(Note note) async {
    final updatedNote = note.copyWith(isDeleted: false, deletedTime: null);
    await updateNote(updatedNote);
  }

  Future<void> deletePermanently(int id) async {
    await DatabaseHelper.instance.delete(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await DatabaseHelper.instance.deleteAll();
    _notes.clear();
    notifyListeners();
  }

  Future<int> importNotes(List<Note> notes) async {
    int count = 0;
    for (var note in notes) {
      // Reset ID to allow auto-increment and avoid conflicts
      final noteToInsert = note.copyWith(id: null);
      await DatabaseHelper.instance.create(noteToInsert);
      count++;
    }
    await loadNotes();
    return count;
  }

  // Helper to group notes by date
  Map<String, List<Note>> groupNotesByDate(
    List<Note> notesList, {
    bool useArchivedTime = false,
    bool useDeletedTime = false,
  }) {
    Map<String, List<Note>> grouped = {};

    for (var note in notesList) {
      DateTime dateToUse = note.createdTime;
      if (useArchivedTime && note.archivedTime != null) {
        dateToUse = note.archivedTime!;
      } else if (useDeletedTime && note.deletedTime != null) {
        dateToUse = note.deletedTime!;
      }

      String dateKey = DateFormat('yyyy-MM-dd').format(dateToUse);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(note);
      } else {
        grouped[dateKey] = [note];
      }
    }
    return grouped;
  }
}

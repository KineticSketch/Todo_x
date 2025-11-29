import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'archive_screen.dart';
import 'trash_screen.dart';
import 'edit_note_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('总览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArchiveScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.recycling_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrashScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeNotes = provider.activeNotes;
          if (activeNotes.isEmpty) {
            return const Center(child: Text('暂无记事'));
          }

          // Separate pinned and unpinned notes
          final pinnedNotes = activeNotes.where((n) => n.isPinned).toList();
          final unpinnedNotes = activeNotes.where((n) => !n.isPinned).toList();

          return ListView(
            children: [
              // Pinned section
              if (pinnedNotes.isNotEmpty) ...[
                _buildSectionCard(
                  context,
                  '置顶',
                  pinnedNotes,
                  provider,
                  isPinned: true,
                ),
                const SizedBox(height: 8),
              ],
              // Regular notes grouped by date
              ..._buildDateGroupedNotes(context, unpinnedNotes, provider),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDateGroupedNotes(
    BuildContext context,
    List<Note> notes,
    NoteProvider provider,
  ) {
    if (notes.isEmpty) return [];

    final groupedNotes = provider.groupNotesByDate(notes);
    final sortedDates = groupedNotes.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return sortedDates.map((date) {
      final dateNotes = groupedNotes[date]!;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildSectionCard(context, date, dateNotes, provider),
      );
    }).toList();
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Note> notes,
    NoteProvider provider, {
    bool isPinned = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                if (isPinned)
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (isPinned) const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) =>
                _buildNoteItem(context, notes[index], provider),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    Note note,
    NoteProvider provider,
  ) {
    return Slidable(
      key: ValueKey(note.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _confirmDelete(context, note, provider),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
          SlidableAction(
            onPressed: (context) => _confirmArchive(context, note, provider),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: '归档',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (context) => provider.togglePin(note),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.isPinned ? '取消置顶' : '置顶',
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showNoteDetail(context, note),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorForNote(note),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: note.content.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 20.0),
                child: Text(
                  note.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Note note, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要将此记事移至回收站吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.moveToTrash(note);
              Navigator.pop(dialogContext);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _confirmArchive(BuildContext context, Note note, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认归档'),
        content: const Text('确定要归档此记事吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.moveToArchive(note);
              Navigator.pop(dialogContext);
            },
            child: const Text('归档'),
          ),
        ],
      ),
    );
  }

  void _showNoteDetail(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(note.createdTime),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(note.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
            },
            child: const Text('编辑'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Color _getColorForNote(Note note) {
    // Generate color based on note ID for consistency
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[(note.id ?? 0) % colors.length];
  }
}

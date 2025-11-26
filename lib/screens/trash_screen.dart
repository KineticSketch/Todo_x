import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
        actions: [
          Consumer<NoteProvider>(
            builder: (context, provider, child) {
              if (provider.trashNotes.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClearAll(context, provider),
                tooltip: '清空回收站',
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final trashNotes = provider.trashNotes;
          if (trashNotes.isEmpty) {
            return const Center(child: Text('回收站为空'));
          }

          return ListView(
            children: _buildDateGroupedNotes(context, trashNotes, provider),
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

    final groupedNotes = provider.groupNotesByDate(notes, useDeletedTime: true);
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
    NoteProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
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
            icon: Icons.delete_forever,
            label: '彻底删除',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => provider.restoreFromTrash(note),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.restore_from_trash,
            label: '还原',
          ),
        ],
      ),
      child: ListTile(
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
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.bold,
                ),
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
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ),
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
        content: const Text('此操作无法撤销，确定要彻底删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePermanently(note.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空回收站'),
        content: const Text('此操作将永久删除回收站中的所有记事，且无法撤销。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final trashNotes = provider.trashNotes;
              for (var note in trashNotes) {
                await provider.deletePermanently(note.id!);
              }
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('回收站已清空')));
            },
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getColorForNote(Note note) {
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/note_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSectionHeader(context, '外观'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = themeProvider.themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text('深色模式'),
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, '数据'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('导出为JSON文件'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            title: const Text('清除数据', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmClearData(context),
          ),
          const Divider(),
          _buildSectionHeader(context, '关于'),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('关于作者'),
            subtitle: Text('KineticSketch'),
            onTap: () {
              openUrl('https://github.com/KineticSketch/Todo_x');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final notes = provider.notes;
      final jsonString = jsonEncode(notes.map((n) => n.toMap()).toList());

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'todo_x_backup_$timestamp.json';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Todo_x Backup');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
    }
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作将永久删除所有记事，且无法恢复。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false).clearAllData();
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('所有数据已清除')));
            },
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

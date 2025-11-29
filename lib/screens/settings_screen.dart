import 'dart:convert';
import 'dart:io';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../utils/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/data_transfer_helper.dart';
import 'qr_display_screen.dart';
import 'qr_scanner_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('导出为JSON文件'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.clear_all_outlined, color: Colors.red),
            title: const Text('清除数据', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmClearData(context),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('导入数据'),
            subtitle: const Text('从JSON文件导入'),
            onTap: () => _importFromJson(context),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_2_outlined),
            title: const Text('二维码分享数据'),
            onTap: () => _shareViaQr(context),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner_outlined),
            title: const Text('二维码导入数据'),
            onTap: () => _importViaQr(context),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('分享数据'),
            subtitle: const Text('分享JSON文件到微信等'),
            onTap: () => _shareData(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('关于作者'),
            subtitle: const Text('KineticSketch'),
            onTap: () {
              openUrl('https://github.com/KineticSketch/Todo_x');
            },
          ),
        ],
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
      toastification.show(
        context: context,
        title: Text('导出失败: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );
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
              toastification.show(
                context: context,
                title: const Text('所有数据已清除'),
                autoCloseDuration: const Duration(seconds: 3),
                type: ToastificationType.success,
                style: ToastificationStyle.flat,
              );
            },
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromJson(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final notesData = DataTransferHelper.importFromJson(jsonString);

        if (!context.mounted) return;
        final provider = Provider.of<NoteProvider>(context, listen: false);

        final notes = notesData.map((map) => Note.fromMap(map)).toList();
        final count = await provider.importNotes(notes);

        if (!context.mounted) return;
        toastification.show(
          context: context,
          title: Text('成功导入 $count 条记事'),
          autoCloseDuration: const Duration(seconds: 3),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      toastification.show(
        context: context,
        title: Text('导入失败: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );
    }
  }

  Future<void> _shareViaQr(BuildContext context) async {
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final notes = provider.notes;
      if (notes.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('没有可分享的数据'),
          autoCloseDuration: const Duration(seconds: 3),
          type: ToastificationType.info,
          style: ToastificationStyle.flat,
        );
        return;
      }

      final jsonString = jsonEncode(notes.map((n) => n.toMap()).toList());
      final qrData = DataTransferHelper.generateQrData(jsonString);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QrDisplayScreen(data: qrData)),
      );
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('生成二维码失败: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );
    }
  }

  Future<void> _importViaQr(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!context.mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
      );

      if (result != null && result is String) {
        try {
          final jsonString = DataTransferHelper.parseQrData(result);
          final notesData = DataTransferHelper.importFromJson(jsonString);

          if (!context.mounted) return;
          final provider = Provider.of<NoteProvider>(context, listen: false);
          final notes = notesData.map((map) => Note.fromMap(map)).toList();
          final count = await provider.importNotes(notes);

          if (!context.mounted) return;
          toastification.show(
            context: context,
            title: Text('成功导入 $count 条记事'),
            autoCloseDuration: const Duration(seconds: 3),
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
          );
        } catch (e) {
          if (!context.mounted) return;
          toastification.show(
            context: context,
            title: const Text('无效的二维码数据'),
            autoCloseDuration: const Duration(seconds: 3),
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
          );
        }
      }
    } else {
      if (!context.mounted) return;
      toastification.show(
        context: context,
        title: const Text('需要相机权限以扫描二维码'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
      );
    }
  }

  Future<void> _shareData(BuildContext context) async {
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final notes = provider.notes;

      if (notes.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('没有可分享的数据'),
          autoCloseDuration: const Duration(seconds: 3),
          type: ToastificationType.info,
          style: ToastificationStyle.flat,
        );
        return;
      }

      final jsonString = jsonEncode(notes.map((n) => n.toMap()).toList());
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'todo_x_backup_$timestamp.json';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Todo_x 数据备份 - ${notes.length} 条记事');
    } catch (e) {
      if (!context.mounted) return;
      toastification.show(
        context: context,
        title: Text('分享失败: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );
    }
  }
}

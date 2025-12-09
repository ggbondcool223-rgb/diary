import 'dart:io';
import 'package:diary/db_diary/diary_entity.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ExportUtils {
  static Future<String> exportToMarkdown(List<dynamic> diaries) async {
    final buffer = StringBuffer();
    buffer.writeln('# Diary Export\n');
    buffer.writeln('Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n');
    buffer.writeln('---\n');

    for (var diary in diaries) {
      if (diary is DiaryEntity) {
        buffer.writeln('## ${diary.title}');
        buffer.writeln('**Date:** ${diary.ymdStr}\n');
        buffer.writeln(diary.content);
        buffer.writeln('\n---\n');
      }
    }

    return buffer.toString();
  }

  static Future<String> exportToTxt(List<dynamic> diaries) async {
    final buffer = StringBuffer();
    buffer.writeln('Diary Export');
    buffer.writeln('Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    for (var diary in diaries) {
      if (diary is DiaryEntity) {
        buffer.writeln('Title: ${diary.title}');
        buffer.writeln('Date: ${diary.ymdStr}');
        buffer.writeln('-' * 50);
        buffer.writeln(diary.content);
        buffer.writeln('');
        buffer.writeln('=' * 50);
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  static Future<File?> saveToFile(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return file;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  static Future<String> getExportPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }
}


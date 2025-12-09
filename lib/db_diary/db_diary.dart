import 'dart:convert';

import 'package:diary/db_diary/diary_entity.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBDiary extends GetxService {
  late Database dbBase;

  Future<DBDiary> init() async {
    await createDiaryDB();
    return this;
  }

  createDiaryDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'diary.db');

    dbBase = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await createDiaryTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE diary ADD COLUMN isPinned INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE diary ADD COLUMN isStarred INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE diary ADD COLUMN tags TEXT');
      }
    });
  }

  createDiaryTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS diary (id INTEGER PRIMARY KEY, createdTime TEXT, type INTEGER, title TEXT, content TEXT, list TEXT, isPinned INTEGER DEFAULT 0, isStarred INTEGER DEFAULT 0, tags TEXT)');
  }

  insertDiary(DiaryEntity entity) async {
    final id = await dbBase.insert('diary', {
      'createdTime': entity.createdTime.toIso8601String(),
      'type': entity.type,
      'title': entity.title,
      'content': entity.content,
      'list': jsonEncode(entity.list.map((e) => e.toMap()).toList()),
      'isPinned': entity.isPinned ? 1 : 0,
      'isStarred': entity.isStarred ? 1 : 0,
      'tags': entity.tags ?? '',
    });
    return id;
  }

  deleteDiary(int id) async {
    await dbBase.delete('diary', where: 'id = ?', whereArgs: [id]);
  }

  cleanDiaryData() async {
    await dbBase.delete('diary');
  }

  List<List<DiaryEntity>> groupNotesByYearMonthDay(List<DiaryEntity> list) {
    Map<String, List<DiaryEntity>> groupedMap = {};
    for (var diary in list) {
      String yearMonthKey =
          '${diary.createdTime.year}-${diary.createdTime.month.toString().padLeft(2, '0')}-${diary.createdTime.day.toString().padLeft(2, '0')}';
      if (!groupedMap.containsKey(yearMonthKey)) {
        groupedMap[yearMonthKey] = [];
      }
      groupedMap[yearMonthKey]!.add(diary);
    }
    return groupedMap.values.toList();
  }

  Future<List<List<DiaryEntity>>> getDiaryAllData({bool isDiary = true}) async {
    var result = await dbBase.query('diary', orderBy: 'createdTime DESC');
    var list = result.map((e) => DiaryEntity.fromJson(e)).toList();
    list = list.where((element) => element.type == (isDiary ? 0 : 1)).toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      if (a.isStarred != b.isStarred) return a.isStarred ? -1 : 1;
      return b.createdTime.compareTo(a.createdTime);
    });
    return groupNotesByYearMonthDay(list);
  }

  Future<void> updatePinnedStatus(int id, bool isPinned) async {
    await dbBase.update('diary', {'isPinned': isPinned ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStarredStatus(int id, bool isStarred) async {
    await dbBase.update('diary', {'isStarred': isStarred ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DiaryEntity>> searchDiary(String keyword, {bool isDiary = true}) async {
    var result = await dbBase.query(
      'diary',
      where: 'type = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [isDiary ? 0 : 1, '%$keyword%', '%$keyword%'],
      orderBy: 'createdTime DESC',
    );
    return result.map((e) => DiaryEntity.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getStatistics({bool isDiary = true}) async {
    var result = await dbBase.query(
      'diary',
      where: 'type = ?',
      whereArgs: [isDiary ? 0 : 1],
    );
    var list = result.map((e) => DiaryEntity.fromJson(e)).toList();
    
    int totalCount = list.length;
    int totalWords = list.fold(0, (sum, item) => sum + item.content.length);
    double avgWords = totalCount > 0 ? totalWords / totalCount : 0;

    Map<String, int> monthlyCount = {};
    for (var item in list) {
      String monthKey = '${item.createdTime.year}-${item.createdTime.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }

    String? mostActiveMonth = monthlyCount.entries.isEmpty
        ? null
        : monthlyCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return {
      'totalCount': totalCount,
      'totalWords': totalWords,
      'avgWords': avgWords.round(),
      'monthlyCount': monthlyCount,
      'mostActiveMonth': mostActiveMonth,
    };
  }
}

import 'dart:convert';

import 'package:intl/intl.dart';

import '../pages/diary_first/diary_edit/diary_edit_logic.dart';

class DiaryEntity {
  int id;
  DateTime createdTime;
  int type;
  String title;
  String content;
  List<StyledTextSegment> list;
  bool isPinned;
  bool isStarred;
  String? tags;

  DiaryEntity({
    required this.id,
    required this.createdTime,
    required this.type,
    required this.title,
    required this.content,
    required this.list,
    this.isPinned = false,
    this.isStarred = false,
    this.tags,
  });

  factory DiaryEntity.fromJson(Map<String, dynamic> json) {
    return DiaryEntity(
      id: json['id'],
      createdTime: DateTime.parse(json['createdTime']),
      type: json['type'],
      title: json['title'],
      content: json['content'],
      list: (jsonDecode(json['list']) as List)
          .map((e) => StyledTextSegment.fromMap(e))
          .toList(),
      isPinned: json['isPinned'] == 1 || json['isPinned'] == true,
      isStarred: json['isStarred'] == 1 || json['isStarred'] == true,
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTime': createdTime.toIso8601String(),
      'type': type,
      'title': title,
      'content': content,
      'list': jsonEncode(list.map((e) => e.toMap()).toList()),
      'isPinned': isPinned ? 1 : 0,
      'isStarred': isStarred ? 1 : 0,
      'tags': tags ?? '',
    };
  }

  String get ymdStr => DateFormat('MM/dd/yyyy').format(createdTime);

  String get mdStr {
    final now = DateTime.now();
    if (now.year == createdTime.year) {
      return DateFormat('MM.dd').format(createdTime);
    } else {
      return DateFormat('MM.dd.yyyy').format(createdTime);
    }
  }

  String get weekStr => DateFormat('EEEE').format(createdTime);
}
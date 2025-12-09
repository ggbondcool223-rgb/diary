import 'package:diary/db_diary/db_diary.dart';
import 'package:diary/db_diary/diary_entity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum TextStyleType {
  title('Title', FontWeight.bold, 20.0, Colors.black),
  subtitle('Subtitle', FontWeight.bold, 16.0, Colors.black),
  smallTitle('SmallTitle', FontWeight.bold, 14.0, Colors.black),
  body('Body', FontWeight.normal, 14.0, Colors.black),
  note('Note', FontWeight.normal, 14.0, Colors.black);

  final String displayName;
  final FontWeight fontWeight;
  final double fontSize;
  final Color color;

  const TextStyleType(
      this.displayName,
      this.fontWeight,
      this.fontSize,
      this.color,
      );
}

class StyledTextSegment {
  String text;
  TextStyleType style;
  int start;
  int end;

  StyledTextSegment({
    required this.text,
    required this.style,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'style': style.index,
      'start': start,
      'end': end,
    };
  }

  static StyledTextSegment fromMap(Map<String, dynamic> map) {
    return StyledTextSegment(
      text: map['text'],
      style: TextStyleType.values[map['style']],
      start: map['start'],
      end: map['end'],
    );
  }

  @override
  String toString() {
    return 'StyledTextSegment{text: $text, style: $style, start: $start, end: $end}';
  }
}

class DiaryEditLogic extends GetxController {

  DBDiary dbDiary = Get.find();


  addData(String title, String content, List<StyledTextSegment> list, String tags) async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (list.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter some text');
      return;
    }
    if (title.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a title');
      return;
    }
    await dbDiary.insertDiary(DiaryEntity(
      id: 0,
      createdTime: DateTime.now(),
      type: 0,
      title: title,
      content: content,
      list: list,
      isPinned: false,
      isStarred: false,
      tags: tags.isEmpty ? null : tags,
    ));
    Fluttertoast.showToast(msg: 'Add success');
    Get.back();
  }

}

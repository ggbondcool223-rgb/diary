import 'package:diary/db_diary/db_diary.dart';
import 'package:diary/db_diary/diary_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../diary_edit/diary_edit_logic.dart';

class DiaryPreviewLogic extends GetxController {

  DBDiary dbDiary = Get.find();

  DiaryEntity entity = Get.arguments;

  List<StyledTextSegment> textSegments = [];

  TextStyle _getTextStyle(TextStyleType type) {
    return TextStyle(
      fontSize: type.fontSize,
      fontWeight: type.fontWeight,
      color: type.color,
      height: 1.5,
    );
  }

  Widget buildRichTextWithCursor() {
    final List<InlineSpan> children = [];
    for (final segment in textSegments) {
      children.add(TextSpan(
        text: segment.text,
        style: _getTextStyle(segment.style),
      ));
    }

    return RichText(text: TextSpan(children: children));
  }

  void deleteDiary() async {
    await dbDiary.deleteDiary(entity.id);
    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    textSegments = entity.list;
    buildRichTextWithCursor();
    update();
    super.onInit();
  }

}

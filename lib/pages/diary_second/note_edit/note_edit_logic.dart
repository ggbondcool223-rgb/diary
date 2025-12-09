import 'package:diary/db_diary/db_diary.dart';
import 'package:diary/db_diary/diary_entity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class NoteEditLogic extends GetxController {

  DBDiary dbDiary = Get.find();

  DiaryEntity? diaryEntity = Get.arguments;

  String content = '';

  addData() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter some text');
      return;
    }
    await dbDiary.insertDiary(DiaryEntity(
      id: 0,
      createdTime: DateTime.now(),
      type: 1,
      title: '',
      content: content,
      list: [],
      isPinned: false,
      isStarred: false,
    ));
    Fluttertoast.showToast(msg: 'Add success');
    Get.back();
  }

  void deleteDiary() async {
    await dbDiary.deleteDiary(diaryEntity!.id);
    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    if (diaryEntity != null) {
      content = diaryEntity!.content;
    }
    update();
    super.onInit();
  }

}

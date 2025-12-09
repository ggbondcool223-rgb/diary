import 'dart:io';
import 'package:diary/db_diary/db_diary.dart';
import 'package:diary/pages/diary_third/statistics/statistics_binding.dart';
import 'package:diary/pages/diary_third/statistics/statistics_view.dart';
import 'package:diary/utils/export_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class DiaryThirdLogic extends GetxController {

  DBDiary dbDiary = Get.find();

  var appVersion = '1.0.0'.obs;

  void navigateToStatistics() {
    Get.to(() => StatisticsPage(), binding: StatisticsBinding());
  }

  Future<void> exportData() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var allDiaries = await dbDiary.getDiaryAllData(isDiary: true);
      var allNotes = await dbDiary.getDiaryAllData(isDiary: false);
      
      List<dynamic> allItems = [];
      for (var group in allDiaries) {
        allItems.addAll(group);
      }
      for (var group in allNotes) {
        allItems.addAll(group);
      }

      if (allItems.isEmpty) {
        Get.back();
        Fluttertoast.showToast(msg: 'No data to export');
        return;
      }

      String markdown = await ExportUtils.exportToMarkdown(allItems);
      
      String filename = 'diary_export_${DateTime.now().millisecondsSinceEpoch}.md';
      File? file = await ExportUtils.saveToFile(markdown, filename);

      Get.back();

      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Diary Export',
        );
        Fluttertoast.showToast(msg: 'Export successful');
      } else {
        Fluttertoast.showToast(msg: 'Export failed');
      }
    } catch (e) {
      Get.back();
      Fluttertoast.showToast(msg: 'Export error: $e');
    }
  }

  cleanDiaryData() async {
    Get.dialog(AlertDialog(
      title: const Text('Warm reminder'),
      content: const Text('Do you want to clean all records?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            await dbDiary.cleanDiaryData();
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ));
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    var info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    super.onInit();
  }

}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'diary_preview_logic.dart';

class DiaryPreviewPage extends GetView<DiaryPreviewLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Diary preview'),
        actions: [
          const Text(
            'Delete',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ).marginOnly(right: 20).gestures(onTap: () {
            controller.deleteDiary();
          })
        ],
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: GetBuilder<DiaryPreviewLogic>(builder: (_) {
            return SafeArea(
              child: <Widget>[
                Text(
                  controller.entity.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  controller.entity.ymdStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Expanded(child: controller.buildRichTextWithCursor())
              ]
                  .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                  .marginAll(15),
            );
          }))
          .decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg1.png'), fit: BoxFit.fill)),
    );
  }
}

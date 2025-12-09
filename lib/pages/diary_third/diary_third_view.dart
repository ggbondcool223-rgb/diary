import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'diary_third_logic.dart';

class DiaryThirdPage extends GetView<DiaryThirdLogic> {
  Widget _item(int index) {
    final titles = ['Statistics', 'Export Data', 'Clean all data', 'App version'];
    return Container(
      width: double.infinity,
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: <Widget>[
        Expanded(
            child: Text(
          titles[index],
        )),
        if (index == 0 || index == 1 || index == 2)
          const Icon(
            Icons.keyboard_arrow_right,
            color: Colors.grey,
            size: 25,
          )
        else
          Obx(() {
            return Text(
              controller.appVersion.value,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            );
          })
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
    )
        .decorated(
            color: Colors.white,
            border: Border.all(color: const Color(0xffeaeaea)),
            borderRadius: BorderRadius.circular(10))
        .marginOnly(bottom: 10)
        .gestures(onTap: () {
      if (index == 0) {
        controller.navigateToStatistics();
      } else if (index == 1) {
        controller.exportData();
      } else if (index == 2) {
        controller.cleanDiaryData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: <Widget>[_item(0), _item(1), _item(2), _item(3)].toColumn(),
        ).marginAll(15)),
      ).decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg0.png'), fit: BoxFit.fill)),
    );
  }
}

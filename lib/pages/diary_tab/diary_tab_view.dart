import 'package:diary/pages/diary_first/diary_first_logic.dart';
import 'package:diary/pages/diary_first/diary_first_view.dart';
import 'package:diary/pages/diary_second/diary_second_view.dart';
import 'package:diary/pages/diary_third/diary_third_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../diary_second/diary_second_logic.dart';
import 'diary_tab_logic.dart';

class DiaryTabPage extends GetView<DiaryTabLogic> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children: [
          DiaryFirstPage(),
          DiarySecondPage(),
          DiaryThirdPage()
        ],
      ),
      bottomNavigationBar: Obx(()=>_navDiaryBars()),
    );
  }

  Widget _navDiaryBars() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/item0Grey.png',width: 22,height: 22,),
          activeIcon:Image.asset('assets/item0Light.png',width: 22,height: 22,),
          label: 'Diary',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/item1Grey.png',width: 22,height: 22,),
          activeIcon:Image.asset('assets/item1Light.png',width: 22,height: 22,),
          label: 'Note',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/item2Grey.png',width: 22,height: 22,),
          activeIcon:Image.asset('assets/item2Light.png',width: 22,height: 22,),
          label: 'Setting',
        ),
      ],
      currentIndex: controller.currentIndex.value,
      onTap: (index) {
        controller.currentIndex.value = index;
        controller.pageController.jumpToPage(index);
        if (index == 0) {
          DiaryFirstLogic firstLogic = Get.find<DiaryFirstLogic>();
          firstLogic.getData();
        } else if (index == 1) {
          DiarySecondLogic secondLogic = Get.find<DiarySecondLogic>();
          secondLogic.getData();
        }
      },
    );
  }
}

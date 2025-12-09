
import 'package:diary/db_diary/db_diary.dart';
import 'package:diary/pages/diary_first/diary_edit/diary_edit_binding.dart';
import 'package:diary/pages/diary_first/diary_edit/diary_edit_view.dart';
import 'package:diary/pages/diary_first/diary_first_binding.dart';
import 'package:diary/pages/diary_first/diary_first_view.dart';
import 'package:diary/pages/diary_first/diary_preview/diary_preview_binding.dart';
import 'package:diary/pages/diary_first/diary_preview/diary_preview_view.dart';
import 'package:diary/pages/diary_second/diary_second_binding.dart';
import 'package:diary/pages/diary_second/diary_second_view.dart';
import 'package:diary/pages/diary_second/note_edit/note_edit_binding.dart';
import 'package:diary/pages/diary_second/note_edit/note_edit_view.dart';
import 'package:diary/pages/diary_tab/diary_tab_binding.dart';
import 'package:diary/pages/diary_tab/diary_tab_view.dart';
import 'package:diary/pages/diary_third/diary_third_binding.dart';
import 'package:diary/pages/diary_third/diary_third_view.dart';
import 'package:diary/pages/diary_third/statistics/statistics_table.dart';
import 'package:diary/pages/diary_trans/diary_trans_binding.dart';
import 'package:diary/pages/diary_trans/diary_trans_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Color primaryColor = Colors.black;
Color bgColor = const Color(0xfff5f5f5);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => DBDiary().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: Niou,
      initialRoute: '/',
      theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: bgColor,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primaryColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          )
      ),
    );
  }
}
List<GetPage<dynamic>> Niou = [
  GetPage(name: '/', page: () => DiaryTransView(), binding: DiaryTransBinding()),
  GetPage(name: '/diaryTab', page: () => DiaryTabPage(), binding: DiaryTabBinding()),
  GetPage(name: '/diaryFirst', page: () => DiaryFirstPage(), binding: DiaryFirstBinding()),
  GetPage(name: '/diarySecond', page: () => DiarySecondPage(), binding:DiarySecondBinding()),
  GetPage(name: '/diaryThird', page: () => DiaryThirdPage(), binding:DiaryThirdBinding()),
  GetPage(name: '/diaryEdit', page: () => DiaryEditPage(), binding:DiaryEditBinding()),
  GetPage(name: '/diaryPreview', page: () => DiaryPreviewPage(), binding:DiaryPreviewBinding()),
  GetPage(name: '/noteEdit', page: () => NoteEditPage(), binding:NoteEditBinding()),
  GetPage(name: '/diaryStatistics', page: () => StatisticsTable()),
];
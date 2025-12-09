import 'package:diary/db_diary/diary_entity.dart';
import 'package:diary/pages/diary_first/first_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'diary_first_logic.dart';

class DiaryFirstPage extends GetView<DiaryFirstLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Obx(() => controller.isSearching.value
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search diary...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.onSearchChanged(value);
                },
              )
            : const Text('Diary')),
        actions: [
          Obx(() => controller.isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.toggleSearch();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.toggleSearch();
                  },
                )),
          Image.asset('assets/icon0.png').marginOnly(right: 20).gestures(
              onTap: () {
            Get.toNamed('/diaryEdit')?.then((_) {
              controller.getData();
            });
          })
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(child: Obx(() {
          return controller.list.isEmpty
              ? const Center(
                  child: Text('No data'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: controller.list.length,
                  itemBuilder: (_, index) {
                    List<DiaryEntity> entities = controller.list[index];
                    return <Widget>[
                      Text(
                        entities.first.mdStr,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationThickness: 2,
                            decorationColor: Color(0xffffe200)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FirstItem(
                        entities,
                        onTap: (v) {
                          Get.toNamed('/diaryPreview',
                                  arguments: entities[v])
                              ?.then((value) {
                            controller.getData();
                          });
                        },
                      )
                    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
                  });
        })),
      ).decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg0.png'), fit: BoxFit.fill)),
    );
  }
}

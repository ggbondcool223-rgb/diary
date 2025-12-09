import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../db_diary/diary_entity.dart';
import 'diary_second_logic.dart';

class DiarySecondPage extends GetView<DiarySecondLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Obx(() => controller.isSearching.value
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.onSearchChanged(value);
                },
              )
            : const Text('Note')),
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
            Get.toNamed('/noteEdit')?.then((_) {
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
                    return SizedBox(
                      width: double.infinity,
                      height: 142,
                      child: <Widget>[
                        <Widget>[
                          <Widget>[
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
                            Text(
                              entities.first.weekStr,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ].toColumn(
                              crossAxisAlignment: CrossAxisAlignment.start)
                        ].toColumn(mainAxisSize: MainAxisSize.min),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: SizedBox(
                          height: 142,
                          child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 158 / 142),
                              itemCount: entities.length,
                              itemBuilder: (_, idx) {
                                DiaryEntity entity = entities[idx];
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed('/noteEdit', arguments: entity)?.then((_) {
                                      controller.getData();
                                    });
                                  },
                                  onLongPress: () {
                                    Get.bottomSheet(
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                entity.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                                color: entity.isPinned ? Colors.orange : Colors.grey,
                                              ),
                                              title: Text(entity.isPinned ? 'Cancel pinned' : 'Pinned'),
                                              onTap: () {
                                                controller.togglePinned(entity);
                                                Get.back();
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                entity.isStarred ? Icons.star : Icons.star_border,
                                                color: entity.isStarred ? Colors.amber : Colors.grey,
                                              ),
                                              title: Text(entity.isStarred ? 'Cancel starred' : 'Starred'),
                                              onTap: () {
                                                controller.toggleStarred(entity);
                                                Get.back();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset('assets/icon2.png'),
                                      SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: Text(
                                          entity.content,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 5,
                                        ),
                                      ).marginOnly(top: 40),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (entity.isPinned)
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.push_pin,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            if (entity.isStarred) ...[
                                              if (entity.isPinned) const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ))
                      ].toRow(crossAxisAlignment: CrossAxisAlignment.start),
                    ).marginOnly(bottom: 10);
                  });
        })),
      ).decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg0.png'), fit: BoxFit.fill)),
    );
  }
}

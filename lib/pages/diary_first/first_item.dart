import 'package:diary/db_diary/diary_entity.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';

class FirstItem extends StatelessWidget {
  const FirstItem(this.list, {this.onTap, super.key});

  final List<DiaryEntity> list;
  final Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (_, index) {
          final entity = list[index];
          return Container(
            padding: const EdgeInsets.all(12),
            child: <Widget>[
              <Widget>[
                Container(
                  width: 18,
                  height: 18,
                  child: <Widget>[
                    const Icon(
                      Icons.text_snippet_outlined,
                      size: 10,
                      color: Colors.black,
                    )
                  ].toRow(mainAxisAlignment: MainAxisAlignment.center),
                ).decorated(
                    color: const Color(0xffffe200),
                    borderRadius: BorderRadius.circular(9)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(
                  entity.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ))
              ].toRow(),
              Text(
                entity.content,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              <Widget>[
                Expanded(child: Visibility(
                  visible: entity.tags?.isNotEmpty == true,
                  child: Text(
                    entity.tags!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
                Text(
                  entity.ymdStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
          )
              .decorated(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      spreadRadius: 1)
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffe3e3e3)),
              )
              .marginOnly(bottom: 10)
              .gestures(onTap: () {
                onTap?.call(index);
              });
        });
  }
}

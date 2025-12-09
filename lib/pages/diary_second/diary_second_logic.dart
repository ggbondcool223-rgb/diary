import 'package:get/get.dart';

import '../../db_diary/db_diary.dart';
import '../../db_diary/diary_entity.dart';

class DiarySecondLogic extends GetxController {

  DBDiary dbDiary = Get.find();

  var list = [].obs;
  var searchKeyword = ''.obs;
  var isSearching = false.obs;

  getData() async {
    if (searchKeyword.value.isEmpty) {
      list.value = await dbDiary.getDiaryAllData(isDiary: false);
    } else {
      var searchResults = await dbDiary.searchDiary(searchKeyword.value, isDiary: false);
      list.value = dbDiary.groupNotesByYearMonthDay(searchResults);
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchKeyword.value = '';
      getData();
    }
  }

  void onSearchChanged(String keyword) {
    searchKeyword.value = keyword;
    getData();
  }

  Future<void> togglePinned(DiaryEntity entity) async {
    await dbDiary.updatePinnedStatus(entity.id, !entity.isPinned);
    getData();
  }

  Future<void> toggleStarred(DiaryEntity entity) async {
    await dbDiary.updateStarredStatus(entity.id, !entity.isStarred);
    getData();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

}

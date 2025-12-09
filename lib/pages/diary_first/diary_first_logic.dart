import 'package:diary/db_diary/db_diary.dart';
import 'package:get/get.dart';

class DiaryFirstLogic extends GetxController {

  DBDiary dbDiary = Get.find();

  var list = [].obs;
  var searchKeyword = ''.obs;
  var isSearching = false.obs;

  getData() async {
    if (searchKeyword.value.isEmpty) {
      list.value = await dbDiary.getDiaryAllData();
    } else {
      var searchResults = await dbDiary.searchDiary(searchKeyword.value, isDiary: true);
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

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

}

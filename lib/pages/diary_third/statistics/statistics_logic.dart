import 'package:diary/db_diary/db_diary.dart';
import 'package:get/get.dart';

class StatisticsLogic extends GetxController {
  DBDiary dbDiary = Get.find();

  var isLoading = true.obs;
  var diaryStats = <String, dynamic>{}.obs;
  var noteStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      diaryStats.value = await dbDiary.getStatistics(isDiary: true);
      noteStats.value = await dbDiary.getStatistics(isDiary: false);
    } catch (e) {
      print('Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }
}


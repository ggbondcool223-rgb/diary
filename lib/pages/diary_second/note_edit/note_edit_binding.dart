import 'package:get/get.dart';

import 'note_edit_logic.dart';

class NoteEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteEditLogic());
  }
}
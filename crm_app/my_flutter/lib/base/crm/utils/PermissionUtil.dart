import 'dart:async';

import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/constant/Commons.dart';

class PermissionUtil {
  static const permissionChannel =
      const MethodChannel(Commons.permissionChannel);
  static PermissionStatus intToPermissionStatus(int status) {
    switch (status) {
      case 0:
        return PermissionStatus.notDetermined;
      case 1:
        return PermissionStatus.restricted;
      case 2:
        return PermissionStatus.denied;
      case 3:
        return PermissionStatus.authorized;
      case 4:
        return PermissionStatus.deniedNeverAsk;
      default:
        return PermissionStatus.notDetermined;
    }
  }

  static String getPermissionString(Permission permission) {
    String res;
    switch (permission) {
      case Permission.CallPhone:
        res = "CALL_PHONE";
        break;
      case Permission.Camera:
        res = "CAMERA";
        break;
      case Permission.PhotoLibrary:
        res = "PHOTO_LIBRARY";
        break;
      case Permission.RecordAudio:
        res = "RECORD_AUDIO";
        break;
      case Permission.WriteExternalStorage:
        res = "WRITE_EXTERNAL_STORAGE";
        break;
      case Permission.ReadExternalStorage:
        res = "READ_EXTERNAL_STORAGE";
        break;
      case Permission.ReadPhoneState:
        res = "READ_PHONE_STATE";
        break;
      case Permission.AccessFineLocation:
        res = "ACCESS_FINE_LOCATION";
        break;
      case Permission.AccessCoarseLocation:
        res = "ACCESS_COARSE_LOCATION";
        break;
      case Permission.WhenInUseLocation:
        res = "WHEN_IN_USE_LOCATION";
        break;
      case Permission.AlwaysLocation:
        res = "ALWAYS_LOCATION";
        break;
      case Permission.ReadContacts:
        res = "READ_CONTACTS";
        break;
      case Permission.SendSMS:
        res = "SEND_SMS";
        break;
      case Permission.ReadSms:
        res = "READ_SMS";
        break;
      case Permission.Vibrate:
        res = "VIBRATE";
        break;
      case Permission.WriteContacts:
        res = "WRITE_CONTACTS";
        break;
      case Permission.AccessMotionSensor:
        res = "MOTION_SENSOR";
        break;
    }
    return res;
  }

  //Amap 的处理不好,Simple_permission 也有bug，已优化，嘻嘻
  static getPermissionResult(List<Permission> list, Function callback) async {
    bool pass = true;
    List<PermissionStatus> passList =
        List.filled(list.length, PermissionStatus.denied);
    for (int i = 0; i < list.length; i++) {
      Permission permission = list[i];
      passList[i] = await getPermission(permission);
    }
    for (int i = 0; i < passList.length; i++) {
      PermissionStatus status = passList[i];
      if (status != PermissionStatus.authorized) {
        pass = false;
        break;
      }
    }
    if (callback != null) {
      callback(pass);
    }
  }

  static Future<PermissionStatus> getPermission(
    Permission permission,
  ) async {
    PermissionStatus status;
    PermissionStatus permissionStatus = PermissionStatus.denied;
    int result = await permissionChannel.invokeMethod(
        Commons.requestPermissionMethod,
        {"permission": getPermissionString(permission)});
    status = result is int
        ? intToPermissionStatus(result)
        : status is bool
            ? (result == null
                ? PermissionStatus.authorized
                : PermissionStatus.denied)
            : PermissionStatus.notDetermined;
    permissionStatus = status;
    return Future.value(permissionStatus);
  }

  static Future<bool> openSettings() async {
    //Android && IOS 处理
    final bool isOpen =
        await permissionChannel.invokeMethod(Commons.openSettingsMethod);

    return isOpen;
  }

  static Future<bool> openGpsService() async {
    //Android
    final bool isOpen =
    await permissionChannel.invokeMethod(Commons.openGpsServiceMethod);

    return isOpen;
  }

}


/// Enum of all available [Permission]
enum Permission {
  RecordAudio,
  CallPhone,
  Camera,
  PhotoLibrary,
  WriteExternalStorage,
  ReadExternalStorage,
  ReadPhoneState,
  AccessCoarseLocation,
  AccessFineLocation,
  WhenInUseLocation,
  AlwaysLocation,
  ReadContacts,
  ReadSms,
  SendSMS,
  Vibrate,
  WriteContacts,
  AccessMotionSensor
}

/// Permissions status enum (iOs: notDetermined, restricted, denied, authorized, deniedNeverAsk)
/// (Android: denied, authorized, deniedNeverAsk)
enum PermissionStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
  deniedNeverAsk /* android */
}

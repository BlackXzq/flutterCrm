// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppReleaseBean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppReleaseBean _$AppReleaseBeanFromJson(Map<String, dynamic> json) {
  return AppReleaseBean(
      json['id'] as int,
      json['appName'] as String,
      json['type'] as int,
      json['downloadUrl'] as String,
      json['isMustUpdate'] as int,
      json['releaseLog'] as String,
      json['versionCode'] as int,
      json['versionName'] as String,
      json['platformType'] as int);
}

Map<String, dynamic> _$AppReleaseBeanToJson(AppReleaseBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appName': instance.appName,
      'type': instance.type,
      'downloadUrl': instance.downloadUrl,
      'isMustUpdate': instance.isMustUpdate,
      'releaseLog': instance.releaseLog,
      'versionCode': instance.versionCode,
      'versionName': instance.versionName,
      'platformType': instance.platformType
    };

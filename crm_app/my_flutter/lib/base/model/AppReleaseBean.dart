import 'package:json_annotation/json_annotation.dart';

part 'AppReleaseBean.g.dart';

@JsonSerializable()
class AppReleaseBean {
  int id;
  String appName;
  int type;
  String downloadUrl; //iOS   App Store  链接地址
  int isMustUpdate; //iOS   是否强制更新
  String releaseLog; //'=='分割  //iOS 更新信息
  int versionCode;
  String versionName; //iOS 版本号
  int platformType; //1,android,2 iOS

  AppReleaseBean(
      this.id,
      this.appName,
      this.type,
      this.downloadUrl,
      this.isMustUpdate,
      this.releaseLog,
      this.versionCode,
      this.versionName,
      this.platformType);

  factory AppReleaseBean.fromJson(Map<String, dynamic> json) =>
      _$AppReleaseBeanFromJson(json);

  @override
  String toString() {
    return 'AppReleaseBean{id: $id, appName: $appName, type: $type, downloadUrl: $downloadUrl, isMustUpdate: $isMustUpdate, releaseLog: $releaseLog, versionCode: $versionCode, versionName: $versionName, platformType: $platformType}';
  }
}

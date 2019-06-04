// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginRespDto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRespDto _$LoginRespDtoFromJson(Map<String, dynamic> json) {
  return LoginRespDto(json['loginName'] as String, json['code'] as String,
      json['token'] as String);
}

Map<String, dynamic> _$LoginRespDtoToJson(LoginRespDto instance) =>
    <String, dynamic>{
      'loginName': instance.loginName,
      'code': instance.code,
      'token': instance.token
    };

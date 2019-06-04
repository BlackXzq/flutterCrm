import 'package:json_annotation/json_annotation.dart';

part 'LoginRespDto.g.dart';

@JsonSerializable()
class LoginRespDto {
  String loginName;
  String code;
  String token;

  LoginRespDto(this.loginName, this.code, this.token);

  factory LoginRespDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRespDtoFromJson(json);

  @override
  String toString() {
    return 'LoginRespDto{loginName: $loginName, code: $code, token: $token}';
  }
}

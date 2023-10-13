// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) => Login(
      json['auth'] == null
          ? null
          : Auth.fromJson(json['auth'] as Map<String, dynamic>),
    );

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth(
      json['token'] as String,
    );

Map<String, dynamic> _$LoginInfoToJson(LoginInfo instance) => <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'source': instance.source,
    };

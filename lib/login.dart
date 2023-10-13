import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';

@JsonSerializable(createToJson: false)
class Login {
  final Auth? auth;

  Login(this.auth);

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
}

@JsonSerializable(createToJson: false)
class Auth {
  final String token;

  Auth(this.token);

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
}

@JsonSerializable(createFactory: false)
class LoginInfo {
  final String email;
  final String password;
  final String source = "web";

  LoginInfo({required this.email, required this.password});

  toJson() => _$LoginInfoToJson(this);
}

Future<String?> getAuthCode(LoginInfo loginInfo) async {
  final response = await http.post(
      Uri.parse('https://app.rocketlanguages.com/api/v2/login'),
      body: loginInfo.toJson(),
      headers: {"Accept": "application/json"});

  return Login.fromJson(json.decode(response.body)).auth?.token;
}

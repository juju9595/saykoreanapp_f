// lib/api/gameApi.dart


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameApi {
  // .env에서 BASE_URL 읽기
  static String get baseURL => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';


}
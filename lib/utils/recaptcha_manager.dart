
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';

class RecaptchaManager {
  static RecaptchaClient? _client;

  // 앱 시작 시 한 번만 초기화
  static Future<void> initialize(RecaptchaClient client) async{
    _client = client;
    }
  static RecaptchaClient get client {
    if (_client == null ){
      throw Exception('RecaptchaClient가 초기화되지 않았습니다.');
    }
    return _client!;
  }
}


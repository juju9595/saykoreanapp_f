
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saykoreanapp_f/pages/auth/find_page.dart';
import 'package:saykoreanapp_f/pages/auth/signup_page.dart';
import 'package:saykoreanapp_f/pages/home/home_page.dart';
import 'package:saykoreanapp_f/styles/styled_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saykoreanapp_f/api/api.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

// 스타일 위젯 import
import 'package:saykoreanapp_f/main.dart'; // themeColorNotifier

// JWT → payload 추출
Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  final payload = base64Url.normalize(parts[1]);
  return json.decode(utf8.decode(base64Url.decode(payload)));
}

//------------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage>{
  // 1. 입력상자 컨트롤러
  TextEditingController emailCon = TextEditingController();
  TextEditingController pwdCont = TextEditingController();

  // user02@example.com , pass#02!

  // 로그인 메소드
  Future<void> onLogin() async {
    print("onLogin.exe");
    // 2. 자바와 통신
    try {
      final sendData = { "email": emailCon.text, "password": pwdCont.text};
      print(sendData);
      // baseUrl + path만 사용
      final response = await ApiClient.dio.post(
        '/saykorean/login',     // 슬래시로 시작하는 path만 적기
        data: sendData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) {
            // 500 에러도 받아서 확인
            return status! < 600;
          },
        ),
      );

      print("응답 상태: ${response.statusCode}");
      print("응답 데이터: ${response.data}");

      final data = response.data;
      print(data);

      if (response.statusCode == 200 && response.data != null && response.data != '') { // 로그인 성공시 토큰 SharedPreferences 저장하기.
        final token = response.data['token'];

        // 🔥 1) JWT → userNo 추출
        final decoded = _decodeJwt(token);
        final userNo = decoded['userNo'];

        // 1. 전역변수 호출
        final prefs = await SharedPreferences.getInstance();
        // 2. 전역변수 값 추가
        await prefs.setString( 'token', token.toString() );

        // * 은주 추가 코드
        await prefs.setInt('myUserNo', userNo);

        // * 로그인 성공 시 페이지 전환 //
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (content) => HomePage()),
        // );
        Navigator.pushReplacementNamed(context, '/home');
        await onAttend(userNo);
      }
      else {
        print("로그인 실패: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("로그인 오류 : $e");
      if (e is DioException) {
        print("응답 데이터: ${e.response?.data}");
        print("상태 코드: ${e.response?.statusCode}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
      );
    }
  } // c end

  Future<void> onAttend(userNo) async {
    try{
      final sendData = {"userNo":userNo};
      print(sendData);
      final response = await ApiClient.dio.post(
        '/saykorean/attend',
        data: sendData,
        options: Options(
          validateStatus: (status) =>true,
        ),
      );
      if(response.statusCode == 200 && response.data != null && response.data == 1){
        Fluttertoast.showToast(msg: "출석이 완료되었습니다.",backgroundColor: Colors.greenAccent);
      }
      else if( response.statusCode == 222 ){
        Fluttertoast.showToast(msg: "이미 출석이 완료되었습니다.",backgroundColor: Colors.red);
      }else{Fluttertoast.showToast(msg: "출석 체크 중 오류가 발생하였습니다.",backgroundColor: Colors.red);}
    }catch(e){print(e);}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';
    final bg = theme.scaffoldBackgroundColor;

    late final Color titleColor;
    late final Color subtitleColor;

    if (isDark) {
      titleColor = const Color(0xFFF7E0B4);
      subtitleColor = const Color(0xFFB0A3A0);
    } else if (isMint) {
      titleColor = const Color(0xFF2F7A69);
      subtitleColor = const Color(0xFF2F7A69);
    } else {
      titleColor = const Color(0xFF6B4E42);
      subtitleColor = const Color(0xFF9C7C68);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "로그인",
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                "계정에 로그인하여 학습을 시작하세요.",
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),

              const SizedBox(height: 40),

              // 이메일 입력
              StyledTextField(
                controller: emailCon,
                labelText: "이메일",
                prefixIcon: Icons.email_outlined,
                hintText: "example@email.com",
              ),

              const SizedBox(height: 16),

              // 비밀번호 입력
              StyledTextField(
                controller: pwdCont,
                labelText: "비밀번호",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                hintText: "8자 이상 입력",
              ),

              const SizedBox(height: 24),

              // 로그인 버튼
              StyledButton(
                onPressed: onLogin,
                text: "login.button".tr(),
              ),

              const SizedBox(height: 12),

              // 찾기 버튼
              StyledButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => FindPage())
                  );
                },
                text: "login.find".tr(),
                isPrimary: false,
              ),

              const SizedBox(height: 12),

              // 회원가입 버튼
              StyledButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage())
                  );
                },
               text:
                  "signup.signup".tr(),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}


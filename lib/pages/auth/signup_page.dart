import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field_v2/intl_phone_field.dart';
import 'package:intl_phone_field_v2/phone_number.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';
import 'package:saykoreanapp_f/api.dart';
import 'package:saykoreanapp_f/pages/auth/login_page.dart';

import 'package:saykoreanapp_f/utils/recaptcha_manager.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<SignupPage> {
  // * 입력 컨트롤러, 각 입력창에서 입력받은 값을 제어
  TextEditingController nameCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController nickNameCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();

  // 서버 전송용 국제번호 저장 변수
  PhoneNumber? emailPhoneNumber;

  // * 등록 버튼 클릭 시
  void onSignup() async {
    // 1. reCAPTCHA 토큰 요청 (Signup 액션)
    String recaptchaToken = '';
    try {
      // 봇이 아닌지 확인하기 위한 토큰 실행 (Execution)
      recaptchaToken = await RecaptchaManager.client.execute(RecaptchaAction.SIGNUP());
      print('reCAPTCHA Token successfully generated: $recaptchaToken');
    } catch (e) {
      // 토큰 생성 실패 시 (네트워크 오류, SDK 초기화 실패 등)
      Navigator.pop(context); // 로딩 닫기
      Fluttertoast.showToast(msg: "보안 검증 실패. 다시 시도해 주세요.", backgroundColor: Colors.red);
      print('reCAPTCHA execution error: $e');
      return; // 회원가입 진행을 중단
    }

    // 2. 자바에게 보낼 데이터 준비
    final plusPhone = emailPhoneNumber?.completeNumber ?? phoneCon.text;

    final sendData = {
      'name': nameCon.text,
      'email': emailCon.text,
      'password': passwordCon.text,
      'nickName': nickNameCon.text,
      'phone': plusPhone,
      'recaptchaToken':recaptchaToken,
    };
    print(sendData);
    // * Rest API 통신 간의 로딩 화면 표시, showDialog() : 팝업 창 띄우기 위한 위젯
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator(),),
      barrierDismissible: false, // 팝업창(로딩화면) 외 바깥 클릭 차단
    );
    try {
      final response = await ApiClient.dio.post(
          "/saykorean/signup", data: sendData);
      final data = response.data;

      Navigator.pop(context); // 가장 앞(가장 최근에 열린)에 있는 위젯 닫기 (showDialog(): 팝업 창)

      if (data) {
        print("회원가입 성공");

        Fluttertoast.showToast(
          msg: "회원가입 성공 했습니다.",
          // 출력할 내용
          toastLength: Toast.LENGTH_LONG,
          // 메시지 유지기간
          gravity: ToastGravity.BOTTOM,
          // 메시지 위치 : 앱 적용
          timeInSecForIosWeb: 3,
          // 자세한 유지시간 (sec)
          backgroundColor: Colors.redAccent,
          // 배경색
          textColor: Colors.green,
          // 글자색상
          fontSize: 16, // 글자 크기
        );

        // * 페이지 전환
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else {
        print("회원가입 실패");
      }
    } catch (e) {
      print(e);
    }
  } // f end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container( // Container( padding : , margin : ); 안쪽/바깥 여백 위젯
          padding: EdgeInsets.all(30), // EdgeInsets.all() : 상하좌우 모두 적용되는 안쪽 여백
          margin: EdgeInsets.all(30), // EdgeInsets.all() : 상하좌우 모두 적용되는 바깥 여백
          child: Column( // 세로배치 위젯
            mainAxisAlignment: MainAxisAlignment.center,
            // 주 축으로 가운데 정렬( Column 이면 세로 , Row이면 가로)
            children: [ // 하위 위젯
              TextField(
                controller: nameCon,
                decoration: InputDecoration(
                    labelText: "이름", border: OutlineInputBorder()),
              ), // 입력 위젯, 네임
              SizedBox(height: 20,),
              TextField(
                controller: emailCon,
                decoration: InputDecoration(
                    labelText: "이메일", border: OutlineInputBorder()),
              ), // 입력 위젯, 이메일(id)
              SizedBox(height: 20,),
              TextField(
                controller: passwordCon,
                obscureText: true, // 입력한 텍스트 가리기
                decoration: InputDecoration(
                    labelText: "비밀번호", border: OutlineInputBorder()),
              ), // 입력 위젯 , 패스워드
              SizedBox(height: 20,),
              TextField(
                controller: nickNameCon,
                decoration: InputDecoration(
                    labelText: "닉네임", border: OutlineInputBorder()),
              ), // 입력 위젯, 닉네임
              SizedBox(height: 20,),
              IntlPhoneField(
                controller: phoneCon,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'KR',
                autovalidateMode: AutovalidateMode.disabled,
                validator: (value) => null, // 자리수 검증 제거// ,
                onChanged: (phone) {
                  emailPhoneNumber = phone;
                  print("입력한 번호: ${phone.number}");
                }, // 입력 위젯, 전화번호
              ),
              SizedBox(height: 20,),

              ElevatedButton(onPressed: onSignup, child: Text("회원가입")),
              SizedBox(height: 20,),
              TextButton(onPressed: () =>
              {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage())
                )
              }, child: Text("이미 가입된 사용자면 로그인"))
            ],
          ),
        )
    );
  } // build end
} // class end
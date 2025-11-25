import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field_v2/intl_phone_field.dart';
import 'package:intl_phone_field_v2/phone_number.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';
import 'package:saykoreanapp_f/api/api.dart';
import 'package:saykoreanapp_f/pages/auth/login_page.dart';
import 'package:saykoreanapp_f/styles/styled_text_field.dart';
import 'package:saykoreanapp_f/utils/recaptcha_manager.dart';

// 스타일 위젯 import
import 'package:saykoreanapp_f/main.dart'; // themeColorNotifier

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<SignupPage> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController nickNameCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();
  TextEditingController passwordCon2 = TextEditingController();

  bool emailCheck = false;
  bool phoneCheck = false;
  PhoneNumber? emailPhoneNumber;

  void onSignup() async {
    if(nameCon.text.trim().isEmpty ||
        emailCon.text.trim().isEmpty ||
        passwordCon.text.trim().isEmpty ||
        nickNameCon.text.trim().isEmpty ||
        phoneCon.text.trim().isEmpty ||
        passwordCon2.text.trim().isEmpty)
    {
      Fluttertoast.showToast(msg: "입력값을 채워주세요.", backgroundColor: Colors.red);
      return;
    }
    if( passwordCon.text != passwordCon2.text ){
      Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다.",backgroundColor: Colors.red);
      return;
    }
    if( passwordCon.text.length <8 || passwordCon2.text.length <8 ){
      Fluttertoast.showToast(msg: "8자 이상 비밀번호를 입력해주세요.", backgroundColor: Colors.red);
      return;
    }
    if( emailCheck == false || phoneCheck == false ){
      Fluttertoast.showToast(msg: "중복 확인을 모두 해주세요.",backgroundColor: Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    String recaptchaToken = '';

    try {
      recaptchaToken = await RecaptchaManager.getClient().execute(RecaptchaAction.SIGNUP());
      print('reCAPTCHA Token successfully generated: $recaptchaToken');
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "보안 검증 실패. 다시 시도해 주세요. [$e]", backgroundColor: Colors.red, toastLength: Toast.LENGTH_LONG);
      return;
    }

    final plusPhone = emailPhoneNumber?.completeNumber ?? phoneCon.text;
    final sendData = {
      'name': nameCon.text,
      'email': emailCon.text,
      'password': passwordCon.text,
      'nickName': nickNameCon.text,
      'phone': plusPhone,
    };

    try {
      final response = await ApiClient.dio.post("/saykorean/signup", data: sendData);
      final data = response.data;

      Navigator.pop(context);

      if (data) {
        Fluttertoast.showToast(
          msg: "회원가입 성공 했습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 10,
          backgroundColor: Color(0xFFA8E6CF),
          textColor: Color(0xFF6B4E42),
          fontSize: 16,
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      else {
        Fluttertoast.showToast(msg: "회원가입 실패", backgroundColor: Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "서버 통신 오류가 발생했습니다.", backgroundColor: Colors.red);
    }
  }

  void checkEmail () async{
    try{
      final response = await ApiClient.dio.get(
          "/saykorean/checkemail",
          options: Options(validateStatus: (status) => true),
          queryParameters: { 'email' : emailCon.text }
      );
      if(response.statusCode == 200 && response.data != null && response.data == 0){
        setState(() {
          emailCheck=true;
        });
        Fluttertoast.showToast(msg: "이메일 사용이 가능합니다.", backgroundColor: Colors.greenAccent);
      }else{
        Fluttertoast.showToast(msg: "이메일 형식이 올바르지 않거나, 사용 중인 이메일입니다.", backgroundColor: Colors.red);
      }
    }catch(e){print(e);}
  }

  void checkPhone () async{
    try{
      final plusPhone = emailPhoneNumber?.completeNumber ?? phoneCon.text;
      final response = await ApiClient.dio.get(
          "/saykorean/checkphone",
          options: Options(validateStatus: (status) => true),
          queryParameters: { 'phone' : plusPhone }
      );
      if(response.statusCode == 200 && response.data != null && response.data == 0){
        setState(() {
          phoneCheck=true;
        });
        Fluttertoast.showToast(msg: "전화번호 사용이 가능합니다.", backgroundColor: Colors.greenAccent);
      }else{
        Fluttertoast.showToast(msg: "전화번호 형식이 올바르지 않거나, 사용 중인 전화번호입니다.", backgroundColor: Colors.red);
      }
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
    late final Color checkButtonBg;
    late final Color checkButtonFg;

    if (isDark) {
      titleColor = const Color(0xFFF7E0B4);
      subtitleColor = const Color(0xFFB0A3A0);
      checkButtonBg = theme.colorScheme.primaryContainer;
      checkButtonFg = theme.colorScheme.onPrimaryContainer;
    } else if (isMint) {
      titleColor = const Color(0xFF2F7A69);
      subtitleColor = const Color(0xFF2F7A69);
      checkButtonBg = const Color(0xFF2F7A69);
      checkButtonFg = Colors.white;
    } else {
      titleColor = const Color(0xFF6B4E42);
      subtitleColor = const Color(0xFF9C7C68);
      checkButtonBg = const Color(0xFF9C7C68);
      checkButtonFg = Colors.white;
    }

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "회원가입",
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "새로운 계정을 만들어 학습을 시작하세요.",
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),

              const SizedBox(height: 32),

              // 이름
              StyledTextField(
                controller: nameCon,
                labelText: "이름",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // 이메일
              StyledTextField(
                controller: emailCon,
                labelText: "이메일",
                prefixIcon: Icons.email_outlined,
                hintText: "example@email.com",
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: checkEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emailCheck ? const Color(0xFFA8E6CF) : checkButtonBg,
                      foregroundColor: emailCheck
                          ? (isMint ? const Color(0xFF2F7A69) : const Color(0xFF6B4E42))
                          : checkButtonFg,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      emailCheck ? "확인 완료" : "중복 확인",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 비밀번호
              StyledTextField(
                controller: passwordCon,
                labelText: "비밀번호",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                hintText: "8자 이상 입력해주세요",
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              StyledTextField(
                controller: passwordCon2,
                labelText: "비밀번호 확인",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                hintText: "8자 이상 입력해주세요",
              ),
              const SizedBox(height: 16),

              // 닉네임
              StyledTextField(
                controller: nickNameCon,
                labelText: "닉네임",
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // 전화번호
              StyledPhoneFieldContainer(
                labelText: "전화번호",
                prefixIcon: Icons.phone_outlined,
                child: IntlPhoneField(
                  controller: phoneCon,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  initialCountryCode: 'KR',
                  autovalidateMode: AutovalidateMode.disabled,
                  validator: (value) => null,
                  onChanged: (phone) {
                    emailPhoneNumber = phone;
                    setState(() {
                      phoneCheck = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: checkPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: phoneCheck ? const Color(0xFFA8E6CF) : checkButtonBg,
                      foregroundColor: phoneCheck
                          ? (isMint ? const Color(0xFF2F7A69) : const Color(0xFF6B4E42))
                          : checkButtonFg,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      phoneCheck ? "확인 완료" : "중복 확인",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 회원가입 버튼
              StyledButton(
                onPressed: onSignup,
                text: "회원가입",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
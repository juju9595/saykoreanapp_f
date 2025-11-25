import 'package:flutter/material.dart';
import 'package:intl_phone_field_v2/intl_phone_field.dart';
import 'package:intl_phone_field_v2/phone_number.dart';
import 'package:saykoreanapp_f/api/api.dart';
import 'package:saykoreanapp_f/styles/styled_text_field.dart';

// 스타일 위젯 import
import 'package:saykoreanapp_f/main.dart'; // themeColorNotifier

class FindPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FindState();
  }
}

class _FindState extends State<FindPage>{
  TextEditingController name1Con = TextEditingController();
  TextEditingController phone1Con = TextEditingController();
  TextEditingController name2Con = TextEditingController();
  TextEditingController phone2Con = TextEditingController();
  TextEditingController emailCon = TextEditingController();

  PhoneNumber? emailPhoneNumber;
  PhoneNumber? passwordPhoneNumber;

  void onFindEmail() async {
    print("onFindEmail.exe");
    try{
      final plusPhone = emailPhoneNumber?.completeNumber ?? phone1Con.text;

      final sendData = {
        "name" : name1Con.text,
        "phone" : plusPhone
      };
      print(sendData);
      final response = await ApiClient.dio.get(
          '/saykorean/findemail',
          queryParameters: sendData
      );
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('찾으시는 이메일은 : ${response.data} 입니다.'),
          duration: Duration(seconds: 15),
        ),
      );
    } catch(e){print("오류발생 : 이메일 찾기 실패, $e");}
  }

  void onFindPass() async{
    print("onFindPass.exe");
    try{
      final plusPhone = passwordPhoneNumber?.completeNumber ?? phone2Con.text;

      final sendData = {
        "name" : name2Con.text,
        "phone" : plusPhone,
        "email" : emailCon.text
      };
      print(sendData);
      final response = await ApiClient.dio.get(
          '/saykorean/findpwrd',
          queryParameters: sendData
      );
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('임시 비밀번호가 이메일로 발급되었습니다.'),
          duration: Duration(seconds: 15),
        ),
      );
    }catch(e){print("오류발생 : 비밀번호 찾기 실패, $e");}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';
    final bg = theme.scaffoldBackgroundColor;

    late final Color titleColor;

    if (isDark) {
      titleColor = const Color(0xFFF7E0B4);
    } else if (isMint) {
      titleColor = const Color(0xFF2F7A69);
    } else {
      titleColor = const Color(0xFF6B4E42);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "계정 찾기",
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
              // 이메일 찾기 섹션
              StyledSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StyledSectionTitle(
                      title: "이메일 찾기",
                      subtitle: "이름과 전화번호로 이메일을 찾아요.",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    StyledTextField(
                      controller: name1Con,
                      labelText: '이름',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    StyledPhoneFieldContainer(
                      labelText: "전화번호",
                      prefixIcon: Icons.phone_outlined,
                      child: IntlPhoneField(
                        controller: phone1Con,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        initialCountryCode: 'KR',
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) => null,
                        onChanged: (phone) {
                          emailPhoneNumber = phone;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: StyledButton(
                        onPressed: onFindEmail,
                        text: "이메일 찾기",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 비밀번호 찾기 섹션
              StyledSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StyledSectionTitle(
                      title: "비밀번호 찾기",
                      subtitle: "임시 비밀번호를 이메일로 전송해드려요.",
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 20),

                    StyledTextField(
                      controller: name2Con,
                      labelText: '이름',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    StyledPhoneFieldContainer(
                      labelText: "전화번호",
                      prefixIcon: Icons.phone_outlined,
                      child: IntlPhoneField(
                        controller: phone2Con,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        initialCountryCode: 'KR',
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) => null,
                        onChanged: (phone) {
                          passwordPhoneNumber = phone;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    StyledTextField(
                      controller: emailCon,
                      labelText: '이메일',
                      prefixIcon: Icons.email_outlined,
                      hintText: "example@email.com",
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: StyledButton(
                        onPressed: onFindPass,
                        text: "비밀번호 찾기",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
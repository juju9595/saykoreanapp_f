import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field_v2/intl_phone_field.dart';
import 'package:intl_phone_field_v2/phone_number.dart';
import 'package:saykoreanapp_f/api/api.dart';
import 'package:saykoreanapp_f/pages/auth/login_page.dart';
import 'package:saykoreanapp_f/pages/setting/myPage.dart';
import 'package:saykoreanapp_f/styles/styled_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 스타일 위젯 import
import 'package:saykoreanapp_f/main.dart'; // themeColorNotifier

class MyInfoUpdatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InfoUpdateState();
  }
}

class _InfoUpdateState extends State<MyInfoUpdatePage>{
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  TextEditingController nameCon = TextEditingController();
  TextEditingController nickCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();
  TextEditingController currentPassCon = TextEditingController();
  TextEditingController newPassCon = TextEditingController();
  TextEditingController checkPassCon = TextEditingController();

  bool phoneCheck = false;
  PhoneNumber? emailPhoneNumber;
  String originalPhone = "";

  Future<String?> showPasswordPrompt() async {
    final TextEditingController controller = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMint = themeColorNotifier.value == 'mint';

    late final Color titleColor;
    late final Color buttonColor;
    late final Color dialogBg;

    if (isDark) {
      titleColor = const Color(0xFFF7E0B4);
      buttonColor = theme.colorScheme.primaryContainer;
      dialogBg = const Color(0xFF261E1B);
    } else if (isMint) {
      titleColor = const Color(0xFF2F7A69);
      buttonColor = const Color(0xFF2F7A69);
      dialogBg = Colors.white;
    } else {
      titleColor = const Color(0xFF6B4E42);
      buttonColor = const Color(0xFF6B4E42);
      dialogBg = Colors.white;
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: dialogBg,
          title: Text(
            "정말 탈퇴하시겠습니까?",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          content: StyledTextField(
            controller: controller,
            labelText: "비밀번호",
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            hintText: "비밀번호를 입력해주세요",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(
                  color: isDark ? const Color(0xFFB0A3A0) : const Color(0xFF9C7C68)
              )),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void checkPhone() async {
    try {
      final plusPhone = emailPhoneNumber?.completeNumber ?? phoneCon.text;
      final response = await ApiClient.dio.get(
          "/saykorean/checkphone",
          options: Options(validateStatus: (status) => true),
          queryParameters: {'phone': plusPhone}
      );
      if (response.statusCode == 200 && response.data == 0) {
        setState(() => phoneCheck = true);
        Fluttertoast.showToast(msg: "전화번호 사용이 가능합니다.", backgroundColor: Colors.greenAccent);
      } else {
        Fluttertoast.showToast(msg: "전화번호 형식이 올바르지 않거나, 사용 중인 전화번호입니다.", backgroundColor: Colors.red);
      }
    } catch (e) {
      print(e);
    }
  }

  void updateUserInfo() async {
    if (nameCon.text.trim().isEmpty ||
        nickCon.text.trim().isEmpty ||
        phoneCon.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "입력값을 채워주세요.", backgroundColor: Colors.red);
      return;
    }

    try {
      final plusPhone = emailPhoneNumber?.completeNumber ?? "+82${phoneCon.text}";
      bool isPhoneChanged = (originalPhone != plusPhone);

      if (isPhoneChanged && !phoneCheck) {
        Fluttertoast.showToast(msg: "전화번호 중복 확인을 해주세요.", backgroundColor: Colors.red);
        return;
      }

      final sendData = {"name": nameCon.text, "nickName": nickCon.text, "phone": plusPhone};
      final response = await ApiClient.dio.put(
        "/saykorean/updateuserinfo",
        data: sendData,
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200 && response.data == 1) {
        Fluttertoast.showToast(msg: "수정이 완료되었습니다.", backgroundColor: Colors.greenAccent);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
      } else {
        Fluttertoast.showToast(msg: "수정이 실패했습니다.", backgroundColor: Colors.red);
      }
    } catch (e) {
      print(e);
    }
  }

  void updatePwrd() async {
    if (currentPassCon.text.trim().isEmpty ||
        newPassCon.text.trim().isEmpty ||
        checkPassCon.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "입력값을 채워주세요.", backgroundColor: Colors.red);
      return;
    }
    if (newPassCon.text != checkPassCon.text) {
      Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다.", backgroundColor: Colors.red);
      return;
    }
    if (newPassCon.text.length < 8) {
      Fluttertoast.showToast(msg: "8자 이상 비밀번호를 입력해주세요.", backgroundColor: Colors.red);
      return;
    }

    try {
      final sendData = {"currentPassword": currentPassCon.text, "newPassword": newPassCon.text};
      final response = await ApiClient.dio.put(
        "/saykorean/updatepwrd",
        data: sendData,
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "수정이 완료되었습니다.", backgroundColor: Colors.greenAccent);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
      } else {
        Fluttertoast.showToast(msg: "수정이 실패했습니다.", backgroundColor: Colors.red);
      }
    } catch (e) {
      print(e);
    }
  }

  void deleteUserStatus() async {
    try {
      final inputPassword = await showPasswordPrompt();

      if (inputPassword == null || inputPassword.trim().isEmpty) {
        Fluttertoast.showToast(msg: "취소되었습니다.", backgroundColor: Colors.red);
        return;
      }

      final response = await ApiClient.dio.put(
        "/saykorean/deleteuser",
        data: {"password": inputPassword},
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200 && response.data == 1) {
        Fluttertoast.showToast(msg: "회원 탈퇴가 완료되었습니다.", backgroundColor: Colors.greenAccent);
        LogOut();
      } else {
        Fluttertoast.showToast(msg: "비밀번호가 올바르지 않습니다.", backgroundColor: Colors.red);
      }
    } catch (e) {
      print(e);
    }
  }

  void LogOut() async {
    try {
      await ApiClient.dio.get('/saykorean/logout');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('myUserNo');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print(e);
    }
  }

  void loadUserInfo() async {
    try {
      final response = await ApiClient.dio.get(
        "/saykorean/info",
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        setState(() {
          nameCon.text = data["name"] ?? "";
          nickCon.text = data["nickName"] ?? "";
          String phone = data["phone"] ?? "";
          if (phone.startsWith("+82")) {
            phone = phone.substring(3);
          } else if (phone.startsWith("82")) {
            phone = phone.substring(2);
          }
          phoneCon.text = phone;
          originalPhone = data["phone"] ?? "";
        });
      }
    } catch (e) {
      print(e);
    }
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
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "정보 수정",
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
              // 사용자 정보 수정 섹션
              StyledSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StyledSectionTitle(
                      title: "사용자 정보 수정",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    StyledTextField(
                      controller: nameCon,
                      labelText: '이름',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    StyledTextField(
                      controller: nickCon,
                      labelText: '닉네임',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),

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
                          setState(() => phoneCheck = false);
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
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: StyledButton(
                        onPressed: updateUserInfo,
                        text: "수정",
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 비밀번호 수정 섹션
              StyledSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StyledSectionTitle(
                      title: "비밀번호 수정",
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 20),

                    StyledTextField(
                      controller: currentPassCon,
                      labelText: "기존 비밀번호",
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    StyledTextField(
                      controller: newPassCon,
                      labelText: "새 비밀번호",
                      prefixIcon: Icons.lock_open,
                      obscureText: true,
                      hintText: "8자 이상",
                    ),
                    const SizedBox(height: 12),

                    StyledTextField(
                      controller: checkPassCon,
                      labelText: "새 비밀번호 확인",
                      prefixIcon: Icons.lock_open,
                      obscureText: true,
                      hintText: "8자 이상",
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: StyledButton(
                        onPressed: updatePwrd,
                        text: "수정",
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 회원 탈퇴 섹션
              StyledSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.red[700], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "회원 탈퇴",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.",
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: deleteUserStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.exit_to_app, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "탈퇴",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
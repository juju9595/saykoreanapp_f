import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("회원가입페이지"),),
      body: Center(
        child: Column(
          children: [
            Text("회원가입 페이지"),
          // 정유진 : 뒤로가기 삭제함
          ],
        ),
      ),
    );
  }
}
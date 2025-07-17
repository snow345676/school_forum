import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:school_forum/Authentication/Auth.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _FlatState();
}

class _FlatState extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const Auth()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF4FB3C9);
    final Color lighterColor = const Color(0xFF6BC6EF);
    final Color shadowColor = const Color(0xFF084A59);
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon( Icons.mark_unread_chat_alt,size: 120,color: shadowColor,),
            SizedBox(height: 50),
            SpinKitThreeInOut
        (
              size: 30.0,

              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index.isEven ? lighterColor : mainColor,
                  ),
                );
              },
            ),



          ],
        ),
      ),
    );
  }
}

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
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5)).then((value) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const auth()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon( Icons.school,size: 200),
            SizedBox(height: 150),
            SpinKitThreeInOut
        (
              size: 35.0,

              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index.isEven ? Colors.cyan.shade100 : Colors.cyan.shade200,
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
//flutter pub add flutter_spinkit
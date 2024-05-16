import 'package:flutter/material.dart';

class LoginAndGuest extends StatelessWidget {
  const LoginAndGuest({super.key});

  @override
  Widget build(BuildContext context) {
    final double highSpace = MediaQuery.of(context).size.width / 50;
    return Scaffold(
      backgroundColor: const Color(0xff1F1F1F),
      body: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(txt: "VA", txtColor: Colors.white),
              customText(txt: "L", txtColor: Colors.redAccent),
              customText(txt: "INEUPS", txtColor: Colors.white),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(image: "assets/images/googleAuth.png"),
              SizedBox(width: 10.0),
              CustomButton(image: "assets/images/anonimAuth.png"),
            ],
          ),
          SizedBox(height: highSpace),
          const Text(
            "Valorant Unofficial Fan App",
            style: TextStyle(
                color: Color(0XFF6D6D6D),
                fontSize: 16.0,
                fontWeight: FontWeight.w100,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class customText extends StatelessWidget {
  final Color txtColor;
  final String txt;
  const customText({
    super.key,
    required this.txtColor,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
        color: txtColor,
        fontFamily: 'valo-font',
        fontSize: 36,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String image;
  const CustomButton({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final double authWidthButton = MediaQuery.of(context).size.width / 7;

    return SizedBox(
      width: authWidthButton,
      height: authWidthButton,
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xffBD3944)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        child: Image.asset(image),
      ),
    );
  }
}

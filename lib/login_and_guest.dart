import 'package:flutter/material.dart';
import 'package:valineups/langs/strings.dart';

class LoginAndGuest extends StatelessWidget {
  const LoginAndGuest({super.key});

  @override
  Widget build(BuildContext context) {
    final double highSpace = MediaQuery.of(context).size.width / 30;
    return Scaffold(
      backgroundColor: const Color(0xff1F1F1F),
      body: Column(
        children: [
          Expanded(
              flex: 7,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          "assets/images/login_and_guest_cover.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xff1F1F1F),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: const Color(0xFF1F1F1F).withOpacity(0.5),
                  ),
                ],
              )),
          SizedBox(height: highSpace * 2),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                        txt: AuthPageText().va,
                        txtColor: const Color(0xFFFFFBF5)),
                    CustomText(
                        txt: AuthPageText().l,
                        txtColor: const Color(0xFFD13739)),
                    CustomText(
                        txt: AuthPageText().ineups,
                        txtColor: const Color(0xFFFFFBF5)),
                  ],
                ),
                SizedBox(height: highSpace),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      image: AuthPageText().googleAuth,
                      buttonTxt: 'Google',
                    ),
                    CustomButton(
                      image: AuthPageText().anonimAuth,
                      buttonTxt: 'Anonim',
                    ),
                  ],
                ),
                SizedBox(height: highSpace),
                Text(
                  AuthPageText().infoText,
                  style: const TextStyle(
                      color: Color(0XFF6D6D6D),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final Color txtColor;
  final String txt;
  const CustomText({
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

class CustomButtonText extends StatelessWidget {
  final String txt;
  const CustomButtonText({
    super.key,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: const TextStyle(
        color: Color(0xFFFFFBF5),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String image;
  final String buttonTxt;
  const CustomButton({
    super.key,
    required this.image,
    required this.buttonTxt,
  });

  @override
  Widget build(BuildContext context) {
    final double authWidthButton = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
      child: Container(
        width: authWidthButton,
        height: authWidthButton / 9,
        decoration: BoxDecoration(
          color: const Color(0xFFD13739),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {},
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButtonText(txt: buttonTxt),
                const SizedBox(width: 5.0),
                Image.asset(image),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

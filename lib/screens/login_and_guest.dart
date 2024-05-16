import 'package:flutter/material.dart';
import 'package:valineups/components/custom_button.dart';
import 'package:valineups/components/custom_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';

class LoginAndGuestScreen extends StatelessWidget {
  const LoginAndGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ProjectColor().darkGrey,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                SizedBox(
                  height: mediaQueryHeight,
                  width: mediaQueryWidth,
                  child: Image.asset(
                    AuthPageText().loginGuestPageCover,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ProjectColor().transparent,
                        ProjectColor().darkGrey,
                      ],
                    ),
                  ),
                ),
                Container(
                  height: mediaQueryHeight,
                  width: mediaQueryWidth,
                  color: ProjectColor().darkGrey.withOpacity(0.5),
                ),
              ],
            ),
          ),
          SizedBox(height: mediaQueryWidth / 15),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      txt: AuthPageText().va,
                      txtColor: ProjectColor().customWhite,
                    ),
                    CustomText(
                      txt: AuthPageText().l,
                      txtColor: ProjectColor().valoRed,
                    ),
                    CustomText(
                      txt: AuthPageText().ineups,
                      txtColor: ProjectColor().customWhite,
                    ),
                  ],
                ),
                SizedBox(height: mediaQueryWidth / 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      image: AuthPageText().googleAuth,
                      buttonTxt: AuthPageText().google,
                    ),
                    CustomButton(
                      image: AuthPageText().anonimAuth,
                      buttonTxt: AuthPageText().anonim,
                    ),
                  ],
                ),
                SizedBox(height: mediaQueryWidth / 30),
                Text(
                  AuthPageText().infoText,
                  style: TextStyle(
                    color: ProjectColor().hintGrey,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

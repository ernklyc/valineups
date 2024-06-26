import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/utils/constants.dart';
import 'onboarding_screen.dart';
import 'package:valineups/components/custom_button.dart';
import 'package:valineups/components/custom_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';

class LoginAndGuestScreen extends StatelessWidget {
  const LoginAndGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ProjectColor().darkGrey,
      body: Stack(
        children: [
          Image(
            image: AssetImage(AuthPageText().loginGuestPageCover),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.high,
          ),
          Container(
            height: mediaQueryHeight,
            width: mediaQueryHeight,
            color: ProjectColor().darkGrey.withOpacity(0.3),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: ProjectEdgeInsets().buttonVertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
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
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: ProjectEdgeInsets().loginAndGuestPageButtonText,
        child: FloatingActionButton.small(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('seenOnboarding', true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              ),
            );
          },
          backgroundColor: ProjectColor().valoRed,
          child: Icon(
            Icons.info,
            color: ProjectColor().customWhite,
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endTop, // Düğmenin konumu
    );
  }
}

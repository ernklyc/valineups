import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/components/drawer_navBar.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/services/firestore.dart';
import 'package:valineups/utils/constants.dart';
import 'onboarding_screen.dart';
import 'package:valineups/components/custom_button.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';

class LoginAndGuestScreen extends StatefulWidget {
  const LoginAndGuestScreen({super.key});

  @override
  _LoginAndGuestScreenState createState() => _LoginAndGuestScreenState();
}

class _LoginAndGuestScreenState extends State<LoginAndGuestScreen> {
  late ThemeData themeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeData = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ProjectColor().dark,
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
            color: ProjectColor().dark.withOpacity(0.65),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: ProjectEdgeInsets().buttonVertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ValineupsText(),
                      SizedBox(height: mediaQueryWidth / 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                              image: AuthPageText().googleAuth,
                              buttonTxt: AuthPageText().google,
                              onPressed: () async {
                                await AuthService().signInWithGoogle();
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ControlPage(),
                                  ),
                                );
                              }),
                          CustomButton(
                              image: AuthPageText().anonimAuth,
                              buttonTxt: AuthPageText().anonim,
                              onPressed: () async {
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ControlPage(),
                                  ),
                                );
                              }),
                          SizedBox(height: mediaQueryWidth / 30),
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
            if (!mounted) return;
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

  Widget _buildTextField(String hintText, bool obscureText) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }
}

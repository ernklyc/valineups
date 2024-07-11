import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
  bool _isLoadingGoogle = false;
  bool _isLoadingAnonymous = false;

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
                          _isLoadingGoogle
                              ? Shimmer.fromColors(
                                  baseColor: Colors.red,
                                  highlightColor: Colors.yellow,
                                  child: SizedBox(
                                    width: mediaQueryWidth * 0.6,
                                    child: const Text(
                                      'Loading...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : CustomButton(
                                  image: AuthPageText().googleAuth,
                                  buttonTxt: AuthPageText().google,
                                  onPressed: () async {
                                    setState(() {
                                      _isLoadingGoogle = true;
                                    });
                                    bool result =
                                        await AuthService().signInWithGoogle();
                                    setState(() {
                                      _isLoadingGoogle = false;
                                    });
                                    if (result) {
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ControlPage(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Google sign-in failed'),
                                        ),
                                      );
                                    }
                                  }),
                          _isLoadingAnonymous
                              ? Shimmer.fromColors(
                                  baseColor: Colors.red,
                                  highlightColor: Colors.yellow,
                                  child: SizedBox(
                                    width: mediaQueryWidth * 0.6,
                                    child: const Text(
                                      'Loading...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : CustomButton(
                                  image: AuthPageText().anonimAuth,
                                  buttonTxt: AuthPageText().anonim,
                                  onPressed: () async {
                                    setState(() {
                                      _isLoadingAnonymous = true;
                                    });
                                    bool result =
                                        await AuthService().signInAnonymously();
                                    setState(() {
                                      _isLoadingAnonymous = false;
                                    });
                                    if (result) {
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ControlPage(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Anonymous sign-in failed'),
                                        ),
                                      );
                                    }
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
}

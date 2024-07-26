import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/generated/locale_keys.g.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/screens/first/login_and_guest.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      body: Padding(
        padding: ProjectEdgeInsets().all16,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: _buildPageView(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: _buildDotsIndicator(),
                ),
                _buildNavigationButtons(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProjectColor().white,
                shape: RoundedRectangleBorder(
                  borderRadius: ProjectBorderRadius().circular30,
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                minimumSize: Size(30, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                context.setLocale(const Locale('tr', 'TR'));
              },
              child: Text(
                'TR',
                style: TextStyle(
                  color: ProjectColor().dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProjectColor().white,
                shape: RoundedRectangleBorder(
                  borderRadius: ProjectBorderRadius().circular30,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                minimumSize: Size(30, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                context.setLocale(const Locale('en', 'US'));
              },
              child: Text(
                'EN',
                style: TextStyle(
                  color: ProjectColor().dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: 3,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return buildPage(
              title: LocaleKeys.screen1Title.tr(),
              description: LocaleKeys.screen1Text.tr(),
              imagePath: OnBoardingScreen().agents,
            );
          case 1:
            return buildPage(
              title: LocaleKeys.screen2Title.tr(),
              description: LocaleKeys.screen2Text.tr(),
              imagePath: OnBoardingScreen().lineups,
            );
          case 2:
          default:
            return buildPage(
              title: LocaleKeys.screen3Title.tr(),
              description: LocaleKeys.screen3Text.tr(),
              imagePath: OnBoardingScreen().discussions,
            );
        }
      },
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => buildDot(index)),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: ProjectEdgeInsets().vertical20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _completeOnboardingAndNavigate,
            child: Text(
              LocaleKeys.skipButton.tr(),
              style: TextStyle(fontSize: 16, color: ProjectColor().customWhite),
            ),
          ),
          _currentPage == 2 ? _buildStartButton() : _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
      style: ElevatedButton.styleFrom(
        padding: ProjectEdgeInsets().horizontal30Vertical15,
        shape: RoundedRectangleBorder(
          borderRadius: ProjectBorderRadius().circular30,
        ),
        backgroundColor: ProjectColor().valoRed,
      ),
      child: Text(
        LocaleKeys.nextButton.tr(),
        style: TextStyle(
          fontSize: 18,
          color: ProjectColor().customWhite,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _completeOnboardingAndNavigate,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: Size(100, 0),
        backgroundColor: ProjectColor().valoRed,
      ),
      child: Text(
        LocaleKeys.startButton.tr(),
        style: TextStyle(fontSize: 18, color: ProjectColor().customWhite),
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  height: constraints.maxHeight * 0.4,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(top: constraints.maxHeight * 0.1),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: ProjectColor().customWhite,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: ProjectEdgeInsets().onBoardingText,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.05,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 12 : 10,
      margin: ProjectEdgeInsets().horizontal4,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.grey,
        borderRadius: ProjectBorderRadius().circular12,
      ),
    );
  }

  Future<void> _completeOnboardingAndNavigate() async {
    await _completeOnboarding();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const LoginAndGuestScreen(),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }
}

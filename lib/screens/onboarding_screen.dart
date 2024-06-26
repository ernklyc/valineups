import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/screens/login_and_guest.dart';
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
      backgroundColor: ProjectColor().darkGrey,
      body: Padding(
        padding: ProjectEdgeInsets().all16,
        child: Column(
          children: [
            Expanded(
              child: _buildPageView(),
            ),
            _buildDotsIndicator(),
            _buildNavigationButtons(),
          ],
        ),
      ),
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
        // Her sayfa için farklı bir resim ve açıklama
        switch (index) {
          case 0:
            return buildPage(
              title: OnBoardingScreen().agentTitle,
              description: OnBoardingScreen().agentDesc,
              imagePath: OnBoardingScreen().agents,
            );
          case 1:
            return buildPage(
              title: OnBoardingScreen().lineupTitle,
              description: OnBoardingScreen().lineupDesc,
              imagePath: OnBoardingScreen().lineups,
            );
          case 2:
          default:
            return buildPage(
              title: OnBoardingScreen().discussionTitle,
              description: OnBoardingScreen().discussionDesc,
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
              OnBoardingScreen().skip,
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
        OnBoardingScreen().next,
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
          padding: ProjectEdgeInsets().horizontal50Vertical15,
          shape: RoundedRectangleBorder(
            borderRadius: ProjectBorderRadius().circular30,
          ),
          backgroundColor: ProjectColor().valoRed),
      child: Text(
        OnBoardingScreen().start,
        style: TextStyle(fontSize: 18, color: ProjectColor().customWhite),
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          height: 300,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: ProjectEdgeInsets().top64,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
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
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 12 : 10,
      margin: ProjectEdgeInsets().horizontal4,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
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

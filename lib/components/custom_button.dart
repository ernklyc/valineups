import 'package:flutter/material.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

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
      padding: ProjectEdgeInsets().loginAndGuestPageButton,
      child: Container(
        width: authWidthButton,
        height: authWidthButton / 9,
        decoration: BoxDecoration(
          color: ProjectColor().valoRed,
          borderRadius: Decorations().circular8,
        ),
        child: InkWell(
          onTap: () {},
          overlayColor: WidgetStateProperty.all(ProjectColor().transparent),
          child: Padding(
            padding: ProjectEdgeInsets().loginAndGuestPageButtonText,
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
      style: TextStyle(
        color: ProjectColor().customWhite,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

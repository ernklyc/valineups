import 'package:flutter/material.dart';
import 'package:valineups/styles/fonts.dart';

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
        fontFamily: Fonts().valFonts,
        fontSize: 36,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:valineups/components/custom_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';

class ValineupsText extends StatelessWidget {
  const ValineupsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

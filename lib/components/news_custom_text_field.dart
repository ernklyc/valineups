import 'package:flutter/material.dart';
import 'package:valineups/styles/project_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: ProjectColor().white,
      controller: controller,
      style: TextStyle(
        color: ProjectColor().white,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: ProjectColor().hintGrey,
          fontSize: 13,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ProjectColor().white,
          ),
        ),
      ),
    );
  }
}

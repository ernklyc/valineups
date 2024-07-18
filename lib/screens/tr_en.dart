import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LangueTranslations extends StatefulWidget {
  const LangueTranslations({super.key});

  @override
  State<LangueTranslations> createState() => _LangueTranslationsState();
}

class _LangueTranslationsState extends State<LangueTranslations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.setLocale(const Locale('en', 'US'));
            },
            child: const Text('English'),
          ),
          ElevatedButton(
            onPressed: () {
              context.setLocale(const Locale('tr', 'TR'));
            },
            child: const Text('Türkçe'),
          ),
        ],
      ),
    ));
  }
}

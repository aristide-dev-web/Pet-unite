import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AnimalFormScreen extends StatelessWidget {
  const AnimalFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'registration_screen_disabled'.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
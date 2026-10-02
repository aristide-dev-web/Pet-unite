import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InfoLegaliScreen extends StatelessWidget {
  const InfoLegaliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('legal_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'legal_title'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'legal_copyright'.tr() + '\n\n' + 'legal_desc'.tr(),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
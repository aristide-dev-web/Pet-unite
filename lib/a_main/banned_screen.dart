import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gavel_rounded, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'account_banned_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'account_banned_message'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Puoi aggiungere un link al supporto se vuoi
                },
                child: Text('contact_support'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

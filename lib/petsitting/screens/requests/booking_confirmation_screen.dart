import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("booking_confirm_title".tr())),
      body: Center(
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            Text("booking_confirm_step8".tr()),
            Text("booking_confirm_step7".tr()),
          ],
        ),
      ),
    );
  }
}

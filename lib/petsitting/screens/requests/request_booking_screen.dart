import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:easy_localization/easy_localization.dart';

class RequestBookingScreen extends StatefulWidget {
  final SitterProfile sitter;
  const RequestBookingScreen({super.key, required this.sitter});

  @override
  State<RequestBookingScreen> createState() => _RequestBookingScreenState();
}

class _RequestBookingScreenState extends State<RequestBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("booking_request_title".tr())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("booking_request_step2".tr()),
            Text("booking_request_step3".tr()),
            Text("booking_request_step6".tr()),
          ],
        ),
      ),
    );
  }
}

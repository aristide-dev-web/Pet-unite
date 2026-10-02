import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:petping/strip/stripe_api_service.dart';
import 'widgets/premium_paywall_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as dev;

class SubscriptionButton extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String currentUserId;
  final bool isSmall;

  const SubscriptionButton({
    super.key,
    required this.userData,
    required this.currentUserId,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPremium = userData['isPremiumSOS'] == true;

    return GestureDetector(
      onTap: () => _handleSubscription(context, isPremium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 20, 
          vertical: isSmall ? 10 : 12    
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
                : [const Color(0xFF673AB7), const Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isSmall ? 18 : 25),
          boxShadow: [
            BoxShadow(
              color: (isPremium ? Colors.orange : Colors.deepPurple).withOpacity(0.3),
              blurRadius: isSmall ? 6 : 12,
              offset: Offset(0, isSmall ? 3 : 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPremium ? Icons.star_rounded : Icons.workspace_premium_rounded,
              color: Colors.white,
              size: isSmall ? 12 : 18,
            ),
            const SizedBox(width: 3),
            Text(
              'subscription_label'.tr().toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 8.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: isSmall ? -0.5 : 0.3,
              ),
            ),
            if (!isSmall) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 14
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscription(BuildContext context, bool isPremium) async {
    if (isPremium) {
      try {
        final url = await StripeApiService.instance.createStripePortalSession();
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          _showError(context, 'sub_error_invalid_url'.tr());
        }
      } catch (e) {
        _showError(context, 'sub_error_connection'.tr(args: [e.toString()]));
      }
    } else {
      await PremiumPaywallDialog.show(context);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

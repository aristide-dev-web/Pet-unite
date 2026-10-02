import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class AppVersionScreen extends StatefulWidget {
  const AppVersionScreen({super.key});

  @override
  State<AppVersionScreen> createState() => _AppVersionScreenState();
}

class _AppVersionScreenState extends State<AppVersionScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _caricaInfoApp();
  }

  Future<void> _caricaInfoApp() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_app_version_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('settings_app_version_label'.tr(args: [_version]), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('settings_app_build_label'.tr(args: [_buildNumber]), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
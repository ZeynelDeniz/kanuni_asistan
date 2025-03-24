import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = SettingsService();
  final settingsController = SettingsController(settingsService);

  await settingsController.loadSettings();

  Get.put(settingsController);

  runApp(const MyApp());
}

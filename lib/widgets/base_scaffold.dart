import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../src/settings/settings_controller.dart';
import 'app_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
    this.fab,
    this.appBarActions,
  });

  final Widget body;
  final String? appBarTitle;
  final Widget? fab;
  final List<Widget>? appBarActions;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? AppLocalizations.of(context)!.appTitle),
        actions: appBarActions,
      ),
      drawer: AppDrawer(settingsController: settingsController),
      body: Column(
        children: [
          Expanded(
            child: body,
          ),
          if (Platform.isIOS)
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
        ],
      ),
      floatingActionButton: fab,
    );
  }
}

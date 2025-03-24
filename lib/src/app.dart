import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../src/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    // Force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('tr', ''), // Turkish, no country code
        ],
        locale: settingsController.locale.value,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        theme: ThemeData.light(), // Replace with your custom light theme
        darkTheme: ThemeData.dark(), // Replace with your custom dark theme
        themeMode: settingsController.themeMode.value,
        initialRoute: HomeScreen.routeName,
        getPages: [
          GetPage(
            name: HomeScreen.routeName,
            page: () => const HomeScreen(),
          ),
        ],
      );
    });
  }
}

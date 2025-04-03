import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:get/get.dart';

import '../src/settings/settings_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> screensInDrawer = [
      DrawerItem(
        dTitle: AppLocalizations.of(context)!.homeScreenTitle,
        dRoute: "/",
        icon: Icons.home,
      ),
      DrawerItem(
        dTitle: AppLocalizations.of(context)!.chatScreenTitle,
        dRoute: "/chat",
        icon: Icons.chat,
      ),
    ];

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerHeader(context),
                ...screensInDrawer.map(
                  (screen) {
                    return ListTile(
                      leading: screen.iconAsset != null
                          ? Image.asset(
                              screen.iconAsset!,
                              width: 24,
                              height: 24,
                            )
                          : Icon(
                              screen.icon,
                            ),
                      title: Text(screen.dTitle),
                      onTap: () async {
                        // Check if the current route is the same as the target route
                        if (Get.currentRoute == screen.dRoute) {
                          Get.back(); // Just close the drawer
                        } else {
                          Get.back();
                          Get.offAndToNamed(
                              screen.dRoute); // Navigate to the new route
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(),
          _buildThemeSwitch(context),
          _buildLocaleSwitch(context),
          SizedBox(height: 24)
        ],
      ),
    );
  }

  DrawerHeader _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        children: [
          Spacer(),
          Text(
            AppLocalizations.of(context)!.appTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.theme,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Obx(() {
            return IconTheme.merge(
              data: const IconThemeData(color: Colors.white),
              child: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.85,
                child: AnimatedToggleSwitch<int>.rolling(
                  current: settingsController.themeMode.value.index,
                  values: const [0, 1, 2],
                  onChanged: (index) {
                    ThemeMode newThemeMode;
                    switch (index) {
                      case 1:
                        newThemeMode = ThemeMode.light;
                        break;
                      case 2:
                        newThemeMode = ThemeMode.dark;
                        break;
                      case 0:
                      default:
                        newThemeMode = ThemeMode.system;
                        break;
                    }
                    settingsController.updateThemeMode(newThemeMode);
                    return Future.value();
                  },
                  height: 50,
                  iconBuilder: (value, foreground) {
                    final themeMode = settingsController.themeMode.value;
                    final isDarkMode = themeMode == ThemeMode.dark ||
                        (themeMode == ThemeMode.system &&
                            View.of(context)
                                    .platformDispatcher
                                    .platformBrightness ==
                                Brightness.dark);

                    final color = foreground
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black);

                    switch (value) {
                      case 1:
                        return Icon(Icons.light_mode, color: color);
                      case 2:
                        return Icon(Icons.dark_mode, color: color);
                      case 0:
                      default:
                        return Icon(Icons.brightness_auto, color: color);
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocaleSwitch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.localeName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Obx(() {
            return IconTheme.merge(
              data: const IconThemeData(color: Colors.white),
              child: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.85,
                child: AnimatedToggleSwitch<int>.rolling(
                  current: settingsController.locale.value == const Locale('tr')
                      ? 1
                      : 0,
                  values: const [0, 1],
                  onChanged: (index) {
                    Locale newLocale;
                    switch (index) {
                      case 1:
                        newLocale = Locale('tr');
                        break;
                      case 0:
                      default:
                        newLocale = Locale('en');
                        break;
                    }
                    settingsController.updateLocale(newLocale);
                    return Future.value();
                  },
                  style: ToggleStyle(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 50,
                  iconBuilder: (value, foreground) {
                    switch (value) {
                      case 1:
                        return CountryFlag.fromCountryCode('TR',
                            shape: const Circle(), width: 35, height: 35);
                      case 0:
                      default:
                        return CountryFlag.fromCountryCode('US',
                            shape: const Circle(), width: 35, height: 35);
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DrawerItem {
  final String dTitle;
  final String dRoute;
  final String? iconAsset; // Asset yolu, opsiyonel
  final IconData? icon; // Standart ikon, opsiyonel

  DrawerItem({
    required this.dTitle,
    required this.dRoute,
    this.iconAsset,
    this.icon,
  });
}

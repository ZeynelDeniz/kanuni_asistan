import 'package:flutter/material.dart';
import '../widgets/base_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.homeScreenTitle,
      body: Center(child: Text('')),
    );
  }
}

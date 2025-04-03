import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    return isTyping
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.more_horiz, color: Colors.grey),
                Text(
                  AppLocalizations.of(context)!.chatScreenTypingIndicator,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class RichTextData {
  RichTextData({
    required this.textWithTags,
  });

  final List<TextWithTag> textWithTags;
}

class TextWithTag {
  TextWithTag({
    this.text,
    this.style,
    this.recognizer,
  });

  final String? text;
  TextStyle? style;
  GestureRecognizer? recognizer;
}

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    required this.richTextData,
    super.key,
  });

  final RichTextData richTextData;

  @override
  Widget build(BuildContext context) {
    final widgets = <InlineSpan>[];

    for (final rt in richTextData.textWithTags) {
      widgets.add(
        TextSpan(
          text: rt.text,
          style: rt.style,
          recognizer: rt.recognizer,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: widgets,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class AppFooterView extends StatelessWidget {
  const AppFooterView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.copyWith(fontSize: 12);
    final linkStyle = baseStyle.copyWith(
      color: Theme.of(context).colorScheme.secondary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Link(
            uri: Uri.parse('https://github.com/lunaticfriki'),
            target: LinkTarget.blank,
            builder: (context, followLink) => GestureDetector(
              onTap: followLink,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text('@lunaticfriki', style: linkStyle),
              ),
            ),
          ),
          Text(', ', style: baseStyle),
          Text('${DateTime.now().year}', style: linkStyle),
        ],
      ),
    );
  }
}

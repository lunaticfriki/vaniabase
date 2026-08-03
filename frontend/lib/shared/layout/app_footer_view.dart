import 'package:flutter/material.dart';

class AppFooterView extends StatelessWidget {
  const AppFooterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Text(
        '© vaniabase — a personal catalog for books, comics, magazines, movies, video games and music',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

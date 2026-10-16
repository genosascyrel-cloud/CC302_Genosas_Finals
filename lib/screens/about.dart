import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget item(IconData i, String title, String body) => ListTile(
          leading: Icon(i, color: t.colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(body),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/logo.png', width: 110, height: 110),
              ),
            ),
            const SizedBox(height: 12),
            Text('Bohol Explorer',
                textAlign: TextAlign.center,
                style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('Version 1.0.0', textAlign: TextAlign.center, style: t.textTheme.bodySmall),
            const SizedBox(height: 16),
            item(Icons.flag, 'Purpose',
                'Helps travelers discover Bohol\'s attractions and plan their trip in one place.'),
            item(Icons.people, 'Intended users',
                'Tourists, students and locals planning a visit to Bohol, Philippines.'),
            item(Icons.cloud_download, 'Data sources',
                'Wikipedia REST API (attractions) and Open-Meteo (live weather).'),
            item(Icons.touch_app, 'Tips',
                'Tap the bookmark to save a place. In My Trip, swipe left or tap the trash icon to delete.'),
            const Divider(),
            Text('CC 302 Final Project · Flutter & Dart',
                textAlign: TextAlign.center, style: t.textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}

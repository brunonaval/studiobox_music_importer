import 'package:flutter/material.dart';

import 'features/home/presentation/home_screen.dart';

class StudioBoxMusicImporterApp extends StatelessWidget {
  const StudioBoxMusicImporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudioBox Music Importer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

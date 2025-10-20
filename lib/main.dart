import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/listings/presentation/listings_screen.dart';

void main() {
  runApp(const ProviderScope(child: TekerayApp()));
}

class TekerayApp extends StatelessWidget {
  const TekerayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekeray',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
      ),
      home: const ListingsScreen(),
    );
  }
}

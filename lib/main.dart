import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/services/key.dart';

import 'package:translator/view/navigation.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: url,
    anonKey: anon,
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: NavigationProgress(),
    );
  }
}

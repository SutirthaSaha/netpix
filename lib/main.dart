import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:netpix/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xFFFFFFFF), // <---- I set white color here
    primaryVariant: Color(0xFF117378),
    secondary: Color(0xFFEFF3F3),
    secondaryVariant: Color(0xFFFAFBFB),
    background: Color(0xFF636363),
    surface: Color(0xFF808080),
    onBackground: Colors.white,
    error: Colors.redAccent,
    onError: Colors.redAccent,
    onPrimary: Colors.redAccent,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetPix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData
        (
        scaffoldBackgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        primarySwatch: Colors.grey,
        cardColor: Colors.white70,
        colorScheme: colorScheme, textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black)
      ),
      home: HomePage(),
    );
  }
}

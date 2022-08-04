import 'dart:io';

import 'package:collatz_conjecture_flutter/home.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS) {
      await Window.initialize();
      await Window.setEffect(effect: WindowEffect.acrylic, dark: true);
    }

    setWindowMinSize(const Size(1100, 500));
    setWindowTitle("Collatz Conjecture");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isLinux) {
      return FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'Collatz Conjecture',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          activeColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        home: const HomePage(),
      );
    }

    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Collatz Conjecture',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        activeColor: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jesus24/utils/app_styles.dart';

import 'controllers/settings_controller.dart';
import 'screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  [Permission.location, Permission.storage, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan]
      .request()
      .then((status) {
    runApp(const ProviderScope(child: MyApp()));
  });
  /*Run app*/
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fluttooth',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.themeData(ref.watch(darkProvider), context),
      darkTheme: AppStyles.themeData(true, context),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
      home: const SplashPage(),
    );
  }
}

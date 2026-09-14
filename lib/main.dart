import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_constants.dart';
import 'core/trial_manager.dart';
import 'features/auth/auth_controller.dart';
import 'features/profile/multi_profile_engine.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final profiles = MultiProfileEngine(prefs);
  await profiles.load();
  final auth = AuthController(prefs)..load();
  runApp(
    LifexApp(
      prefs: prefs,
      profiles: profiles,
      auth: auth,
    ),
  );
}

class LifexApp extends StatelessWidget {
  const LifexApp({
    super.key,
    required this.prefs,
    required this.profiles,
    required this.auth,
  });

  final SharedPreferences prefs;
  final MultiProfileEngine profiles;
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TrialManager>.value(value: TrialManager(prefs)),
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<ActiveProfileController>(
          create: (_) => ActiveProfileController(profiles),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.brandTeal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Tahoma',
        ),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}


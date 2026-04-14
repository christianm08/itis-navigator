import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/constants.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
import 'services/theme_provider.dart';
import 'services/tts_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(AppStrings.prefsOnboardingDone) ?? false;

  runApp(ItisNavigatorApp(onboardingDone: onboardingDone));
}

class ItisNavigatorApp extends StatelessWidget {
  final bool onboardingDone;
  const ItisNavigatorApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
        ChangeNotifierProxyProvider<TtsService, NavigationService>(
          create: (_) => NavigationService(),
          update: (_, tts, nav) => nav!..attachTts(tts),
        ),
        ChangeNotifierProvider(create: (_) => WeatherService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ITIS Navigator',
            locale: const Locale('it', 'IT'),
            supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            home: onboardingDone ? const HomeScreen() : const OnboardingScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const primaryColor = AppColors.primaryColor;
    const secondaryColor = AppColors.secondaryColor;
    const accentColor = AppColors.accentColor;

    final surfaceColor = isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor;
    final cardColor = isDark ? AppColors.darkCardColor : AppColors.lightCardColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.lightTextColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        onTertiary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
        primaryContainer: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
        onPrimaryContainer: isDark ? Colors.white : primaryColor,
        secondaryContainer: isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE),
        onSecondaryContainer: isDark ? Colors.white : secondaryColor,
        tertiaryContainer: isDark ? const Color(0xFF164E63) : const Color(0xFFCFFAFE),
        onTertiaryContainer: isDark ? Colors.white : accentColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: cardColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

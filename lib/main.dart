import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
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
  
  runApp(const ItisNavigatorApp());
}

class ItisNavigatorApp extends StatelessWidget {
  const ItisNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ITIS Navigator',
        locale: const Locale('it', 'IT'),
        supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: _buildWarmTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildWarmTheme() {
    // Colori caldi e vivaci per un'atmosfera amichevole
    const primaryColor = Color(0xFFFF6B6B); // Rosso corallo caldo
    const secondaryColor = Color(0xFFFFD93D); // Giallo sole
    const accentColor = Color(0xFFFF8E53); // Arancione amichevole
    const backgroundColor = Color(0xFFFFF8F0); // Crema caldo
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: backgroundColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF2D3436),
        onSurface: Color(0xFF2D3436),
        primaryContainer: Color(0xFFFFE5E5),
        secondaryContainer: Color(0xFFFFF5D6),
        tertiaryContainer: Color(0xFFFFE8D9),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: const Color(0xFF2D3436),
        displayColor: const Color(0xFF2D3436),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D3436),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

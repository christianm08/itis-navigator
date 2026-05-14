import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';
import '../utils/string_utils.dart';
import '../widgets/widgets.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'destination_picker_screen.dart' show kDestinations;
import 'map_navigation_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'sos_screen.dart';
import 'transport_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _currentDate = '';
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = StringUtils.capitalize(
          DateFormat('EEEE, d MMMM yyyy', 'it_IT').format(now));
    });
  }

  Future<void> _initializeServices() async {
    final locationService = context.read<LocationService>();
    final weatherService = context.read<WeatherService>();
    try { await locationService.initialize(); } catch (e) {
      debugPrint('Errore GPS: $e');
    }
    try { await weatherService.fetchWeather(); } catch (e) {
      debugPrint('Errore meteo: $e');
    }
  }

  Future<void> _openSchoolWebsite() async {
    final uri = Uri.parse(AppStrings.schoolWebsite);
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.schoolWebsiteError)),
      );
    }
  }

  void _navigateTo(dest) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapNavigationScreen(destination: dest),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openSos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SosScreen()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 32,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(_getGreeting(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 4),
                      Semantics(
                        button: true,
                        label: 'Apri impostazioni',
                        child: IconButton(
                          icon: const Icon(Icons.settings_rounded,
                              color: Colors.white, size: 28),
                          tooltip: 'Impostazioni',
                          onPressed: _openSettings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(_currentTime, maxLines: 1,
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 56,
                        )),
                  ),
                  const SizedBox(height: 4),
                  Text(_currentDate,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWeatherCard(theme),
                const SizedBox(height: 20),
                _buildNavigationCard(theme),
                const SizedBox(height: 20),
                _buildTransportCard(theme),
                const SizedBox(height: 20),
                _buildQrCard(theme),
                const SizedBox(height: 20),
                _buildSosCard(theme),
                const SizedBox(height: 20),
                _buildSchoolInfoCard(theme),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buongiorno';
    if (h < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  Widget _buildWeatherCard(ThemeData theme) {
    return Consumer<WeatherService>(
      builder: (context, ws, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.secondary, theme.colorScheme.tertiary],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.25),
              blurRadius: 20, offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ws.isLoading
            ? const SizedBox(
                height: 120,
                child: Center(
                    child: CircularProgressIndicator(color: Colors.white)))
            : LayoutBuilder(builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                return Semantics(
                  label: 'Meteo a Cassino: ${ws.description}, '
                      '${ws.temperature} gradi. '
                      'Vento ${ws.windSpeed.toStringAsFixed(1)} ${AppStrings.weatherUnitKmh}, '
                      'Umidità ${ws.humidity} ${AppStrings.weatherUnitPercent}.',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12, runSpacing: 12,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isCompact
                                    ? constraints.maxWidth
                                    : constraints.maxWidth * 0.62,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.weatherTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(ws.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9))),
                                ],
                              ),
                            ),
                            Text(ws.icon,
                                style: TextStyle(
                                    fontSize: isCompact ? 48 : 64)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12, runSpacing: 12,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('${ws.temperature}${AppStrings.weatherUnitCelsius}',
                                  style: theme.textTheme.displayLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isCompact ? 40 : 48)),
                            ),
                            Wrap(
                              spacing: 12, runSpacing: 12,
                              children: [
                                WeatherDetail(
                                  label: AppStrings.weatherWind,
                                  value: '${ws.windSpeed.toStringAsFixed(1)} ${AppStrings.weatherUnitKmh}',
                                ),
                                WeatherDetail(
                                  label: AppStrings.weatherHumidity,
                                  value: '${ws.humidity}${AppStrings.weatherUnitPercent}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
      ),
    );
  }

  Widget _buildNavigationCard(ThemeData theme) {
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final scuola = kDestinations.firstWhere(
      (d) => d.name.contains('Biennio'),
      orElse: () => kDestinations.first,
    );
    final stazione = kDestinations.firstWhere(
      (d) => d.name.contains('Stazione'),
      orElse: () => kDestinations.last,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: isDark
            ? Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
            blurRadius: 20, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.navigation_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.navigationTitle,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(AppStrings.navigationSubtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: AppStrings.schoolNavAccessibility,
                  child: NavigationDestButton(
                    icon: Icons.school_rounded,
                    label: AppStrings.schoolNavLabel,
                    gradient: [cs.primary, cs.secondary],
                    onTap: () => _navigateTo(scuola),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  button: true,
                  label: AppStrings.stationNavAccessibility,
                  child: NavigationDestButton(
                    icon: Icons.train_rounded,
                    label: AppStrings.stationNavLabel,
                    gradient: const [AppColors.trenintColor, AppColors.trenitaliSecondaryColor],
                    onTap: () => _navigateTo(stazione),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(ThemeData theme) {
    return Semantics(
      button: true,
      label: AppStrings.qrAccessibility,
      child: GradientCard(
        icon: Icons.qr_code_scanner_rounded,
        iconGradient: const [AppColors.qrPrimary, AppColors.qrSecondary],
        title: AppStrings.qrTitle,
        subtitle: AppStrings.qrSubtitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
        ),
      ),
    );
  }

  Widget _buildTransportCard(ThemeData theme) {
    return Semantics(
      button: true,
      label: AppStrings.transportAccessibility,
      child: GradientCard(
        icon: Icons.directions_transit_rounded,
        iconGradient: const [AppColors.trenintColor, AppColors.trenitaliSecondaryColor],
        title: AppStrings.transportTitle,
        subtitle: AppStrings.transportSubtitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransportScreen()),
        ),
      ),
    );
  }

  Widget _buildSosCard(ThemeData theme) {
    return Semantics(
      button: true,
      label: 'Apri schermata SOS emergenza',
      child: GestureDetector(
        onTap: _openSos,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS Emergenza',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chiama i soccorsi in caso di emergenza',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolInfoCard(ThemeData theme) {
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: isDark
            ? Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
            blurRadius: 20, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.school_rounded,
                    size: 28, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(AppStrings.schoolName,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InfoRow(icon: Icons.location_on_outlined,
              text: AppStrings.schoolAddress),
          const SizedBox(height: 12),
          InfoRow(
              icon: Icons.mail_outline_rounded, text: AppStrings.schoolEmail),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: AppStrings.settingsAccessibility,
              child: ElevatedButton.icon(
                onPressed: _openSchoolWebsite,
                icon: const Icon(Icons.language_rounded),
                label: const Text('Visita il sito della scuola'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

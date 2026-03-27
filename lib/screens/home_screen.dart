import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'destination_picker_screen.dart' show Destination, kDestinations;
import 'map_navigation_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
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
      _currentDate = _capitalize(
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

  String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  Future<void> _openSchoolWebsite() async {
    final uri = Uri.parse('https://itiscassino.edu.it/');
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il sito della scuola')),
      );
    }
  }

  void _navigateTo(Destination dest) {
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
                      'Vento ${ws.windSpeed.toStringAsFixed(1)} km/h, '
                      'Umidita ${ws.humidity} percento.',
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
                                  Text('Meteo a Cassino',
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
                              child: Text('${ws.temperature}°C',
                                  style: theme.textTheme.displayLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isCompact ? 40 : 48)),
                            ),
                            Wrap(
                              spacing: 12, runSpacing: 12,
                              children: [
                                _buildWeatherDetail(theme, 'Vento',
                                    '${ws.windSpeed.toStringAsFixed(1)} km/h'),
                                _buildWeatherDetail(
                                    theme, 'Umidita', '${ws.humidity}%'),
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

  Widget _buildWeatherDetail(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
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
                    Text('Navigazione',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Percorso a piedi dalla tua posizione',
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
                  label: 'Vai a Scuola — naviga verso ITIS Biennio',
                  child: _NavDestButton(
                    icon: Icons.school_rounded,
                    label: 'Vai a Scuola',
                    gradient: [cs.primary, cs.secondary],
                    onTap: () => _navigateTo(scuola),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Vai alla Stazione — naviga verso la Stazione Ferroviaria',
                  child: _NavDestButton(
                    icon: Icons.train_rounded,
                    label: 'Vai alla\nStazione',
                    gradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
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
      label: 'Percorso QR. Scansiona i punti lungo il percorso dalla Stazione all ITIS.',
      child: _HomeCard(
        icon: Icons.qr_code_scanner_rounded,
        iconGradient: const [Color(0xFF059669), Color(0xFF34D399)],
        title: 'Percorso QR',
        subtitle: 'Scansiona i 3 punti Stazione — ITIS',
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
      label: 'Trasporti. Orari Trenitalia, COTRAL e Bus Magni. Tocca per aprire.',
      child: _HomeCard(
        icon: Icons.directions_transit_rounded,
        iconGradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
        title: 'Trasporti',
        subtitle: 'Trenitalia · COTRAL · Bus Magni',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransportScreen()),
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
                child: Text('ITIS E. Majorana',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(theme, Icons.location_on_outlined,
              'Via S. Angelo, 2 - 03043 Cassino'),
          const SizedBox(height: 12),
          _buildInfoRow(
              theme, Icons.mail_outline_rounded, 'frtf020002@istruzione.it'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: 'Visita il sito web della scuola ITIS Majorana',
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

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
      ],
    );
  }
}

class _NavDestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _NavDestButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        // Bordo sottile in dark mode per dare definizione alle card
        border: isDark
            ? Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
            blurRadius: isDark ? 12 : 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: iconGradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.primary, size: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

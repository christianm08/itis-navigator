import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'destination_picker_screen.dart';
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
      debugPrint('⚠️ Errore GPS: $e');
    }
    try { await weatherService.fetchWeather(); } catch (e) {
      debugPrint('⚠️ Errore meteo: $e');
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
                  Text(_getGreeting(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
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
                child: Center(child: CircularProgressIndicator(color: Colors.white)))
            : LayoutBuilder(builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                return Semantics(
                  label: 'Meteo a Cassino: ${ws.description}, ${ws.temperature} gradi. '
                      'Vento ${ws.windSpeed.toStringAsFixed(1)} km/h, '
                      'Umidità ${ws.humidity} percento.',
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
                                maxWidth: isCompact ? constraints.maxWidth : constraints.maxWidth * 0.62,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Meteo a Cassino',
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(ws.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9))),
                                ],
                              ),
                            ),
                            Text(ws.icon, style: TextStyle(fontSize: isCompact ? 48 : 64)),
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
                                  style: theme.textTheme.displayLarge?.copyWith(
                                      color: Colors.white, fontWeight: FontWeight.bold,
                                      fontSize: isCompact ? 40 : 48)),
                            ),
                            Wrap(
                              spacing: 12, runSpacing: 12,
                              children: [
                                _buildWeatherDetail(theme, 'Vento', '${ws.windSpeed.toStringAsFixed(1)} km/h'),
                                _buildWeatherDetail(theme, 'Umidità', '${ws.humidity}%'),
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
          Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(ThemeData theme) {
    return Semantics(
      button: true,
      label: 'Inizia navigazione. Tocca per scegliere la destinazione.',
      child: _HomeCard(
        icon: Icons.navigation_rounded,
        iconGradient: [theme.colorScheme.primary, theme.colorScheme.secondary],
        title: 'Inizia Navigazione',
        subtitle: 'Scegli la tua destinazione a Cassino',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DestinationPickerScreen()),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school_rounded, size: 28),
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
          _buildInfoRow(theme, Icons.mail_outline_rounded,
              'frtf020002@istruzione.it'),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
        ),
      ],
    );
  }
}

/// Card riusabile per la home
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20, offset: const Offset(0, 10),
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
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

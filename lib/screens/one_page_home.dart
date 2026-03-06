import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/weather_service.dart';
import 'map_screen.dart';



class OnePageHomeScreen extends StatefulWidget {
  const OnePageHomeScreen({super.key});

  @override
  State<OnePageHomeScreen> createState() => _OnePageHomeScreenState();
}

class _OnePageHomeScreenState extends State<OnePageHomeScreen> {
  final WeatherService _weather = WeatherService();
  late final Stream<DateTime> _clock;

  @override
  void initState() {
    super.initState();
    _clock = Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            title: const Text('ITIS Navigator'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _WarmHero(theme: theme),
                  const SizedBox(height: 14),

                  // Ora/Data
                  Card(
                    color: cs.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: StreamBuilder<DateTime>(
                        stream: _clock,
                        builder: (context, snap) {
                          final now = snap.data ?? DateTime.now();
                          final time = DateFormat('HH:mm:ss', 'it_IT').format(now);
                          final date = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(now);

                          return Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                child: const Icon(Icons.schedule),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      time,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      date,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onPrimaryContainer.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Meteo
                  FutureBuilder<Map<String, dynamic>>(
                    future: _weather.getWeatherForCassino(),
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const _LoadingCard(
                          icon: Icons.wb_sunny,
                          title: 'Meteo',
                          subtitle: 'Caricamento…',
                        );
                      }
                      if (snap.hasError) {
                        return _ErrorCard(
                          icon: Icons.cloud_off,
                          title: 'Meteo',
                          subtitle: 'Errore. Tocca per riprovare.',
                          onTap: () => setState(() {}),
                        );
                      }

                      final w = snap.data!;
                      return Card(
                        color: cs.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: cs.tertiary,
                                foregroundColor: cs.onTertiary,
                                child: const Icon(Icons.wb_sunny),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Meteo a Cassino',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: cs.onTertiaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${w['temperature']}°C • ${w['description']}',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: cs.onTertiaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vento ${w['windSpeed']} km/h • Umidità ${w['humidity']}%',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onTertiaryContainer.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Aggiorna',
                                onPressed: () => setState(() {}),
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Tasto mappa → chiede destinazione
                  Card(
                    color: cs.secondaryContainer,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => _openMapMenu(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.secondary,
                              foregroundColor: cs.onSecondary,
                              child: const Icon(Icons.map),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mappa',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dove vuoi andare? ITIS o Stazione',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSecondaryContainer.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Trasporti (placeholder)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => _openTransportPlaceholder(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.errorContainer,
                              foregroundColor: cs.onErrorContainer,
                              child: const Icon(Icons.directions_bus),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trasporti',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Placeholder: qui integreremo le API (Cotral).',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'WIP',
                                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  Text(
                    'Tocca le card per aprire azioni e dettagli.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMapMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Dove vuoi andare?', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('All’ITIS (Triennio)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(from: RoutePoint.station, to: RoutePoint.itisTriennio),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('All’ITIS (Biennio)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(from: RoutePoint.station, to: RoutePoint.itisBiennio),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.train),
                title: const Text('Alla Stazione'),
                subtitle: const Text('Partenza: ITIS (Triennio)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(from: RoutePoint.itisTriennio, to: RoutePoint.station),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTransportPlaceholder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Trasporti', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: Icon(Icons.construction),
                title: Text('Integrazione API in arrivo'),
                subtitle: Text('Qui inseriremo orari/arrivi bus (Cotral).'),
              ),
              const SizedBox(height: 6),
              const FilledButton(
                onPressed: null,
                child: Text('Configura API (placeholder)'),
              )
            ],
          ),
        );
      },
    );
  }
}

class _WarmHero extends StatelessWidget {
  final ThemeData theme;
  const _WarmHero({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.onPrimary.withOpacity(0.18),
            foregroundColor: cs.onPrimary,
            child: const Icon(Icons.favorite),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ciao! Ti accompagno tra Stazione e ITIS con info utili e una mappa semplice.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LoadingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ErrorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.refresh),
      ),
    );
  }
}

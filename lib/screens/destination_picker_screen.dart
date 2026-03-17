import 'package:flutter/material.dart';
import 'map_navigation_screen.dart';

class Destination {
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final double latitude;
  final double longitude;

  const Destination({
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.latitude,
    required this.longitude,
  });
}

const List<Destination> kDestinations = [
  Destination(
    name: 'ITIS — Sede Biennio',
    description: 'Via S. Angelo 2',
    category: 'Scuola',
    icon: Icons.school_rounded,
    latitude: 41.4688333,
    longitude: 13.8341111,
  ),
  Destination(
    name: 'ITIS — Sede Triennio',
    description: 'Via S. Angelo 4',
    category: 'Scuola',
    icon: Icons.school_rounded,
    latitude: 41.46905,
    longitude: 13.83385,
  ),
  Destination(
    name: 'Stazione Ferroviaria',
    description: 'Piazzale Ferrovia',
    category: 'Trasporti',
    icon: Icons.train_rounded,
    latitude: 41.4842329,
    longitude: 13.8322095,
  ),
  Destination(
    name: 'Deposito Cotral',
    description: 'Viale Garigliano Via Volturno',
    category: 'Trasporti',
    icon: Icons.directions_bus_rounded,
    latitude: 41.4855114,
    longitude: 13.8369294,
  ),
];

class DestinationPickerScreen extends StatelessWidget {
  const DestinationPickerScreen({super.key});

  void _go(BuildContext context, Destination dest) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MapNavigationScreen(destination: dest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scuola = kDestinations.firstWhere((d) => d.name.contains('Biennio'));
    final stazione = kDestinations.firstWhere((d) => d.name.contains('Stazione'));

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
              bottom: 32,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dove vuoi andare?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scegli la destinazione',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),

          // Bottoni
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: _DestButton(
                      icon: Icons.school_rounded,
                      label: 'Scuola',
                      sublabel: scuola.description,
                      gradient: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      onTap: () => _go(context, scuola),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _DestButton(
                      icon: Icons.train_rounded,
                      label: 'Stazione',
                      sublabel: stazione.description,
                      gradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      onTap: () => _go(context, stazione),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _DestButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$label — $sublabel. Tocca per avviare la navigazione.',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sublabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'trenitalia_screen.dart';
import 'cotral_screen.dart';
import 'magni_screen.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
              bottom: 28,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: 'Torna alla schermata principale',
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  child: Text(
                    'Trasporti',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ExcludeSemantics(
                  child: Text(
                    'Orari dei mezzi da e per Cassino',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _TransportCard(
                  icon: Icons.train_rounded,
                  label: 'Trenitalia',
                  subtitle: 'Treni Cassino ↔ Roma / Napoli',
                  color: const Color(0xFF009944),
                  semanticLabel:
                      'Trenitalia. Orari treni Cassino per Roma e Napoli. Tocca due volte per aprire.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrenitaliaScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _TransportCard(
                  icon: Icons.directions_bus_rounded,
                  label: 'COTRAL',
                  subtitle: 'Bus regionali Lazio — area Cassino',
                  color: const Color(0xFF1565C0),
                  semanticLabel:
                      'COTRAL. Bus regionali del Lazio area Cassino. Tocca due volte per aprire.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CotrAlScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _TransportCard(
                  icon: Icons.airport_shuttle_rounded,
                  label: 'Bus Magni',
                  subtitle: 'Servizio urbano ed extraurbano Cassino',
                  color: const Color(0xFFE65100),
                  semanticLabel:
                      'Bus Magni. Servizio urbano ed extraurbano di Cassino. Tocca due volte per aprire.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MagniScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String semanticLabel;
  final VoidCallback onTap;

  const _TransportCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: color, size: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

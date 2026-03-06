import 'package:flutter/material.dart';
import 'glass_card.dart';

class NavigationBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final String transportMode;
  final VoidCallback onRecenter;

  const NavigationBottomSheet({
    super.key,
    required this.scrollController,
    required this.transportMode,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getTransportIcon(),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransportTitle(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verso ITIS E. Majorana',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  theme,
                  Icons.straighten_rounded,
                  'Distanza',
                  _getDistance(),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  theme,
                  Icons.access_time_rounded,
                  'Tempo',
                  _getDuration(),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepsList(theme, isDark),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRecenter,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.my_location_rounded),
                const SizedBox(width: 8),
                Text(
                  'Ricentra Mappa',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(ThemeData theme, bool isDark) {
    final steps = _getSteps();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicazioni',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < steps.length - 1 ? 12 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getTransportIcon() {
    switch (transportMode) {
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      default:
        return Icons.navigation_rounded;
    }
  }

  String _getTransportTitle() {
    switch (transportMode) {
      case 'walking':
        return 'A Piedi';
      case 'bus':
        return 'In Autobus';
      case 'car':
        return 'In Auto';
      default:
        return 'Navigazione';
    }
  }

  String _getDistance() {
    switch (transportMode) {
      case 'walking':
        return '1.2 km';
      case 'bus':
        return '2.1 km';
      case 'car':
        return '1.8 km';
      default:
        return '1.5 km';
    }
  }

  String _getDuration() {
    switch (transportMode) {
      case 'walking':
        return '15 min';
      case 'bus':
        return '8 min';
      case 'car':
        return '5 min';
      default:
        return '10 min';
    }
  }

  List<String> _getSteps() {
    switch (transportMode) {
      case 'walking':
        return [
          'Parti dalla Stazione di Cassino',
          'Prosegui su Via Vittorio Veneto per 400m',
          'Svolta a destra in Via Giuseppe Verdi',
          'Arrivo all\'ITIS E. Majorana',
        ];
      case 'bus':
        return [
          'Prendi l\'autobus linea 1 dalla stazione',
          'Scendi alla fermata "ITIS Majorana"',
          'Cammina per 100m fino all\'ingresso',
        ];
      case 'car':
        return [
          'Esci dal parcheggio della stazione',
          'Imbocca Via Casilina Nord',
          'Svolta in Via Giuseppe Verdi',
          'Arrivo con parcheggio disponibile',
        ];
      default:
        return [
          'Segui le indicazioni sulla mappa',
          'Mantieni la direzione indicata',
        ];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:url_launcher/url_launcher.dart';

class _Train {
  final String departureTime;
  final String arrivalTime;
  final String from;
  final String to;
  final String type;
  final String notes;

  const _Train({
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.type,
    this.notes = '',
  });
}

const _kTrains = [
  _Train(departureTime: '05:48', arrivalTime: '07:48', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '06:17', arrivalTime: '08:20', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '06:55', arrivalTime: '08:52', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '07:24', arrivalTime: '09:22', from: 'Cassino', to: 'Roma Termini', type: 'RV', notes: 'Feriale'),
  _Train(departureTime: '12:17', arrivalTime: '14:15', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '13:20', arrivalTime: '15:22', from: 'Cassino', to: 'Roma Termini', type: 'RV', notes: 'Feriale'),
  _Train(departureTime: '14:17', arrivalTime: '16:18', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '16:17', arrivalTime: '18:17', from: 'Cassino', to: 'Roma Termini', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '14:05', arrivalTime: '16:05', from: 'Roma Termini', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '16:05', arrivalTime: '18:05', from: 'Roma Termini', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '17:05', arrivalTime: '19:05', from: 'Roma Termini', to: 'Cassino', type: 'RV', notes: 'Feriale'),
  _Train(departureTime: '18:05', arrivalTime: '20:05', from: 'Roma Termini', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '19:05', arrivalTime: '21:05', from: 'Roma Termini', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '06:10', arrivalTime: '07:45', from: 'Cassino', to: 'Napoli Centrale', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '07:10', arrivalTime: '08:45', from: 'Cassino', to: 'Napoli Centrale', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '13:10', arrivalTime: '14:45', from: 'Cassino', to: 'Napoli Centrale', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '17:10', arrivalTime: '18:45', from: 'Cassino', to: 'Napoli Centrale', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '06:15', arrivalTime: '08:00', from: 'Napoli Centrale', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '13:15', arrivalTime: '15:00', from: 'Napoli Centrale', to: 'Cassino', type: 'R',  notes: 'Feriale'),
  _Train(departureTime: '17:15', arrivalTime: '19:00', from: 'Napoli Centrale', to: 'Cassino', type: 'RV', notes: 'Feriale'),
  _Train(departureTime: '18:15', arrivalTime: '20:00', from: 'Napoli Centrale', to: 'Cassino', type: 'R',  notes: 'Feriale'),
];

class TrenitaliaScreen extends StatefulWidget {
  const TrenitaliaScreen({super.key});
  @override
  State<TrenitaliaScreen> createState() => _TrenitaliaScreenState();
}

class _TrenitaliaScreenState extends State<TrenitaliaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _tabs = [
    'Cassino → Roma',
    'Roma → Cassino',
    'Cassino → Napoli',
    'Napoli → Cassino',
  ];
  static const _routes = [
    ('Cassino', 'Roma Termini'),
    ('Roma Termini', 'Cassino'),
    ('Cassino', 'Napoli Centrale'),
    ('Napoli Centrale', 'Cassino'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Orari Trenitalia. Seleziona una direzione con le schede in alto.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_Train> _trainsForTab(int i) {
    final (from, to) = _routes[i];
    return _kTrains
        .where((t) => t.from == from && t.to == to)
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  String? _nextTrain(int tabIndex) {
    final now = TimeOfDay.now();
    for (final t in _trainsForTab(tabIndex)) {
      final parts = t.departureTime.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h > now.hour || (h == now.hour && m > now.minute)) return t.departureTime;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const brandColor = Color(0xFF009944);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20, right: 20, bottom: 0,
            ),
            color: brandColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Torna ai trasporti',
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      header: true,
                      child: Text('Trenitalia',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  onTap: (i) {
                    final next = _nextTrain(i);
                    SemanticsService.announce(
                      next != null
                          ? '${_tabs[i]}. Prossimo treno alle $next.'
                          : '${_tabs[i]}. Nessun altro treno oggi.',
                      TextDirection.ltr,
                    );
                  },
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: List.generate(
                _tabs.length,
                (i) => _TrainList(trains: _trainsForTab(i), nextTime: _nextTrain(i)),
              ),
            ),
          ),
          _BottomSection(
            officialUrl: 'https://www.trenitalia.com',
            buttonLabel: 'Apri sito Trenitalia',
            buttonSemanticLabel:
                'Apri il sito ufficiale di Trenitalia per gli orari in tempo reale',
            brandColor: brandColor,
          ),
        ],
      ),
    );
  }
}

class _TrainList extends StatelessWidget {
  final List<_Train> trains;
  final String? nextTime;
  const _TrainList({required this.trains, this.nextTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const brandColor = Color(0xFF009944);

    if (trains.isEmpty) {
      return Center(
        child: Text('Nessuna corsa disponibile',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: trains.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = trains[i];
        final isNext = t.departureTime == nextTime;
        return Semantics(
          label: '${isNext ? 'Prossimo treno. ' : ''}'
              'Partenza ${t.departureTime}, arrivo ${t.arrivalTime}. '
              'Tipo: ${t.type == 'RV' ? 'Regionale Veloce' : 'Regionale'}. '
              '${t.notes}.',
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isNext
                    ? brandColor.withValues(alpha: isDark ? 0.18 : 0.10)
                    : cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNext
                      ? brandColor
                      : cs.onSurface.withValues(alpha: isDark ? 0.14 : 0.12),
                  width: isNext ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.departureTime,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNext ? brandColor : cs.onSurface,
                          )),
                      const SizedBox(height: 2),
                      Text('→ ${t.arrivalTime}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.type == 'RV'
                                ? const Color(0xFF1565C0).withValues(alpha: isDark ? 0.25 : 0.12)
                                : cs.onSurface.withValues(alpha: isDark ? 0.12 : 0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t.type == 'RV' ? 'Regionale Veloce' : 'Regionale',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: t.type == 'RV'
                                  ? (isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0))
                                  : cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        if (t.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(t.notes,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.45))),
                        ],
                      ],
                    ),
                  ),
                  if (isNext)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: brandColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Prossimo',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomSection extends StatelessWidget {
  final String officialUrl;
  final String buttonLabel;
  final String buttonSemanticLabel;
  final Color brandColor;

  const _BottomSection({
    required this.officialUrl,
    required this.buttonLabel,
    required this.buttonSemanticLabel,
    required this.brandColor,
  });

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(officialUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il sito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: false,
            label: 'Nota: gli orari sono indicativi e soggetti a variazioni. '
                'Verifica sempre sul sito ufficiale.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.shade900.withValues(alpha: 0.25)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? Colors.amber.shade700 : Colors.amber.shade300),
              ),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18,
                        color: isDark ? Colors.amber.shade400 : Colors.amber.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gli orari sono indicativi e soggetti a variazioni. '
                        'Verifica sempre sul sito ufficiale.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            button: true,
            label: buttonSemanticLabel,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _launch(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

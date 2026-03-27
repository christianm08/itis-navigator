import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class _Bus {
  final String time;
  final String line;
  final String from;
  final String to;
  final String notes;

  const _Bus({
    required this.time,
    required this.line,
    required this.from,
    required this.to,
    this.notes = '',
  });
}

const _kBuses = [
  _Bus(time: '06:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '07:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '08:15', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '13:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '14:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '16:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '18:00', line: 'Cassino–Frosinone', from: 'Cassino', to: 'Frosinone', notes: 'Feriale'),
  _Bus(time: '06:30', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '07:30', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '09:00', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '13:30', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '15:00', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '17:00', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '19:00', line: 'Frosinone–Cassino', from: 'Frosinone', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '06:45', line: 'Cassino–Sora', from: 'Cassino', to: 'Sora', notes: 'Feriale'),
  _Bus(time: '12:45', line: 'Cassino–Sora', from: 'Cassino', to: 'Sora', notes: 'Feriale'),
  _Bus(time: '17:45', line: 'Cassino–Sora', from: 'Cassino', to: 'Sora', notes: 'Feriale'),
  _Bus(time: '07:30', line: 'Sora–Cassino', from: 'Sora', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '13:30', line: 'Sora–Cassino', from: 'Sora', to: 'Cassino', notes: 'Feriale'),
  _Bus(time: '18:30', line: 'Sora–Cassino', from: 'Sora', to: 'Cassino', notes: 'Feriale'),
];

class CotrAlScreen extends StatefulWidget {
  const CotrAlScreen({super.key});
  @override
  State<CotrAlScreen> createState() => _CotrAlScreenState();
}

class _CotrAlScreenState extends State<CotrAlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    'Cassino → Frosinone',
    'Frosinone → Cassino',
    'Cassino → Sora',
    'Sora → Cassino',
  ];
  static const _routes = [
    ('Cassino', 'Frosinone'),
    ('Frosinone', 'Cassino'),
    ('Cassino', 'Sora'),
    ('Sora', 'Cassino'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Orari COTRAL. Seleziona una direzione con le schede in alto.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_Bus> _busesForTab(int i) {
    final (from, to) = _routes[i];
    return _kBuses.where((b) => b.from == from && b.to == to).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  String? _nextBus(int tabIndex) {
    final now = TimeOfDay.now();
    for (final b in _busesForTab(tabIndex)) {
      final parts = b.time.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h > now.hour || (h == now.hour && m > now.minute)) return b.time;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const brandColor = Color(0xFF1565C0);

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
                      child: Text('COTRAL',
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
                    final next = _nextBus(i);
                    SemanticsService.announce(
                      next != null
                          ? '${_tabs[i]}. Prossimo bus alle $next.'
                          : '${_tabs[i]}. Nessun altro bus oggi.',
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
                (i) => _BusList(
                  buses: _busesForTab(i),
                  nextTime: _nextBus(i),
                  brandColor: brandColor,
                ),
              ),
            ),
          ),
          _BottomSection(
            officialUrl: 'https://www.cotralspa.it',
            buttonLabel: 'Apri sito COTRAL',
            buttonSemanticLabel:
                'Apri il sito ufficiale COTRAL per gli orari in tempo reale',
            brandColor: brandColor,
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.shade900.withValues(alpha: 0.25)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? Colors.amber.shade700 : Colors.amber.shade300),
            ),
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
                onPressed: () {},
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

class _BusList extends StatelessWidget {
  final List<_Bus> buses;
  final String? nextTime;
  final Color brandColor;
  const _BusList({required this.buses, this.nextTime, required this.brandColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (buses.isEmpty) {
      return Center(
        child: Text('Nessuna corsa disponibile',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: buses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final b = buses[i];
        final isNext = b.time == nextTime;
        return Semantics(
          label: '${isNext ? 'Prossimo bus. ' : ''}'
              'Partenza ${b.time}. Linea ${b.line}. ${b.notes}.',
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isNext
                    ? brandColor.withValues(alpha: isDark ? 0.18 : 0.08)
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
                  Text(b.time,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNext ? brandColor : cs.onSurface,
                      )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.line,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        if (b.notes.isNotEmpty)
                          Text(b.notes,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.45))),
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
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
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

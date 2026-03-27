import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:url_launcher/url_launcher.dart';

class _BusRun {
  final String time;
  final String line;
  final String direction;
  final String notes;

  const _BusRun({
    required this.time,
    required this.line,
    required this.direction,
    this.notes = '',
  });
}

const _kRuns = [
  _BusRun(time: '06:50', line: 'Linea 1', direction: 'Stazione → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '07:20', line: 'Linea 1', direction: 'Stazione → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '07:50', line: 'Linea 1', direction: 'Stazione → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '08:10', line: 'Linea 1', direction: 'Stazione → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '13:10', line: 'Linea 1', direction: 'ITIS → Stazione', notes: 'Feriale scolastico'),
  _BusRun(time: '14:10', line: 'Linea 1', direction: 'ITIS → Stazione', notes: 'Feriale scolastico'),
  _BusRun(time: '16:10', line: 'Linea 1', direction: 'ITIS → Stazione', notes: 'Feriale scolastico'),
  _BusRun(time: '17:10', line: 'Linea 1', direction: 'ITIS → Stazione', notes: 'Feriale scolastico'),
  _BusRun(time: '07:00', line: 'Linea 2', direction: 'Centro → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '07:40', line: 'Linea 2', direction: 'Centro → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '08:00', line: 'Linea 2', direction: 'Centro → ITIS', notes: 'Feriale scolastico'),
  _BusRun(time: '13:05', line: 'Linea 2', direction: 'ITIS → Centro', notes: 'Feriale scolastico'),
  _BusRun(time: '14:05', line: 'Linea 2', direction: 'ITIS → Centro', notes: 'Feriale scolastico'),
  _BusRun(time: '16:05', line: 'Linea 2', direction: 'ITIS → Centro', notes: 'Feriale scolastico'),
];

class MagniScreen extends StatefulWidget {
  const MagniScreen({super.key});
  @override
  State<MagniScreen> createState() => _MagniScreenState();
}

class _MagniScreenState extends State<MagniScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    'Stazione → ITIS',
    'ITIS → Stazione',
    'Centro → ITIS',
    'ITIS → Centro',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Orari Bus Magni. Seleziona una direzione con le schede in alto.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_BusRun> _runsForTab(int i) {
    final dir = _tabs[i];
    return _kRuns
        .where((r) => r.direction == dir)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  String? _nextRun(int tabIndex) {
    final now = TimeOfDay.now();
    for (final r in _runsForTab(tabIndex)) {
      final parts = r.time.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h > now.hour || (h == now.hour && m > now.minute)) return r.time;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const brandColor = Color(0xFFE65100);

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
                      child: Text('Bus Magni',
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
                    final next = _nextRun(i);
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
                (i) => _RunList(
                  runs: _runsForTab(i),
                  nextTime: _nextRun(i),
                  brandColor: brandColor,
                ),
              ),
            ),
          ),
          _BottomSection(
            officialUrl: 'tel:+390776301472',
            buttonLabel: 'Chiama Autolinee Magni',
            buttonSemanticLabel:
                'Chiama Autolinee Magni per informazioni sugli orari',
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

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(officialUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile effettuare la chiamata')),
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
                    'Verifica sempre con Autolinee Magni.',
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
                onPressed: () => _launch(context),
                icon: const Icon(Icons.phone_rounded),
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

class _RunList extends StatelessWidget {
  final List<_BusRun> runs;
  final String? nextTime;
  final Color brandColor;
  const _RunList({required this.runs, this.nextTime, required this.brandColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (runs.isEmpty) {
      return Center(
        child: Text('Nessuna corsa disponibile',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: runs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = runs[i];
        final isNext = r.time == nextTime;
        return Semantics(
          label: '${isNext ? 'Prossima corsa. ' : ''}'
              'Partenza ${r.time}. ${r.line}, direzione ${r.direction}. ${r.notes}.',
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
                  Text(r.time,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNext ? brandColor : cs.onSurface,
                      )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.line,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600, color: brandColor)),
                        Text(r.direction,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6))),
                        if (r.notes.isNotEmpty)
                          Text(r.notes,
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

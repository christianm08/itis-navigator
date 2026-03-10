import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

/// Destinazioni esterne a Cassino verso cui navigare a piedi
const List<Destination> kDestinations = [
  // --- Scuola ---
  Destination(
    name: 'ITIS E. Majorana',
    description: 'Ingresso principale, Via S. Angelo 2',
    category: 'Scuola',
    icon: Icons.school_rounded,
    latitude: 41.4688333,
    longitude: 13.8341111,
  ),
  Destination(
    name: 'ITIS — Ingresso Secondario',
    description: 'Entrata laterale lato parcheggio',
    category: 'Scuola',
    icon: Icons.door_sliding_rounded,
    latitude: 41.46905,
    longitude: 13.83385,
  ),

  // --- Trasporti ---
  Destination(
    name: 'Stazione Ferroviaria',
    description: 'Cassino FS — Piazzale della Stazione',
    category: 'Trasporti',
    icon: Icons.train_rounded,
    latitude: 41.47630,
    longitude: 13.83150,
  ),
  Destination(
    name: 'Autostazione',
    description: 'Terminal bus interurbani, Via G. Marconi',
    category: 'Trasporti',
    icon: Icons.directions_bus_rounded,
    latitude: 41.47550,
    longitude: 13.83050,
  ),
  Destination(
    name: 'Fermata Bus Scuola',
    description: 'Fermata più vicina all\'ITIS su Via S. Angelo',
    category: 'Trasporti',
    icon: Icons.bus_alert_rounded,
    latitude: 41.46950,
    longitude: 13.83300,
  ),

  // --- Città ---
  Destination(
    name: 'Piazza Diamare',
    description: 'Piazza principale del centro storico di Cassino',
    category: 'Città',
    icon: Icons.location_city_rounded,
    latitude: 41.48900,
    longitude: 13.82900,
  ),
  Destination(
    name: 'Ospedale S. Scolastica',
    description: 'Pronto soccorso e ospedale civile di Cassino',
    category: 'Città',
    icon: Icons.local_hospital_rounded,
    latitude: 41.48100,
    longitude: 13.82600,
  ),
  Destination(
    name: 'Biblioteca Comunale',
    description: 'Biblioteca pubblica "G. Salvadori", Via G. Di Biasio',
    category: 'Città',
    icon: Icons.menu_book_rounded,
    latitude: 41.48700,
    longitude: 13.82800,
  ),
  Destination(
    name: 'Comune di Cassino',
    description: 'Municipio, Piazza Labriola',
    category: 'Città',
    icon: Icons.account_balance_rounded,
    latitude: 41.48750,
    longitude: 13.82950,
  ),
  Destination(
    name: 'Centro Commerciale Ikea / Retail Park',
    description: 'Via Interamnia, zona commerciale nord',
    category: 'Città',
    icon: Icons.shopping_bag_rounded,
    latitude: 41.50200,
    longitude: 13.83500,
  ),

  // --- Università ---
  Destination(
    name: 'Università di Cassino',
    description: 'Campus UniCassino, Via G. Di Biasio 43',
    category: 'Università',
    icon: Icons.account_balance_rounded,
    latitude: 41.48550,
    longitude: 13.82750,
  ),
];

class DestinationPickerScreen extends StatefulWidget {
  const DestinationPickerScreen({super.key});

  @override
  State<DestinationPickerScreen> createState() =>
      _DestinationPickerScreenState();
}

class _DestinationPickerScreenState extends State<DestinationPickerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Destination> _filtered = kDestinations;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      SemanticsService.announce(
        'Schermata selezione destinazione. '
        'Sono disponibili ${kDestinations.length} destinazioni. '
        'Usa il campo di ricerca per filtrare, '
        'o scorri la lista per scegliere.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _query = query.toLowerCase();
      _filtered = kDestinations.where((d) {
        return d.name.toLowerCase().contains(_query) ||
            d.description.toLowerCase().contains(_query) ||
            d.category.toLowerCase().contains(_query);
      }).toList();
    });
    final count = _filtered.length;
    SemanticsService.announce(
      count == 0
          ? 'Nessuna destinazione trovata per "$query"'
          : '$count destinazion${count == 1 ? 'e trovata' : 'i trovate'} per "$query"',
      TextDirection.ltr,
    );
  }

  void _selectDestination(Destination dest) {
    SemanticsService.announce(
      'Avvio navigazione verso ${dest.name}. ${dest.description}',
      TextDirection.ltr,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MapNavigationScreen(destination: dest),
      ),
    );
  }

  Map<String, List<Destination>> get _grouped {
    final map = <String, List<Destination>>{};
    for (final d in _filtered) {
      map.putIfAbsent(d.category, () => []).add(d);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _grouped;
    final hasResults = _filtered.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          Semantics(
            header: true,
            child: Container(
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
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(
                      'Dove vuoi andare?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: Text(
                      'Scegli la destinazione a Cassino',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    textField: true,
                    label: 'Cerca destinazione',
                    hint: 'Scrivi stazione, scuola, ospedale…',
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: _onSearch,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF1F2937)),
                      decoration: InputDecoration(
                        hintText: 'Cerca stazione, scuola, ospedale…',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFF6B7280)),
                        suffixIcon: _query.isNotEmpty
                            ? Semantics(
                                button: true,
                                label: 'Cancella ricerca',
                                child: IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: Color(0xFF6B7280)),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onSearch('');
                                  },
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: hasResults
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    itemCount: _buildItems(grouped).length,
                    itemBuilder: (_, i) => _buildItems(grouped)[i],
                  )
                : Semantics(
                    liveRegion: true,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('Nessuna destinazione trovata',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text('Prova con un termine diverso',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(Map<String, List<Destination>> grouped) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    for (final entry in grouped.entries) {
      items.add(Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 6),
          child: Text(
            entry.key,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ));
      for (final dest in entry.value) {
        items.add(_DestinationTile(
          destination: dest,
          onTap: () => _selectDestination(dest),
        ));
      }
    }
    return items;
  }
}

class _DestinationTile extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationTile({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${destination.name}, ${destination.category}. '
          '${destination.description}. '
          'Tocca due volte per avviare la navigazione.',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(destination.icon,
                          color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            destination.description,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary, size: 28),
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

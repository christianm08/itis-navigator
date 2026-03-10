import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'map_navigation_screen.dart';

/// Destinazione interna all'ITIS Majorana
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

/// Tutte le destinazioni disponibili nell'ITIS E. Majorana di Cassino
const List<Destination> kDestinations = [
  // Ingressi
  Destination(
    name: 'Ingresso Principale',
    description: 'Entrata principale su Via S. Angelo',
    category: 'Ingressi',
    icon: Icons.door_front_door_rounded,
    latitude: 41.4688333,
    longitude: 13.8341111,
  ),
  Destination(
    name: 'Ingresso Secondario',
    description: 'Entrata laterale lato parcheggio',
    category: 'Ingressi',
    icon: Icons.door_sliding_rounded,
    latitude: 41.4690000,
    longitude: 13.8338000,
  ),
  // Uffici
  Destination(
    name: 'Segreteria',
    description: 'Ufficio segreteria studenti, piano terra',
    category: 'Uffici',
    icon: Icons.admin_panel_settings_rounded,
    latitude: 41.4688500,
    longitude: 13.8341500,
  ),
  Destination(
    name: 'Presidenza',
    description: 'Ufficio del Dirigente Scolastico, primo piano',
    category: 'Uffici',
    icon: Icons.business_rounded,
    latitude: 41.4688700,
    longitude: 13.8341800,
  ),
  // Aule
  Destination(
    name: 'Aule Piano Terra',
    description: 'Aule 1A – 1F, piano terra ala nord',
    category: 'Aule',
    icon: Icons.class_rounded,
    latitude: 41.4689000,
    longitude: 13.8342000,
  ),
  Destination(
    name: 'Aule Primo Piano',
    description: 'Aule 2A – 2F, primo piano',
    category: 'Aule',
    icon: Icons.class_rounded,
    latitude: 41.4689200,
    longitude: 13.8342200,
  ),
  Destination(
    name: 'Aule Secondo Piano',
    description: 'Aule 3A – 3F, secondo piano',
    category: 'Aule',
    icon: Icons.class_rounded,
    latitude: 41.4689400,
    longitude: 13.8342400,
  ),
  // Laboratori
  Destination(
    name: 'Laboratorio Informatica',
    description: 'Lab. informatica con PC, piano terra ala sud',
    category: 'Laboratori',
    icon: Icons.computer_rounded,
    latitude: 41.4688000,
    longitude: 13.8343000,
  ),
  Destination(
    name: 'Laboratorio Elettronica',
    description: 'Lab. elettronica e sistemi, primo piano',
    category: 'Laboratori',
    icon: Icons.electrical_services_rounded,
    latitude: 41.4688200,
    longitude: 13.8343200,
  ),
  Destination(
    name: 'Laboratorio Chimica',
    description: 'Lab. chimica e scienze, piano terra',
    category: 'Laboratori',
    icon: Icons.science_rounded,
    latitude: 41.4688400,
    longitude: 13.8343400,
  ),
  // Servizi
  Destination(
    name: 'Biblioteca',
    description: 'Biblioteca scolastica, piano terra',
    category: 'Servizi',
    icon: Icons.menu_book_rounded,
    latitude: 41.4689600,
    longitude: 13.8340000,
  ),
  Destination(
    name: 'Palestra',
    description: 'Palestra e spogliatoi, piano seminterrato',
    category: 'Servizi',
    icon: Icons.sports_gymnastics,
    latitude: 41.4687000,
    longitude: 13.8340500,
  ),
  Destination(
    name: 'Mensa / Bar',
    description: 'Bar scolastico e area ristoro, piano terra',
    category: 'Servizi',
    icon: Icons.local_cafe_rounded,
    latitude: 41.4689800,
    longitude: 13.8341000,
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
    // Autofocus per screen reader: il cursore va subito sul campo di ricerca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      // Annuncio vocale iniziale per screen reader
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

    // Annuncio risultati per screen reader
    final count = _filtered.length;
    SemanticsService.announce(
      count == 0
          ? 'Nessuna destinazione trovata per "$query"'
          : '$count destinazion${count == 1 ? "e trovata" : "i trovate"} per "$query"',
      TextDirection.ltr,
    );
  }

  void _selectDestination(Destination dest) {
    // Annuncio selezione per screen reader
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

  // Raggruppa per categoria mantenendo l'ordine originale
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
          // Header con gradiente
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
                  // Back button
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
                      'Scegli la tua destinazione all\'ITIS',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo ricerca
                  Semantics(
                    textField: true,
                    label: 'Cerca destinazione',
                    hint: 'Scrivi il nome di un\'aula, laboratorio o ufficio',
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: _onSearch,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cerca aula, laboratorio, ufficio…',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF6B7280),
                        ),
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
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista destinazioni
          Expanded(
            child: hasResults
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    itemCount: _buildItems(grouped).length,
                    itemBuilder: (context, index) =>
                        _buildItems(grouped)[index],
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
                          Text(
                            'Nessuna destinazione trovata',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prova con un termine diverso',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Costruisce la lista flat con header di categoria + tile destinazioni
  List<Widget> _buildItems(Map<String, List<Destination>> grouped) {
    final theme = Theme.of(context);
    final items = <Widget>[];

    for (final entry in grouped.entries) {
      // Header categoria
      items.add(
        Semantics(
          header: true,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 12, bottom: 6),
            child: Text(
              entry.key,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      );

      // Tile per ogni destinazione
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

/// Tile accessibile per una singola destinazione
class _DestinationTile extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      // Label completo letto dallo screen reader in un unico annuncio
      label: '\'${destination.name}\', ${destination.category}. '
          '${destination.description}. '
          'Tocca due volte per avviare la navigazione.',
      child: ExcludeSemantics(
        // ExcludeSemantics evita duplicazioni nei figli
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
                // Altezza minima 64px per accessibilità motoria (WCAG 2.5.5)
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
                    // Icona categoria
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        destination.icon,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
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

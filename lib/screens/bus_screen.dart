import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cotral_service.dart';
import '../models/cotral_models.dart';
import 'package:intl/intl.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  String? _selectedPoleCode;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _loadBusData();
    _startAutoRefresh();
  }

  Future<void> _loadBusData() async {
    final cotralService = context.read<CotralService>();
    
    // Carica fermate di Cassino
    await cotralService.getStops('Cassino');
    
    // Se ci sono fermate, carica le paline della prima
    if (cotralService.stops.isNotEmpty) {
      final firstStop = cotralService.stops.first;
      await cotralService.getPoles(firstStop.code);
      
      // Carica i transiti della prima palina
      if (cotralService.poles.isNotEmpty) {
        _selectedPoleCode = cotralService.poles.first.code;
        await cotralService.getTransits(_selectedPoleCode!);
      }
    }
  }

  void _startAutoRefresh() {
    if (_autoRefresh) {
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && _autoRefresh && _selectedPoleCode != null) {
          context.read<CotralService>().getTransits(_selectedPoleCode!);
          _startAutoRefresh();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        title: Text(
          '🚌 Bus Cotral',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _selectedPoleCode != null
                ? context.read<CotralService>().getTransits(_selectedPoleCode!)
                : _loadBusData(),
          ),
        ],
      ),
      body: Consumer<CotralService>(
        builder: (context, service, child) {
          if (service.isLoading && service.currentTransits == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF20B2AA)),
            );
          }

          if (service.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    service.error!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBusData,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedPoleCode != null) {
                await service.getTransits(_selectedPoleCode!);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStopSelector(service),
                const SizedBox(height: 16),
                _buildPoleSelector(service),
                const SizedBox(height: 24),
                if (service.currentTransits != null)
                  _buildTransitsList(service.currentTransits!)
                else
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStopSelector(CotralService service) {
    if (service.stops.isEmpty) {
      return const Card(
        color: Color(0xFF16213E),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nessuna fermata trovata per Cassino',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF16213E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚏 Fermate Cassino',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF20B2AA),
              ),
            ),
            const SizedBox(height: 8),
            ...service.stops.map((stop) => ListTile(
              title: Text(
                stop.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Codice: ${stop.code}',
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
              onTap: () async {
                await service.getPoles(stop.code);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPoleSelector(CotralService service) {
    if (service.poles.isEmpty) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFF16213E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Paline Disponibili',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF20B2AA),
              ),
            ),
            const SizedBox(height: 8),
            ...service.poles.map((pole) => ListTile(
              selected: _selectedPoleCode == pole.code,
              selectedTileColor: const Color(0xFF20B2AA).withOpacity(0.1),
              title: Text(
                pole.name,
                style: TextStyle(
                  color: _selectedPoleCode == pole.code
                      ? const Color(0xFF20B2AA)
                      : Colors.white,
                  fontWeight: _selectedPoleCode == pole.code
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                'Codice: ${pole.code}',
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: const Icon(Icons.schedule, color: Colors.white60),
              onTap: () async {
                setState(() => _selectedPoleCode = pole.code);
                await service.getTransits(pole.code);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitsList(BusTransitResponse response) {
    if (response.transits.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⏱️ Prossimi Bus',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...response.transits.map((transit) => _buildTransitCard(transit)),
      ],
    );
  }

  Widget _buildTransitCard(BusTransit transit) {
    final minutes = transit.getMinutesUntilArrival();
    final isArriving = minutes <= 5;

    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isArriving
                    ? Colors.orange.withOpacity(0.2)
                    : const Color(0xFF20B2AA).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isArriving ? Icons.directions_bus : Icons.schedule,
                color: isArriving ? Colors.orange : const Color(0xFF20B2AA),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transit.routeName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        transit.isRealTime ? Icons.gps_fixed : Icons.access_time,
                        size: 14,
                        color: transit.isRealTime ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transit.isRealTime ? 'Tempo reale' : 'Programmato',
                        style: TextStyle(
                          fontSize: 12,
                          color: transit.isRealTime ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transit.getFormattedArrivalTime(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isArriving ? Colors.orange : const Color(0xFF20B2AA),
                  ),
                ),
                if (transit.delay != '00:00:00')
                  Text(
                    'Ritardo: ${transit.delay}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun bus in arrivo',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seleziona una palina per vedere i transiti',
            style: TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml2js/xml2js.dart' as xml2js;
import '../models/cotral_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CotralService extends ChangeNotifier {
  static const String _baseUrl = 'http://travel.mob.cotralspa.it:7777/beApp';
  static const String _userId = '1BB73DCDAFA007572FC51E7407AB497C';

  bool _isLoading = false;
  String? _error;
  List<BusStop> _stops = [];
  List<BusPole> _poles = [];
  BusTransitResponse? _currentTransits;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BusStop> get stops => _stops;
  List<BusPole> get poles => _poles;
  BusTransitResponse? get currentTransits => _currentTransits;

  // Fermate di Cassino (vicine all'ITIS)
  static const String cassinoStopCode = '70539'; // Codice fermata Cassino

  /// Ottiene tutte le fermate di una località
  Future<List<BusStop>> getStops(String locality) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getStops.asp?userId=$_userId&locality=$locality');
      debugPrint('🚌 Fetching stops for $locality: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);

        _stops = _parseStops(jsonData);
        debugPrint('✅ Found ${_stops.length} stops in $locality');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Errore nel caricamento fermate: $e';
      debugPrint('❌ Error fetching stops: $e');
      _stops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _stops;
  }

  /// Ottiene le paline di una fermata
  Future<List<BusPole>> getPoles(String stopCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getPalina.asp?userId=$_userId&codStop=$stopCode');
      debugPrint('🚏 Fetching poles for stop $stopCode: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);

        _poles = _parsePoles(jsonData);
        debugPrint('✅ Found ${_poles.length} poles for stop $stopCode');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Errore nel caricamento paline: $e';
      debugPrint('❌ Error fetching poles: $e');
      _poles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _poles;
  }

  /// Ottiene i transiti in tempo reale per una palina
  Future<BusTransitResponse?> getTransits(String poleCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getTransitiPalina.asp?userId=$_userId&codPalina=$poleCode');
      debugPrint('🚌 Fetching transits for pole $poleCode: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);

        _currentTransits = _parseTransits(jsonData);
        debugPrint('✅ Found ${_currentTransits?.transits.length ?? 0} transits for pole $poleCode');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Errore nel caricamento transiti: $e';
      debugPrint('❌ Error fetching transits: $e');
      _currentTransits = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _currentTransits;
  }

  /// Trova paline vicine a una posizione GPS
  Future<List<BusPole>> getPolesNearby(LatLng position, {double radiusKm = 2.0}) async {
    // Prima otteniamo tutte le fermate di Cassino
    await getStops('Cassino');
    
    // Poi prendiamo le paline delle fermate più vicine
    final nearbyStops = _stops.where((stop) {
      final distance = _calculateDistance(position, stop.position);
      return distance <= radiusKm;
    }).toList();

    if (nearbyStops.isNotEmpty) {
      // Prendi le paline della fermata più vicina
      await getPoles(nearbyStops.first.code);
      return _poles;
    }

    return [];
  }

  /// Converte XML in JSON
  Future<Map<String, dynamic>> _xmlToJson(String xmlString) async {
    try {
      final builder = xml2js.XmlBuilder();
      final parser = xml2js.XmlParser();
      final document = parser.parse(xmlString);
      
      // Conversione semplificata XML → Map
      return _xmlNodeToMap(document.rootElement);
    } catch (e) {
      debugPrint('❌ XML parsing error: $e');
      return {};
    }
  }

  Map<String, dynamic> _xmlNodeToMap(dynamic node) {
    final map = <String, dynamic>{};
    
    if (node.children != null) {
      for (final child in node.children) {
        if (child is xml2js.XmlElement) {
          final name = child.name.local;
          final value = child.text.trim();
          
          if (value.isNotEmpty) {
            map[name] = value;
          } else if (child.children.isNotEmpty) {
            map[name] = _xmlNodeToMap(child);
          }
        }
      }
    }
    
    return map;
  }

  List<BusStop> _parseStops(Map<String, dynamic> json) {
    final stops = <BusStop>[];
    // Parsing logica basata sulla struttura XML di Cotral
    // TODO: implementare parsing corretto quando testiamo con dati reali
    return stops;
  }

  List<BusPole> _parsePoles(Map<String, dynamic> json) {
    final poles = <BusPole>[];
    // Parsing logica basata sulla struttura XML di Cotral
    // TODO: implementare parsing corretto quando testiamo con dati reali
    return poles;
  }

  BusTransitResponse _parseTransits(Map<String, dynamic> json) {
    // Parsing logica basata sulla struttura XML di Cotral
    // TODO: implementare parsing corretto quando testiamo con dati reali
    final pole = BusPole(
      code: '',
      name: '',
      locality: 'Cassino',
      position: const LatLng(41.4897, 13.8283),
    );
    
    return BusTransitResponse(pole: pole, transits: []);
  }

  /// Calcola distanza tra due punti GPS (Haversine)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const R = 6371; // Raggio Terra in km
    final dLat = _toRadians(pos2.latitude - pos1.latitude);
    final dLon = _toRadians(pos2.longitude - pos1.longitude);
    
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(pos1.latitude).cos() *
        _toRadians(pos2.latitude).cos() *
        (dLon / 2).sin() *
        (dLon / 2).sin();
    
    final c = 2 * a.sqrt().asin();
    return R * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
}

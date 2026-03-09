import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStop {
  final String code;
  final String name;
  final String locality;
  final LatLng position;

  BusStop({
    required this.code,
    required this.name,
    required this.locality,
    required this.position,
  });

  factory BusStop.fromXml(Map<String, dynamic> xml) {
    return BusStop(
      code: xml['codiceStop']?.toString() ?? '',
      name: xml['nomeStop']?.toString() ?? '',
      locality: xml['localita']?.toString() ?? '',
      position: LatLng(
        double.tryParse(xml['coordX']?.toString() ?? '0') ?? 0.0,
        double.tryParse(xml['coordY']?.toString() ?? '0') ?? 0.0,
      ),
    );
  }
}

class BusPole {
  final String code;
  final String name;
  final String locality;
  final LatLng position;

  BusPole({
    required this.code,
    required this.name,
    required this.locality,
    required this.position,
  });

  factory BusPole.fromXml(Map<String, dynamic> xml) {
    return BusPole(
      code: xml['codicePalina']?.toString() ?? '',
      name: xml['nomePalina']?.toString() ?? '',
      locality: xml['localita']?.toString() ?? '',
      position: LatLng(
        double.tryParse(xml['coordX']?.toString() ?? '0') ?? 0.0,
        double.tryParse(xml['coordY']?.toString() ?? '0') ?? 0.0,
      ),
    );
  }
}

class BusTransit {
  final String routeName;
  final DateTime scheduledTime;
  final DateTime? estimatedTime;
  final String delay;
  final String vehicleCode;
  final bool isRealTime;

  BusTransit({
    required this.routeName,
    required this.scheduledTime,
    this.estimatedTime,
    required this.delay,
    required this.vehicleCode,
    required this.isRealTime,
  });

  factory BusTransit.fromXml(Map<String, dynamic> xml) {
    final scheduledStr = xml['orarioPartenzaCorsa']?.toString() ?? '';
    final transitStr = xml['tempoTransito']?.toString() ?? '';
    
    return BusTransit(
      routeName: xml['percorso']?.toString() ?? '',
      scheduledTime: _parseDateTime(scheduledStr),
      estimatedTime: transitStr.isNotEmpty ? _parseDateTime(transitStr) : null,
      delay: xml['ritardo']?.toString() ?? '00:00:00',
      vehicleCode: xml['automezzo']?['codice']?.toString() ?? '',
      isRealTime: xml['automezzo']?['isAlive']?.toString().toLowerCase() == 'true',
    );
  }

  static DateTime _parseDateTime(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  int getMinutesUntilArrival() {
    final now = DateTime.now();
    final arrivalTime = estimatedTime ?? scheduledTime;
    return arrivalTime.difference(now).inMinutes;
  }

  String getFormattedArrivalTime() {
    final minutes = getMinutesUntilArrival();
    if (minutes < 0) return 'In partenza';
    if (minutes == 0) return 'In arrivo';
    if (minutes == 1) return '1 min';
    return '$minutes min';
  }
}

class BusTransitResponse {
  final BusPole pole;
  final List<BusTransit> transits;

  BusTransitResponse({
    required this.pole,
    required this.transits,
  });
}

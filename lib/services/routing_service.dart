import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_data_model.dart';

/// Fixed walking route from Stazione Cassino to ITIS.
/// Source: BRouter-1.7.0, pedestrian profile — simplified route (102 pts).
/// Distance: 2751m, Duration: ~1965s (~32 min)
const _kRoutePolyline = <LatLng>[
  LatLng(41.485337, 13.831877),
  LatLng(41.485323, 13.831752),
  LatLng(41.485327, 13.831611),
  LatLng(41.485308, 13.831618),
  LatLng(41.485162, 13.830802),
  LatLng(41.48507, 13.83023),
  LatLng(41.48504, 13.830118),
  LatLng(41.485053, 13.830116),
  LatLng(41.485031, 13.830008),
  LatLng(41.484944, 13.829628),
  LatLng(41.484916, 13.829523),
  LatLng(41.484882, 13.829395),
  LatLng(41.484789, 13.829),
  LatLng(41.484735, 13.828776),
  LatLng(41.484511, 13.827962),
  LatLng(41.484269, 13.827426),
  LatLng(41.484064, 13.827107),
  LatLng(41.483932, 13.826953),
  LatLng(41.48351, 13.826597),
  LatLng(41.482705, 13.826161),
  LatLng(41.482583, 13.826057),
  LatLng(41.482478, 13.825897),
  LatLng(41.482413, 13.825723),
  LatLng(41.482137, 13.825775),
  LatLng(41.48185, 13.825777),
  LatLng(41.481281, 13.825903),
  LatLng(41.481197, 13.825924),
  LatLng(41.480986, 13.825963),
  LatLng(41.480857, 13.826027),
  LatLng(41.480715, 13.826182),
  LatLng(41.480711, 13.826186),
  LatLng(41.480658, 13.826245),
  LatLng(41.480633, 13.826272),
  LatLng(41.480458, 13.826578),
  LatLng(41.480279, 13.826855),
  LatLng(41.480113, 13.827022),
  LatLng(41.479819, 13.827229),
  LatLng(41.479531, 13.827302),
  LatLng(41.479239, 13.827302),
  LatLng(41.479056, 13.827256),
  LatLng(41.47888, 13.827244),
  LatLng(41.478596, 13.827293),
  LatLng(41.478001, 13.827513),
  LatLng(41.477497, 13.827571),
  LatLng(41.477357, 13.82758),
  LatLng(41.477264, 13.82761),
  LatLng(41.477157, 13.827713),
  LatLng(41.476935, 13.827968),
  LatLng(41.476689, 13.828101),
  LatLng(41.47658, 13.828158),
  LatLng(41.476331, 13.828284),
  LatLng(41.476183, 13.828395),
  LatLng(41.47611, 13.828477),
  LatLng(41.476003, 13.828631),
  LatLng(41.475924, 13.828763),
  LatLng(41.475858, 13.828933),
  LatLng(41.475811, 13.829053),
  LatLng(41.475576, 13.829848),
  LatLng(41.475542, 13.82989),
  LatLng(41.475528, 13.829909),
  LatLng(41.475501, 13.829928),
  LatLng(41.475401, 13.830021),
  LatLng(41.475383, 13.830014),
  LatLng(41.47536, 13.830029),
  LatLng(41.475212, 13.829931),
  LatLng(41.475047, 13.829783),
  LatLng(41.474924, 13.829669),
  LatLng(41.474993, 13.82958),
  LatLng(41.474911, 13.829475),
  LatLng(41.474553, 13.829001),
  LatLng(41.47446, 13.828974),
  LatLng(41.474322, 13.828951),
  LatLng(41.474233, 13.82887),
  LatLng(41.473924, 13.828494),
  LatLng(41.473849, 13.828374),
  LatLng(41.473813, 13.828303),
  LatLng(41.473787, 13.828213),
  LatLng(41.473787, 13.828158),
  LatLng(41.473805, 13.82807),
  LatLng(41.473944, 13.827759),
  LatLng(41.473993, 13.827633),
  LatLng(41.473992, 13.827576),
  LatLng(41.47397, 13.827526),
  LatLng(41.473925, 13.827474),
  LatLng(41.47374, 13.827283),
  LatLng(41.473361, 13.827891),
  LatLng(41.473346, 13.827915),
  LatLng(41.473155, 13.827921),
  LatLng(41.472962, 13.827927),
  LatLng(41.472829, 13.827998),
  LatLng(41.472656, 13.828274),
  LatLng(41.471019, 13.8309),
  LatLng(41.470955, 13.830944),
  LatLng(41.469682, 13.833027),
  LatLng(41.469662, 13.833214),
  LatLng(41.469674, 13.833342),
  LatLng(41.469631, 13.833487),
  LatLng(41.469546, 13.833608),
  LatLng(41.469344, 13.833666),
  LatLng(41.468955, 13.834117),
  LatLng(41.468917, 13.834214),
  LatLng(41.468911, 13.834234),
];

/// Se la posizione è più lontana di questa soglia dal percorso,
/// mostriamo il percorso dall'inizio (utente non ancora sul tracciato).
const double _kOffRouteSnapThresholdMeters = 150.0;

class RoutingService {
  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
  }) async {
    // 1. Orienta la polilinea verso la destinazione
    final oriented = _orientToward(end);

    // 2. Snap: trova il punto più vicino alla posizione attuale
    final snapResult = _snapToRoute(start, oriented);
    final startIndex = snapResult.distanceMeters > _kOffRouteSnapThresholdMeters
        ? 0
        : snapResult.index;

    // 3. Tronca dal punto di snap fino alla fine
    final trimmed = oriented.sublist(startIndex);
    final polyline = trimmed.length >= 2 ? trimmed : oriented;

    // 4. Distanza e durata proporzionali ai punti rimasti
    final totalLen = _polylineLength(oriented);
    final remainingLen = _polylineLength(polyline);
    final fraction = totalLen > 0 ? remainingLen / totalLen : 1.0;
    final distanceM = 2751.0 * fraction;
    final durationS = 1965.0 * fraction;

    return RouteDataModel(
      polylinePoints: polyline,
      steps: _buildSteps(polyline, distanceM, durationS),
      distanceMeters: distanceM,
      durationSeconds: durationS,
    );
  }

  List<LatLng> _orientToward(LatLng destination) {
    final dFirst = _haversineM(_kRoutePolyline.first, destination);
    final dLast  = _haversineM(_kRoutePolyline.last,  destination);
    return dLast <= dFirst
        ? List<LatLng>.from(_kRoutePolyline)
        : _kRoutePolyline.reversed.toList();
  }

  _SnapResult _snapToRoute(LatLng pos, List<LatLng> polyline) {
    int bestIndex = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < polyline.length; i++) {
      final d = _haversineM(pos, polyline[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }
    return _SnapResult(bestIndex, bestDist);
  }

  double _polylineLength(List<LatLng> pts) {
    double total = 0;
    for (int i = 1; i < pts.length; i++) {
      total += _haversineM(pts[i - 1], pts[i]);
    }
    return total;
  }

  double _haversineM(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = a.latitude  * math.pi / 180;
    final lat2 = b.latitude  * math.pi / 180;
    final dlat = (b.latitude  - a.latitude)  * math.pi / 180;
    final dlng = (b.longitude - a.longitude) * math.pi / 180;
    final sinLat = math.sin(dlat / 2);
    final sinLng = math.sin(dlng / 2);
    final h = sinLat * sinLat +
        math.cos(lat1) * math.cos(lat2) * sinLng * sinLng;
    return 2 * r * math.asin(math.sqrt(h));
  }

  List<RouteStepModel> _buildSteps(
      List<LatLng> polyline, double distanceM, double durationS) {
    return [
      RouteStepModel(
        instruction: 'Parti e segui il percorso',
        location: polyline.first,
        distance: distanceM,
        duration: durationS,
      ),
      RouteStepModel(
        instruction: 'Sei arrivato a destinazione',
        location: polyline.last,
        distance: 0,
        duration: 0,
      ),
    ];
  }
}

class _SnapResult {
  final int index;
  final double distanceMeters;
  const _SnapResult(this.index, this.distanceMeters);
}

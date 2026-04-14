import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Route and navigation constants
class RouteConstants {
  RouteConstants._();

  // OSRM API
  static const osrmBaseUrl = 'https://routing.openstreetmap.de/routed-foot/route/v1/walking';

  // Weather API (Open-Meteo)
  static const weatherBaseUrl = 'api.open-meteo.com';
  static const weatherPath = '/v1/forecast';

  /// Hardcoded walking route from Cassino Station to ITIS.
  /// Source: BRouter-1.7.0, pedestrian profile, simplified (102 points).
  /// Total distance: 2751m, Duration: ~1965s (~32 min)
  static const kRoutePolyline = <LatLng>[
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
}

/// Destination model for navigation
class Destination {
  final String name;
  final LatLng latLng;
  final String description;

  const Destination({
    required this.name,
    required this.latLng,
    required this.description,
  });
}

/// Predefined destinations
class AppDestinations {
  AppDestinations._();

  static const school = Destination(
    name: 'ITIS Biennio',
    latLng: LatLng(41.468840, 13.834258),
    description: 'ITIS E. Majorana - Cassino',
  );

  static const station = Destination(
    name: 'Stazione Ferroviaria',
    latLng: LatLng(41.485302, 13.831859),
    description: 'Stazione di Cassino',
  );

  static const kDestinations = [school, station];
}

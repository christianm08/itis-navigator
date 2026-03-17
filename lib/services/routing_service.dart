import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_data_model.dart';

/// Fixed walking route from Stazione Cassino to ITIS.
/// Source: BRouter-1.7.0, pedestrian profile, drawn manually on brouter.de
/// Distance: 2983m, Duration: ~2129s (~35 min)
const _kRoutePolyline = <LatLng>[
  LatLng(41.485337, 13.831877),
  LatLng(41.485324, 13.831766),
  LatLng(41.485323, 13.831752),
  LatLng(41.485326, 13.831614),
  LatLng(41.485327, 13.831611),
  LatLng(41.485125, 13.830459),
  LatLng(41.485112, 13.830399),
  LatLng(41.485053, 13.830116),
  LatLng(41.485031, 13.830008),
  LatLng(41.484944, 13.829628),
  LatLng(41.484938, 13.829606),
  LatLng(41.484916, 13.829523),
  LatLng(41.484882, 13.829395),
  LatLng(41.484789, 13.829),
  LatLng(41.484735, 13.828776),
  LatLng(41.484732, 13.828766),
  LatLng(41.484518, 13.827988),
  LatLng(41.484511, 13.827962),
  LatLng(41.484273, 13.827435),
  LatLng(41.484269, 13.827426),
  LatLng(41.484067, 13.827111),
  LatLng(41.484064, 13.827107),
  LatLng(41.483932, 13.826953),
  LatLng(41.483929, 13.826951),
  LatLng(41.48351, 13.826597),
  LatLng(41.482705, 13.826161),
  LatLng(41.482586, 13.82606),
  LatLng(41.482583, 13.826057),
  LatLng(41.482487, 13.82591),
  LatLng(41.482478, 13.825897),
  LatLng(41.482413, 13.825723),
  LatLng(41.482408, 13.825723),
  LatLng(41.482142, 13.825774),
  LatLng(41.482137, 13.825775),
  LatLng(41.481852, 13.825776),
  LatLng(41.48185, 13.825777),
  LatLng(41.481281, 13.825903),
  LatLng(41.481197, 13.825924),
  LatLng(41.480992, 13.825961),
  LatLng(41.480986, 13.825963),
  LatLng(41.480869, 13.82602),
  LatLng(41.480857, 13.826027),
  LatLng(41.480715, 13.826182),
  LatLng(41.480711, 13.826186),
  LatLng(41.480658, 13.826245),
  LatLng(41.480636, 13.826268),
  LatLng(41.480633, 13.826272),
  LatLng(41.480458, 13.826578),
  LatLng(41.480285, 13.826844),
  LatLng(41.480279, 13.826855),
  LatLng(41.480124, 13.82701),
  LatLng(41.480113, 13.827022),
  LatLng(41.479826, 13.827223),
  LatLng(41.479819, 13.827229),
  LatLng(41.479559, 13.827294),
  LatLng(41.479531, 13.827302),
  LatLng(41.479239, 13.827302),
  LatLng(41.479056, 13.827256),
  LatLng(41.479038, 13.827254),
  LatLng(41.47888, 13.827244),
  LatLng(41.478596, 13.827293),
  LatLng(41.478001, 13.827513),
  LatLng(41.477497, 13.827571),
  LatLng(41.477357, 13.82758),
  LatLng(41.477264, 13.82761),
  LatLng(41.477157, 13.827713),
  LatLng(41.476937, 13.827964),
  LatLng(41.476935, 13.827968),
  LatLng(41.476689, 13.828101),
  LatLng(41.47658, 13.828158),
  LatLng(41.476331, 13.828284),
  LatLng(41.476191, 13.828389),
  LatLng(41.476183, 13.828395),
  LatLng(41.47611, 13.828477),
  LatLng(41.476003, 13.828631),
  LatLng(41.475924, 13.828763),
  LatLng(41.475858, 13.828933),
  LatLng(41.475855, 13.828939),
  LatLng(41.475811, 13.829053),
  LatLng(41.47558, 13.829833),
  LatLng(41.475576, 13.829848),
  LatLng(41.475528, 13.829909),
  LatLng(41.475501, 13.829928),
  LatLng(41.475401, 13.830021),
  LatLng(41.475383, 13.830014),
  LatLng(41.475364, 13.830026),
  LatLng(41.47536, 13.830029),
  LatLng(41.475212, 13.829931),
  LatLng(41.475047, 13.829783),
  LatLng(41.474924, 13.829669),
  LatLng(41.474993, 13.82958),
  LatLng(41.474978, 13.82956),
  LatLng(41.474911, 13.829475),
  LatLng(41.474553, 13.829001),
  LatLng(41.474508, 13.828988),
  LatLng(41.47446, 13.828974),
  LatLng(41.474322, 13.828951),
  LatLng(41.474275, 13.828909),
  LatLng(41.474233, 13.82887),
  LatLng(41.473924, 13.828494),
  LatLng(41.473849, 13.828374),
  LatLng(41.473813, 13.828303),
  LatLng(41.473787, 13.828213),
  LatLng(41.473787, 13.828158),
  LatLng(41.473805, 13.82807),
  LatLng(41.473944, 13.827759),
  LatLng(41.473993, 13.827633),
  LatLng(41.473992, 13.82759),
  LatLng(41.473992, 13.827576),
  LatLng(41.47397, 13.827526),
  LatLng(41.473925, 13.827474),
  LatLng(41.47374, 13.827283),
  LatLng(41.473736, 13.827288),
  LatLng(41.473361, 13.827891),
  LatLng(41.473333, 13.827875),
  LatLng(41.473361, 13.827891),
  LatLng(41.473346, 13.827915),
  LatLng(41.473155, 13.827921),
  LatLng(41.472962, 13.827927),
  LatLng(41.472829, 13.827998),
  LatLng(41.471019, 13.8309),
  LatLng(41.470955, 13.830944),
  LatLng(41.469682, 13.833027),
  LatLng(41.469662, 13.833214),
  LatLng(41.469674, 13.833342),
  LatLng(41.469631, 13.833487),
  LatLng(41.469546, 13.833607),
  LatLng(41.469546, 13.833608),
  LatLng(41.469344, 13.833666),
  LatLng(41.468955, 13.834117),
  LatLng(41.468947, 13.834136),
  LatLng(41.468917, 13.834214),
  LatLng(41.46891, 13.834235),
  LatLng(41.468705, 13.834946),
  LatLng(41.469059, 13.835118),
  LatLng(41.469048, 13.835154),
  LatLng(41.468752, 13.835029),
  LatLng(41.468628, 13.834973),
  LatLng(41.46887, 13.834205),
];

class RoutingService {
  /// Returns the fixed walking route from Stazione to ITIS (or reverse).
  /// The [waypoints] parameter is accepted for API compatibility but ignored —
  /// the route is hardcoded from the BRouter GeoJSON drawn by the user.
  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
  }) async {
    // Determine direction: if start is closer to the last point, reverse.
    final polyline = _nearestEnd(start) == _NearestEnd.last
        ? _kRoutePolyline.reversed.toList()
        : List<LatLng>.from(_kRoutePolyline);

    final List<RouteStepModel> steps = _buildSteps(polyline);

    return RouteDataModel(
      polylinePoints: polyline,
      steps: steps,
      distanceMeters: 2983.0,
      durationSeconds: 2129.0,
    );
  }

  /// Check which endpoint of the hardcoded polyline is closest to [start].
  _NearestEnd _nearestEnd(LatLng start) {
    final dFirst = _dist(start, _kRoutePolyline.first);
    final dLast  = _dist(start, _kRoutePolyline.last);
    return dFirst <= dLast ? _NearestEnd.first : _NearestEnd.last;
  }

  /// Crude squared-distance (no need for real Haversine for just 2 points).
  double _dist(LatLng a, LatLng b) {
    final dlat = a.latitude  - b.latitude;
    final dlng = a.longitude - b.longitude;
    return dlat * dlat + dlng * dlng;
  }

  /// Generate minimal turn-by-turn steps from the polyline.
  /// Produces one "Parti" step at the start and one "Sei arrivato" at the end.
  List<RouteStepModel> _buildSteps(List<LatLng> polyline) {
    return [
      RouteStepModel(
        instruction: 'Parti e segui il percorso',
        location: polyline.first,
        distance: 2983.0,
        duration: 2129.0,
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

enum _NearestEnd { first, last }

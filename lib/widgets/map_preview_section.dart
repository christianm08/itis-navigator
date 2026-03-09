import 'package:animations/animations.dart' as animations;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/landmark.dart';
import '../screens/map_screen.dart';

class MapPreviewSection extends StatelessWidget {
  const MapPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Centro preview: metà circa del percorso CSV
    final points = Landmark.routeCsvPoints(); // coordinate dal tuo CSV [file:46]
    final mid = points[points.length ~/ 2];
    final previewCenter = LatLng(mid.latitude, mid.longitude);

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // MINI MAPPA (non interattiva per non “mangiare” lo scroll)
            IgnorePointer(
              ignoring: true,
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: previewCenter, zoom: 14.2),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  zoomControlsEnabled: false,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  mapToolbarEnabled: false,
                  // Nota: liteModeEnabled è utile soprattutto su Android (se disponibile nel tuo setup).
                  liteModeEnabled: true,
                ),
              ),
            ),

            // Overlay gradient per “leggibilità”
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.00),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Titolo “a vista d’occhio”
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Mappa (preview)',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),

            // PULSANTI con animazione “tasto → pagina”
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: _OpenMapButton(
                      label: 'Vai all’ITIS',
                      icon: Icons.school,
                      color: cs.primary,
                      onOpen: () => const MapScreen(
                        from: RoutePoint.station,
                        to: RoutePoint.itisTriennio,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OpenMapButton(
                      label: 'Vai alla Stazione',
                      icon: Icons.train,
                      color: cs.tertiary,
                      onOpen: () => const MapScreen(
                        from: RoutePoint.itisTriennio,
                        to: RoutePoint.station,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenMapButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function() onOpen;

  const _OpenMapButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return animations.OpenContainer(
      transitionDuration: const Duration(milliseconds: 520),
      transitionType: animations.ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: cs.surface,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      openShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      closedBuilder: (ctx, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        );
      },
      openBuilder: (ctx, closeContainer) => onOpen(),
    );
  }
}

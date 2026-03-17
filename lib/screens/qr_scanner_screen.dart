import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ─────────────────────────────────────────────
// Dati dei punti QR (coordinate + password)
// ─────────────────────────────────────────────

const _stazione = [41.485302, 13.831859];
const _itis = [41.468840, 13.834258];

const _qrPoints = [
  _QrPoint(
    label: 'Punto 1',
    password: 'pass1',
    lat: 41.482421,
    lng: 13.825648,
  ),
  _QrPoint(
    label: 'Punto 2',
    password: 'pass2',
    lat: 41.475818,
    lng: 13.828921,
  ),
  _QrPoint(
    label: 'Punto 3',
    password: 'pass3',
    lat: 41.474282,
    lng: 13.828943,
  ),
];

/// Raggio entro cui l'utente deve trovarsi per poter scansionare (in metri)
const double _kScanRadius = 30.0;

// ─────────────────────────────────────────────
// Modello punto QR
// ─────────────────────────────────────────────

class _QrPoint {
  final String label;
  final String password;
  final double lat;
  final double lng;

  const _QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
  });
}

// ─────────────────────────────────────────────
// Screen principale: lista dei punti
// ─────────────────────────────────────────────

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  Position? _position;
  bool _loadingGps = true;
  final Set<String> _unlocked = {};

  @override
  void initState() {
    super.initState();
    _fetchPosition();
  }

  Future<void> _fetchPosition() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        setState(() => _loadingGps = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) setState(() { _position = pos; _loadingGps = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  double? _distanceTo(_QrPoint p) {
    if (_position == null) return null;
    return Geolocator.distanceBetween(
      _position!.latitude, _position!.longitude,
      p.lat, p.lng,
    );
  }

  bool _isNearby(_QrPoint p) {
    final d = _distanceTo(p);
    return d != null && d <= _kScanRadius;
  }

  void _onUnlock(String label) {
    setState(() => _unlocked.add(label));
    // Controlla se tutti i punti sono sbloccati
    if (_unlocked.length == _qrPoints.length) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showCompletionDialog();
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Text('🎉', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Text('Percorso completato!'),
        ]),
        content: const Text(
          'Hai scansionato tutti e 3 i punti del percorso '
          'dalla Stazione all\'ITIS. Ottimo lavoro!',
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Torna alla Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Percorso QR',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                    child: Row(children: [
                      const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Stazione → ITIS',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_unlocked.length}/${_qrPoints.length} punti sbloccati',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Barra progresso ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progresso percorso',
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text(
                        '${(_unlocked.length / _qrPoints.length * 100).round()}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: _qrPoints.isEmpty
                          ? 0
                          : _unlocked.length / _qrPoints.length,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Info GPS
                  _GpsStatusBanner(
                    loading: _loadingGps,
                    position: _position,
                    onRefresh: _fetchPosition,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Lista punti ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final point = _qrPoints[i];
                  final dist = _distanceTo(point);
                  final nearby = _isNearby(point);
                  final done = _unlocked.contains(point.label);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _QrPointCard(
                      point: point,
                      index: i,
                      distance: dist,
                      isNearby: nearby,
                      isUnlocked: done,
                      loadingGps: _loadingGps,
                      onScan: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _QrScanPage(
                            point: point,
                            onSuccess: () {
                              Navigator.pop(context);
                              _onUnlock(point.label);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _qrPoints.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Banner stato GPS
// ─────────────────────────────────────────────

class _GpsStatusBanner extends StatelessWidget {
  final bool loading;
  final Position? position;
  final VoidCallback onRefresh;

  const _GpsStatusBanner({
    required this.loading,
    required this.position,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('Rilevamento GPS in corso...',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ]),
      );
    }
    if (position == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(children: [
          Icon(Icons.location_off_rounded,
              size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'GPS non disponibile — le distanze non verranno calcolate.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.orange.shade800),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            color: Colors.orange.shade700,
            onPressed: onRefresh,
            tooltip: 'Riprova GPS',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(children: [
        Icon(Icons.my_location_rounded,
            size: 18, color: Colors.green.shade700),
        const SizedBox(width: 10),
        Text(
          'GPS attivo — precisione ${position!.accuracy.round()} m',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: Colors.green.shade800),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Card di un singolo punto QR
// ─────────────────────────────────────────────

class _QrPointCard extends StatelessWidget {
  final _QrPoint point;
  final int index;
  final double? distance;
  final bool isNearby;
  final bool isUnlocked;
  final bool loadingGps;
  final VoidCallback onScan;

  const _QrPointCard({
    required this.point,
    required this.index,
    required this.distance,
    required this.isNearby,
    required this.isUnlocked,
    required this.loadingGps,
    required this.onScan,
  });

  String _formatDistance(double d) {
    if (d < 1000) return '${d.round()} m';
    return '${(d / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color cardBorder;
    Color iconBg;
    IconData stateIcon;
    String stateLabel;

    if (isUnlocked) {
      cardBorder = Colors.green.shade300;
      iconBg = Colors.green.shade100;
      stateIcon = Icons.check_circle_rounded;
      stateLabel = 'Completato';
    } else if (isNearby) {
      cardBorder = theme.colorScheme.primary;
      iconBg = theme.colorScheme.primaryContainer;
      stateIcon = Icons.qr_code_scanner_rounded;
      stateLabel = 'Pronto per la scansione!';
    } else {
      cardBorder = Colors.grey.shade200;
      iconBg = Colors.grey.shade100;
      stateIcon = Icons.lock_outline_rounded;
      stateLabel = distance != null
          ? 'A ${_formatDistance(distance!)} da qui'
          : 'Posizione non disponibile';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: isNearby ? 2 : 1.2),
        boxShadow: [
          BoxShadow(
            color: isNearby
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Numero step
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isUnlocked
                  ? Icon(Icons.check_rounded,
                      color: Colors.green.shade700, size: 22)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isNearby
                            ? theme.colorScheme.primary
                            : Colors.grey.shade500,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    point.label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(stateIcon,
                          size: 14,
                          color: isUnlocked
                              ? Colors.green.shade600
                              : isNearby
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stateLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                                ? Colors.green.shade600
                                : isNearby
                                    ? theme.colorScheme.primary
                                    : Colors.grey.shade500,
                            fontWeight: isNearby
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Pulsante scansione
            if (!isUnlocked)
              ElevatedButton(
                onPressed: (isNearby || loadingGps) ? onScan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNearby
                      ? theme.colorScheme.primary
                      : Colors.grey.shade200,
                  foregroundColor:
                      isNearby ? Colors.white : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.check_rounded,
                    color: Colors.green.shade700, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pagina di scansione QR (camera + validazione)
// ─────────────────────────────────────────────

class _QrScanPage extends StatefulWidget {
  final _QrPoint point;
  final VoidCallback onSuccess;

  const _QrScanPage({required this.point, required this.onSuccess});

  @override
  State<_QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<_QrScanPage> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _processing = false;
  String? _errorMsg;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() { _processing = true; _errorMsg = null; });
    _ctrl.stop();

    if (raw.trim() == widget.point.password.trim()) {
      _showResult(success: true);
    } else {
      setState(() {
        _errorMsg = 'QR non valido per questo punto. Riprova.';
        _processing = false;
      });
      _ctrl.start();
    }
  }

  void _showResult({required bool success}) {
    if (!success) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          const Text('✅', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Text('${widget.point.label} sbloccato!'),
        ]),
        content: Text(
          'Hai scansionato correttamente il QR code del ${widget.point.label}.',
        ),
        actions: [
          ElevatedButton(
            onPressed: widget.onSuccess,
            child: const Text('Continua'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Scansiona — ${widget.point.label}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _ctrl.torchState,
              builder: (_, state, __) => Icon(
                state == TorchState.on
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: state == TorchState.on
                    ? Colors.yellow
                    : Colors.white,
              ),
            ),
            onPressed: () => _ctrl.toggleTorch(),
            tooltip: 'Torcia',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Overlay mirino
          Center(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                  borderColor: theme.colorScheme.primary),
              child: const SizedBox(width: 260, height: 260),
            ),
          ),

          // Label + istruzione
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Inquadra il QR code del ${widget.point.label}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _errorMsg!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Spinner quando processa
          if (_processing)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    const Text('Verifica in corso...',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painter mirino scanner
// ─────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  const _ScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLen = 36.0;
    const cornerW = 4.0;
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = cornerW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // Angolo top-left
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);
    // Angolo top-right
    canvas.drawLine(r.topRight, r.topRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);
    // Angolo bottom-left
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -cornerLen), paint);
    // Angolo bottom-right
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -cornerLen), paint);

    // Linea animata (statica qui, ma visivamente guida)
    final scanPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.borderColor != borderColor;
}

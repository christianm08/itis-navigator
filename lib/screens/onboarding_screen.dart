import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 2;

  bool _voiceEnabled = true;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TtsService>().speak(
        'Benvenuto in ITIS Navigator. '
        'Questa app ti guidera dalla Stazione di Cassino '
        'fino all ITIS Majorana con indicazioni vocali.',
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final tts = context.read<TtsService>();
    tts.setEnabled(_voiceEnabled);
    await tts.setSpeechRate(_speechRate);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('tts_enabled', _voiceEnabled);

    if (_voiceEnabled) {
      await tts.speak('Configurazione completata. Benvenuto!');
      await Future.delayed(const Duration(milliseconds: 1800));
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      if (_currentPage == 0) {
        context.read<TtsService>().speak('Impostazioni guida vocale.');
      }
    } else {
      _saveAndContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _PageWelcome(theme: theme),
                  _PageVoice(
                    theme: theme,
                    voiceEnabled: _voiceEnabled,
                    speechRate: _speechRate,
                    onVoiceToggle: (v) {
                      setState(() => _voiceEnabled = v);
                      context.read<TtsService>().setEnabled(v);
                      if (v) context.read<TtsService>().speak('Guida vocale attivata.');
                    },
                    onRateChange: (r) async {
                      setState(() => _speechRate = r);
                      await context.read<TtsService>().setSpeechRate(r);
                      context.read<TtsService>().speak('Questa e la velocita selezionata.');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Semantics(
                button: true,
                label: _currentPage < _totalPages - 1
                    ? 'Continua alla pagina successiva'
                    : 'Inizia ad usare l app',
                child: SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentPage < _totalPages - 1 ? 'Continua' : 'Inizia',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageWelcome extends StatelessWidget {
  final ThemeData theme;
  const _PageWelcome({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 32),
          Semantics(
            header: true,
            child: Text(
              'Benvenuto in\nITIS Navigator',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Ti guido dalla Stazione di Cassino fino all'ITIS Majorana "
            'con indicazioni vocali passo dopo passo.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 28),
          _FeatureRow(icon: Icons.record_voice_over_rounded, text: 'Indicazioni vocali in italiano'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.map_rounded, text: 'Mappa GPS con percorso'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.directions_transit_rounded, text: 'Orari Cotral, Trenitalia e Magni'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.qr_code_scanner_rounded, text: 'QR code lungo il percorso'),
        ],
      ),
    );
  }
}

class _PageVoice extends StatelessWidget {
  final ThemeData theme;
  final bool voiceEnabled;
  final double speechRate;
  final ValueChanged<bool> onVoiceToggle;
  final Future<void> Function(double) onRateChange;

  const _PageVoice({
    required this.theme,
    required this.voiceEnabled,
    required this.speechRate,
    required this.onVoiceToggle,
    required this.onRateChange,
  });

  String _rateLabel(double r) {
    if (r <= 0.35) return 'Lenta';
    if (r <= 0.55) return 'Normale';
    return 'Veloce';
  }

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Guida vocale',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          Text(
            "L'app legge le indicazioni ad alta voce mentre cammini.",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 32),
          Semantics(
            toggled: voiceEnabled,
            label: voiceEnabled
                ? 'Guida vocale attiva. Tocca per disattivare.'
                : 'Guida vocale disattivata. Tocca per attivare.',
            child: GestureDetector(
              onTap: () => onVoiceToggle(!voiceEnabled),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: voiceEnabled ? cs.primaryContainer : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: voiceEnabled ? cs.primary : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: voiceEnabled ? cs.primary : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        voiceEnabled ? 'Voce attiva' : 'Voce disattivata',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Switch(value: voiceEnabled, onChanged: onVoiceToggle),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (voiceEnabled) ...[  
            const SizedBox(height: 28),
            Text(
              'Velocita della voce: ${_rateLabel(speechRate)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Velocita voce: ${_rateLabel(speechRate)}. Scorri per cambiare.',
              child: Slider(
                value: speechRate,
                min: 0.3,
                max: 0.7,
                divisions: 4,
                label: _rateLabel(speechRate),
                onChanged: (_) {},
                onChangeEnd: onRateChange,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lenta', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                Text('Veloce', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

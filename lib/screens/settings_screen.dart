import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceEnabled = true;
  double _speechRate = 0.5;
  String _userType = 'biennio';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceEnabled = prefs.getBool('tts_enabled') ?? true;
      _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _userType = prefs.getString('user_type') ?? 'biennio';
      _loading = false;
    });
    // Sincronizza TtsService
    if (mounted) {
      context.read<TtsService>().setEnabled(_voiceEnabled);
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_enabled', _voiceEnabled);
    await prefs.setDouble('tts_speech_rate', _speechRate);
    await prefs.setString('user_type', _userType);
  }

  Future<void> _resetOnboarding() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ripeti configurazione?'),
        content: const Text(
          'Verrai riportato alla schermata iniziale di configurazione.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continua'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  String _rateLabel(double r) {
    if (r <= 0.35) return 'Lenta';
    if (r <= 0.55) return 'Normale';
    return 'Veloce';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Torna alla home',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                // ── Voce ────────────────────────────────────────────────
                _SectionHeader(label: 'Guida vocale', icon: Icons.record_voice_over_rounded),
                const SizedBox(height: 12),

                // Toggle voce
                Semantics(
                  toggled: _voiceEnabled,
                  label: _voiceEnabled
                      ? 'Guida vocale attiva. Tocca per disattivare.'
                      : 'Guida vocale disattivata. Tocca per attivare.',
                  child: _SettingsTile(
                    icon: _voiceEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    iconColor: _voiceEnabled ? cs.primary : Colors.grey,
                    title: 'Guida vocale',
                    subtitle: _voiceEnabled ? 'Attiva' : 'Disattivata',
                    trailing: ExcludeSemantics(
                      child: Switch(
                        value: _voiceEnabled,
                        onChanged: (v) {
                          setState(() => _voiceEnabled = v);
                          context.read<TtsService>().setEnabled(v);
                          if (v) {
                            context.read<TtsService>().speak(
                                'Guida vocale attivata.');
                          }
                          _savePrefs();
                        },
                      ),
                    ),
                  ),
                ),

                if (_voiceEnabled) ...[  
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.speed_rounded,
                    iconColor: cs.primary,
                    title: 'Velocità voce',
                    subtitle: _rateLabel(_speechRate),
                    trailing: null,
                  ),
                  Semantics(
                    label: 'Velocità voce: ${_rateLabel(_speechRate)}. Scorri per cambiare.',
                    child: Slider(
                      value: _speechRate,
                      min: 0.3,
                      max: 0.7,
                      divisions: 4,
                      label: _rateLabel(_speechRate),
                      onChanged: (v) => setState(() => _speechRate = v),
                      onChangeEnd: (v) {
                        _savePrefs();
                        context.read<TtsService>().speak(
                            'Questa è la velocità selezionata.');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lenta',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey)),
                        Text('Veloce',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Pulsante test voce
                  Center(
                    child: Semantics(
                      button: true,
                      label: 'Prova voce. Tocca per sentire un esempio.',
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<TtsService>().speak(
                          'Tra 50 metri, svolta a destra in Via Sant Angelo.',
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Prova voce'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Profilo ─────────────────────────────────────────────
                _SectionHeader(
                    label: 'Profilo scolastico',
                    icon: Icons.school_rounded),
                const SizedBox(height: 12),

                Semantics(
                  label: 'Biennio. Anni primo e secondo, ingresso principale. '
                      '${_userType == 'biennio' ? 'Selezionato.' : 'Tocca per selezionare.'}',
                  button: true,
                  selected: _userType == 'biennio',
                  child: _SelectableTile(
                    icon: Icons.school_outlined,
                    title: 'Biennio',
                    subtitle: 'Anni 1° e 2° — ingresso principale',
                    selected: _userType == 'biennio',
                    onTap: () {
                      setState(() => _userType = 'biennio');
                      _savePrefs();
                      context
                          .read<TtsService>()
                          .speak('Selezionato Biennio.');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Triennio. Anni terzo, quarto e quinto, ingresso laterale. '
                      '${_userType == 'triennio' ? 'Selezionato.' : 'Tocca per selezionare.'}',
                  button: true,
                  selected: _userType == 'triennio',
                  child: _SelectableTile(
                    icon: Icons.school_rounded,
                    title: 'Triennio',
                    subtitle: 'Anni 3°, 4° e 5° — ingresso laterale',
                    selected: _userType == 'triennio',
                    onTap: () {
                      setState(() => _userType = 'triennio');
                      _savePrefs();
                      context
                          .read<TtsService>()
                          .speak('Selezionato Triennio.');
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── App ─────────────────────────────────────────────────
                _SectionHeader(label: 'App', icon: Icons.settings_rounded),
                const SizedBox(height: 12),

                Semantics(
                  button: true,
                  label: 'Ripeti configurazione iniziale.',
                  child: _SettingsTile(
                    icon: Icons.refresh_rounded,
                    iconColor: cs.secondary,
                    title: 'Ripeti configurazione iniziale',
                    subtitle: 'Torna alla schermata di benvenuto',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: cs.secondary),
                    onTap: _resetOnboarding,
                  ),
                ),

                const SizedBox(height: 10),

                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.grey,
                  title: 'Versione',
                  subtitle: '1.0.0',
                  trailing: null,
                ),
              ],
            ),
    );
  }
}

// ── Widget ausiliari ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? cs.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? cs.primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? cs.primary : Colors.grey, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? cs.primary : null,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      color: cs.primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

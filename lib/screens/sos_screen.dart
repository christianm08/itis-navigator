import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile chiamare $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final List<_SosContact> contacts = [
      _SosContact(
        label: 'Emergenza Generale',
        number: '112',
        icon: Icons.emergency_rounded,
        color: const Color(0xFFD32F2F),
      ),
      _SosContact(
        label: 'Ambulanza',
        number: '118',
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFFE53935),
      ),
      _SosContact(
        label: 'Polizia',
        number: '113',
        icon: Icons.local_police_rounded,
        color: const Color(0xFF1565C0),
      ),
      _SosContact(
        label: 'Vigili del Fuoco',
        number: '115',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFE65100),
      ),
      _SosContact(
        label: 'Segreteria Scuola',
        number: '0776 312302',
        icon: Icons.school_rounded,
        color: const Color(0xFF2E7D32),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'SOS Emergenza',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.emergency_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            backgroundColor: const Color(0xFFB71C1C),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFFB71C1C)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tocca un numero per chiamare direttamente i soccorsi.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFB71C1C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final contact = contacts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Semantics(
                      button: true,
                      label: 'Chiama ${contact.label}: ${contact.number}',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _callNumber(context, contact.number),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.07),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: theme.brightness == Brightness.dark
                                  ? Border.all(
                                      color: cs.onSurface.withValues(alpha: 0.12))
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color:
                                          contact.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(contact.icon,
                                        color: contact.color, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.label,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          contact.number,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: contact.color,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: contact.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.phone_rounded,
                                        color: Colors.white, size: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: contacts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SosContact {
  final String label;
  final String number;
  final IconData icon;
  final Color color;

  const _SosContact({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
  });
}

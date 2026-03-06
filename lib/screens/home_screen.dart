import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_route_card.dart';
import '../widgets/quick_action_button.dart';
import 'map_navigation_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(theme, isDark),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(theme),
                    const SizedBox(height: 24),
                    _buildQuickActions(theme),
                    const SizedBox(height: 24),
                    _buildRouteCards(theme),
                    const SizedBox(height: 24),
                    _buildInfoSection(theme),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ITIS Navigator',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeController,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Benvenuto! 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Raggiungi l\'ITIS E. Majorana',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Row(
        children: [
          Expanded(
            child: QuickActionButton(
              icon: Icons.navigation_rounded,
              label: 'Naviga',
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              onTap: () => _navigateToMap(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: QuickActionButton(
              icon: Icons.info_rounded,
              label: 'Info ITIS',
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.secondary.withOpacity(0.8),
                ],
              ),
              onTap: () => _navigateToInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Percorsi Disponibili',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedRouteCard(
          title: '🚶 A Piedi',
          distance: '1.2 km',
          duration: '15 min',
          description: 'Percorso più breve dalla stazione',
          color: theme.colorScheme.primary,
          onTap: () => _startNavigation('walking'),
        ),
        const SizedBox(height: 12),
        AnimatedRouteCard(
          title: '🚌 Autobus',
          distance: '2.1 km',
          duration: '8 min',
          description: 'Linea urbana diretta',
          color: theme.colorScheme.secondary,
          onTap: () => _startNavigation('bus'),
        ),
        const SizedBox(height: 12),
        AnimatedRouteCard(
          title: '🚗 Auto',
          distance: '1.8 km',
          duration: '5 min',
          description: 'Via più veloce in auto',
          color: theme.colorScheme.tertiary,
          onTap: () => _startNavigation('car'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Orari Scuola',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              Icons.wb_sunny_rounded,
              'Mattina',
              '8:00 - 13:00',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.nights_stay_rounded,
              'Pomeriggio',
              '14:00 - 17:00',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MapNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToInfo() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const InfoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
      ),
    );
  }

  void _startNavigation(String mode) {
    context.read<NavigationService>().setTransportMode(mode);
    _navigateToMap();
  }
}

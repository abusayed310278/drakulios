import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';
import '../../../core/language/translation_scope.dart';
import 'package:flutter/services.dart';

import '../../home/view/current_training_plans_screen.dart';
import '../../home/view/home_menu_screen.dart';
import '../../notifications/view/notification_screen.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';
import '../../profile/view/member_profile_screen.dart';
import '../../shop/view/shop_screen.dart';

enum AppShellTab { profile, notifications, shop, trainings, home }

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key, this.initialTab = AppShellTab.home, this.initialTrainingDestination});

  final AppShellTab initialTab;
  final PaymentFlowDestination? initialTrainingDestination;

  static AppShellTab tabForFlowDestination(PaymentFlowDestination destination) {
    switch (destination) {
      case PaymentFlowDestination.shop:
        return AppShellTab.shop;
      case PaymentFlowDestination.onlineCoaching:
      case PaymentFlowDestination.trainingPlan:
      case PaymentFlowDestination.personalTraining:
        return AppShellTab.trainings;
      case PaymentFlowDestination.homeMenu:
        return AppShellTab.home;
    }
  }

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  static const List<AppShellTab> _tabsInOrder = <AppShellTab>[
    AppShellTab.home,
    AppShellTab.trainings,
    AppShellTab.shop,
    AppShellTab.notifications,
    AppShellTab.profile,
  ];

  final Map<AppShellTab, GlobalKey<NavigatorState>> _navigatorKeys = <AppShellTab, GlobalKey<NavigatorState>>{
    for (final tab in _tabsInOrder) tab: GlobalKey<NavigatorState>(),
  };

  late AppShellTab _currentTab;
  final Set<AppShellTab> _initializedTabs = <AppShellTab>{};

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _initializedTabs.add(_currentTab);
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentTab]?.currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    if (_currentTab != AppShellTab.home) {
      setState(() => _currentTab = AppShellTab.home);
      return false;
    }

    return true;
  }

  void _popTabToRoot(AppShellTab tab) {
    final navigator = _navigatorKeys[tab]?.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  void _selectTab(AppShellTab tab) {
    if (_currentTab == tab) {
      _popTabToRoot(tab);
      return;
    }

    setState(() {
      _currentTab = tab;
      _initializedTabs.add(tab);
    });
    if (tab == AppShellTab.home || tab == AppShellTab.trainings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _popTabToRoot(tab);
      });
    }
  }

  Widget _rootForTab(AppShellTab tab) {
    switch (tab) {
      case AppShellTab.profile:
        return const MemberProfileScreen(showBackButton: false);
      case AppShellTab.notifications:
        return const NotificationScreen(showBackButton: false);
      case AppShellTab.shop:
        return const ShopScreen();
      case AppShellTab.trainings:
        return CurrentTrainingPlansScreen(
          showBackButton: false,
          preferredDestination: widget.initialTrainingDestination,
          autoOpenOwnedPlan: true,
        );
      case AppShellTab.home:
        return const HomeMenuScreen();
    }
  }

  Widget _buildTabNavigator(AppShellTab tab) {
    return Navigator(
      key: _navigatorKeys[tab],
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => _rootForTab(tab)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onWillPop().then((shouldPop) {
          if (shouldPop) {
            SystemNavigator.pop();
          }
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050608),
        body: IndexedStack(
          index: _tabsInOrder.indexOf(_currentTab),
          children: _tabsInOrder
              .map(
                (tab) => _initializedTabs.contains(tab)
                    ? TranslationScope(
                        enabled: _currentTab == tab,
                        child: _buildTabNavigator(tab),
                      )
                    : const SizedBox.shrink(),
              )
              .toList(),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: _PersistentBottomNavigationBar(currentTab: _currentTab, onTabTap: _selectTab),
        ),
      ),
    );
  }
}

class _PersistentBottomNavigationBar extends StatelessWidget {
  const _PersistentBottomNavigationBar({required this.currentTab, required this.onTabTap});

  final AppShellTab currentTab;
  final ValueChanged<AppShellTab> onTabTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1118),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1F2737), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 28,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFFF2B31A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomNavAction(label: 'Home', icon: Icons.home_rounded, selected: currentTab == AppShellTab.home, onTap: () => onTabTap(AppShellTab.home)),
          _BottomNavAction(label: 'Trainings', icon: Icons.fitness_center_rounded, selected: currentTab == AppShellTab.trainings, onTap: () => onTabTap(AppShellTab.trainings)),
          _BottomNavAction(label: 'Shopping', icon: Icons.shopping_bag_rounded, selected: currentTab == AppShellTab.shop, onTap: () => onTabTap(AppShellTab.shop)),
          _BottomNavAction(label: 'Notifications', icon: Icons.notifications_rounded, selected: currentTab == AppShellTab.notifications, onTap: () => onTabTap(AppShellTab.notifications)),
          _BottomNavAction(label: 'Profile', icon: Icons.person_rounded, selected: currentTab == AppShellTab.profile, onTap: () => onTabTap(AppShellTab.profile)),
        ],
      ),
    );
  }
}

class _BottomNavAction extends StatelessWidget {
  const _BottomNavAction({required this.label, required this.icon, required this.onTap, this.selected = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  static const _gold = Color(0xFFF2B31A);
  static const _grey = Color(0xFF4B5568);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: selected
                  ? BoxDecoration(
                      color: _gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: selected ? 23 : 21,
                color: selected ? _gold : _grey,
              ),
            ),
            const SizedBox(height: 4),
            TranslatedText(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? _gold : _grey,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 3 : 0,
              decoration: const BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

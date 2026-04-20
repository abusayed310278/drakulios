import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../home/views/current_training_plans_screen.dart';
import '../../home/views/home_menu_screen.dart';
import '../../notifications/views/notification_screen.dart';
import '../../paymentandsubscription/views/payment_flow_destination.dart';
import '../../profile/views/member_profile_screen.dart';
import '../../shop/views/shopping_cart_screen.dart';

enum AppShellTab { profile, notifications, cart, trainings, home }

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    this.initialTab = AppShellTab.home,
    this.initialTrainingDestination,
  });

  final AppShellTab initialTab;
  final PaymentFlowDestination? initialTrainingDestination;

  static AppShellTab tabForFlowDestination(PaymentFlowDestination destination) {
    switch (destination) {
      case PaymentFlowDestination.shop:
        return AppShellTab.cart;
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
    AppShellTab.cart,
    AppShellTab.notifications,
    AppShellTab.profile,
  ];

  final Map<AppShellTab, GlobalKey<NavigatorState>> _navigatorKeys =
      <AppShellTab, GlobalKey<NavigatorState>>{
        for (final tab in _tabsInOrder) tab: GlobalKey<NavigatorState>(),
      };

  late AppShellTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
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

    setState(() => _currentTab = tab);
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
      case AppShellTab.cart:
        return const ShoppingCartScreen(showBackButton: false);
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
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => _rootForTab(tab)),
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
          children: _tabsInOrder.map(_buildTabNavigator).toList(),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: _PersistentBottomNavigationBar(
            currentTab: _currentTab,
            onTabTap: _selectTab,
          ),
        ),
      ),
    );
  }
}

class _PersistentBottomNavigationBar extends StatelessWidget {
  const _PersistentBottomNavigationBar({
    required this.currentTab,
    required this.onTabTap,
  });

  final AppShellTab currentTab;
  final ValueChanged<AppShellTab> onTabTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0D12),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        children: [
          _BottomNavAction(
            label: 'Main Page',
            icon: Icons.home_outlined,
            selected: currentTab == AppShellTab.home,
            onTap: () => onTabTap(AppShellTab.home),
          ),
          _BottomNavAction(
            label: 'My Trainings',
            icon: Icons.fitness_center_outlined,
            selected: currentTab == AppShellTab.trainings,
            onTap: () => onTabTap(AppShellTab.trainings),
          ),
          _BottomNavAction(
            label: 'Shopping Cart',
            icon: Icons.shopping_cart_outlined,
            selected: currentTab == AppShellTab.cart,
            onTap: () => onTabTap(AppShellTab.cart),
          ),
          _BottomNavAction(
            label: 'Notifications',
            icon: Icons.notifications_none_rounded,
            selected: currentTab == AppShellTab.notifications,
            onTap: () => onTabTap(AppShellTab.notifications),
          ),
          _BottomNavAction(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selected: currentTab == AppShellTab.profile,
            onTap: () => onTabTap(AppShellTab.profile),
          ),
        ],
      ),
    );
  }
}

class _BottomNavAction extends StatelessWidget {
  const _BottomNavAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF1A3F77)
                  : const Color(0xFF131821),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2C6CFF)
                    : const Color(0xFF2A3241),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : const Color(0xFFF2B31A),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFE4E7EC),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

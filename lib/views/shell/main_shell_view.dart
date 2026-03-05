import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartssheets_app/views/home/home_view.dart';
import '../../core/responsive/size_config.dart';
import '../../core/ui_components/app_bottom_bar.dart';
import '../../l10n/strings.dart';
import '../../viewmodels/home_view_model.dart';
import '../appointments/appointments_view.dart';
import '../members/members_view.dart';
import '../profile/profile_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  // Active page index — center FAB (2) is not a page
  // Mapping: 0=Home, 1=Appointments, [2=FAB], 3=Members, 4=Profile
  // Page stack indices: 0=Home, 1=Appointments, 2=Members, 3=Profile
  int _pageIndex = 0;

  // Maps bar index → page index (excluding FAB at 2)
  static const Map<int, int> _barToPage = {
    0: 0, // Home
    1: 1, // Appointments
    3: 2, // Members
    4: 3, // Profile
  };

  static final List<Widget> _pages = [
    HomeView(),
    const AppointmentsView(),
    const MembersView(),
    const ProfileView(),
  ];

  void _onBarTap(int barIndex) {
    if (barIndex == 2) {
      // Center FAB — feature coming soon
      final l10n = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.navComingSoon),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final page = _barToPage[barIndex];
    if (page != null && page != _pageIndex) {
      setState(() => _pageIndex = page);
    }
  }

  int get _activeBarIndex {
    switch (_pageIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final l10n = AppStrings.of(context);

    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..init(),
      child: Builder(
        builder: (ctx) {
          return Scaffold(
            body: IndexedStack(
              index: _pageIndex,
              children: _pages,
            ),
            bottomNavigationBar: AppBottomBar(
              currentIndex: _activeBarIndex,
              centerIndex: 2,
              onTap: _onBarTap,
              items: [
                AppBottomBarItem(
                  activeIcon: Icons.home_rounded,
                  inactiveIcon: Icons.home_outlined,
                  label: l10n.navHome,
                ),
                AppBottomBarItem(
                  activeIcon: Icons.calendar_month_rounded,
                  inactiveIcon: Icons.calendar_month_outlined,
                  label: l10n.navAppointments,
                ),
                AppBottomBarItem(
                  activeIcon: Icons.add_rounded,
                  inactiveIcon: Icons.add_rounded,
                  label: '',
                ),
                AppBottomBarItem(
                  activeIcon: Icons.people_rounded,
                  inactiveIcon: Icons.people_outline_rounded,
                  label: l10n.navMembers,
                ),
                AppBottomBarItem(
                  activeIcon: Icons.person_rounded,
                  inactiveIcon: Icons.person_outline_rounded,
                  label: l10n.navProfile,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

enum NavDestination { moments, kept, settings }

/// Adaptive navigation destination model.
class NavItem {
  final NavDestination destination;
  final String label;
  final IconData icon;

  const NavItem({
    required this.destination,
    required this.label,
    required this.icon,
  });

  static const List<NavItem> items = [
    NavItem(
      destination: NavDestination.moments,
      label: 'Moments',
      icon: AppIcons.navMoments,
    ),
    NavItem(
      destination: NavDestination.kept,
      label: 'Kept',
      icon: AppIcons.navKept,
    ),
    NavItem(
      destination: NavDestination.settings,
      label: 'Settings',
      icon: AppIcons.navSettings,
    ),
  ];
}

/// Adaptive navigation controller rendering BottomNav on phones (< 600dp)
/// and NavigationRail on tablets (>= 600dp).
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.3.
class KeevaBottomNavBar extends StatelessWidget {
  final NavDestination activeDestination;
  final ValueChanged<NavDestination> onDestinationSelected;

  const KeevaBottomNavBar({
    super.key,
    required this.activeDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: activeDestination.index,
      onDestinationSelected: (index) {
        if (index != activeDestination.index) {
          HapticFeedback.selectionClick();
          onDestinationSelected(NavDestination.values[index]);
        }
      },
      backgroundColor: AppColors.darkSurfaceLevel0,
      indicatorColor: AppColors.darkPrimaryContainer,
      elevation: 0,
      height: 64,
      destinations: NavItem.items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(item.icon, color: AppColors.darkPrimary),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class KeevaNavRail extends StatelessWidget {
  final NavDestination activeDestination;
  final ValueChanged<NavDestination> onDestinationSelected;
  final bool isExpanded;

  const KeevaNavRail({
    super.key,
    required this.activeDestination,
    required this.onDestinationSelected,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: activeDestination.index,
      onDestinationSelected: (index) {
        if (index != activeDestination.index) {
          HapticFeedback.selectionClick();
          onDestinationSelected(NavDestination.values[index]);
        }
      },
      extended: isExpanded,
      minWidth: 80,
      minExtendedWidth: 220,
      labelType: isExpanded ? null : NavigationRailLabelType.all,
      backgroundColor: AppColors.darkSurfaceLevel0,
      indicatorColor: AppColors.darkPrimaryContainer,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20),
        child: Text(
          isExpanded ? 'Keeva' : 'K',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      destinations: NavItem.items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon, color: AppColors.darkTextSecondary),
          selectedIcon: Icon(item.icon, color: AppColors.darkPrimary),
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}

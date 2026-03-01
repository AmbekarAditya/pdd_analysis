import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class NavContent extends StatelessWidget {
  final String userRole;
  final bool isSidebar;

  const NavContent({
    super.key, 
    this.userRole = 'Admin',
    this.isSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        if (!isSidebar)
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/en/thumb/4/45/IR_Logo.png/220px-IR_Logo.png',
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.train,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        if (isSidebar) const SizedBox(height: 48),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                title: 'Dashboard',
                route: '/dashboard',
                isActive: currentRoute == '/dashboard',
              ),
              _buildNavItem(
                context,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                title: 'Daily PDD Analysis',
                route: '/analysis',
                isActive: currentRoute == '/analysis',
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle_outline,
                activeIcon: Icons.add_circle,
                title: 'Add New Record',
                route: '/train-record/new',
                isActive: currentRoute == '/train-record/new',
              ),
              _buildNavItem(
                context,
                icon: Icons.train_outlined,
                activeIcon: Icons.train,
                title: 'Train Records',
                route: '/train-records',
                isActive: currentRoute == '/train-records',
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                title: 'Profile',
                route: '/profile',
                isActive: currentRoute == '/profile',
              ),
              if (userRole == 'Admin')
                _buildNavItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  title: 'Admin Panel',
                  route: '/settings',
                  isActive: currentRoute == '/settings',
                ),
            ],
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        _buildNavItem(
          context,
          icon: Icons.logout,
          activeIcon: Icons.logout,
          title: 'Log out',
          route: '/login',
          isActive: false,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon, 
        color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (!isActive) {
          context.go(route);
          if (!isSidebar) Scaffold.of(context).closeDrawer();
        }
      },
      tileColor: isActive ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : null,
      hoverColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

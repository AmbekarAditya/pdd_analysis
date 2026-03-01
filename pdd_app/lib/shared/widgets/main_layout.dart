import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/layout_providers.dart';
import 'app_drawer.dart';
import 'nav_content.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final appBarState = ref.watch(appBarProvider);

    return Scaffold(
      appBar: AppBar(
        leading: isDesktop ? const SizedBox.shrink() : null,
        title: Text(appBarState.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: appBarState.actions,
      ),
      drawer: isDesktop ? null : const AppDrawer(),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 280,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const NavContent(isSidebar: true),
            ),
          if (isDesktop)
            VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: appBarState.floatingActionButton,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarState {
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppBarState({
    required this.title,
    this.actions,
    this.floatingActionButton,
  });
}

class AppBarNotifier extends Notifier<AppBarState> {
  @override
  AppBarState build() {
    return const AppBarState(title: 'PDD Analysis');
  }

  void update({
    required String title,
    List<Widget>? actions,
    Widget? floatingActionButton,
  }) {
    state = AppBarState(
      title: title,
      actions: actions,
      floatingActionButton: floatingActionButton,
    );
  }
}

final appBarProvider = NotifierProvider<AppBarNotifier, AppBarState>(AppBarNotifier.new);

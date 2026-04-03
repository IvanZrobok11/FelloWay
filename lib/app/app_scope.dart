import 'package:flutter/material.dart';

import '../shared/network/api_client.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.apiClient, required super.child});

  final ApiClient apiClient;

  static ApiClient of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.apiClient;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) =>
      oldWidget.apiClient != apiClient;
}

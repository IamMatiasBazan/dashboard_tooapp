import 'package:flutter/material.dart';

enum AsyncViewState { loading, empty, error, success, unavailable, forbidden }

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    required this.state,
    required this.child,
    this.message,
    this.onRetry,
    super.key,
  });
  final AsyncViewState state;
  final Widget child;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (state == AsyncViewState.success) return child;
    final content = switch (state) {
      AsyncViewState.loading => const CircularProgressIndicator(),
      AsyncViewState.empty => const Text('No hay datos para mostrar.'),
      AsyncViewState.error => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message ?? 'No se pudo cargar la información.'),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
      AsyncViewState.unavailable => Text(message ?? 'Dato no disponible.'),
      AsyncViewState.forbidden => const Text(
        'No tienes permiso para consultar esta información.',
      ),
      AsyncViewState.success => child,
    };
    return Center(child: Semantics(liveRegion: true, child: content));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'connectivity_provider.dart';

class OfflineBannerWrapper extends ConsumerWidget {
  final Widget child;

  const OfflineBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(connectivityProvider);

    // Default to online if loading, only show banner when definitively false
    final isOffline = isOnlineAsync.value == false;

    return Stack(
      children: [
        child,
        if (isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.redAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Mode hors-ligne — vos modifications seront synchronisées',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -1.0, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
      ],
    );
  }
}

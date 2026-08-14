import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Initial check
  final initialResult = await connectivity.checkConnectivity();
  yield !initialResult.contains(ConnectivityResult.none);

  // Listen to changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield !results.contains(ConnectivityResult.none);
  }
});

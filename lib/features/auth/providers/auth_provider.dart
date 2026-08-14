import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../data/models/user_model.dart';

// Stream of Firebase Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// FutureProvider to fetch the current user's profile from Firestore
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  if (authState.value == null) {
    return null;
  }
  
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getUser(authState.value!.uid);
});

// A provider that determines the current role (derived from the profile)
final currentUserRoleProvider = Provider<String?>((ref) {
  final profileState = ref.watch(currentUserProfileProvider);
  return profileState.value?.role;
});

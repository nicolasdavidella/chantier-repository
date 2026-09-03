import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../data/project_repository.dart';

final clientProjectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  if (authState.value == null) {
    return const Stream.empty();
  }
  
  final projectRepository = ref.watch(projectRepositoryProvider);
  return projectRepository.getClientProjects(authState.value!.uid);
});

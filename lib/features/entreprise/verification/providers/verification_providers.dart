import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/verification_request_model.dart';
import '../data/verification_repository.dart';

// StreamProvider pour écouter en temps réel les changements de la demande
final currentVerificationRequestProvider = StreamProvider.family<VerificationRequestModel?, String>((ref, entrepriseId) {
  final repository = ref.watch(verificationRepositoryProvider);
  return repository.watchActiveRequest(entrepriseId);
});

class VerificationController extends StateNotifier<AsyncValue<void>> {
  final VerificationRepository _repository;

  VerificationController(this._repository) : super(const AsyncValue.data(null));

  Future<VerificationRequestModel> getOrCreateDraft(String entrepriseId) async {
    state = const AsyncValue.loading();
    try {
      final request = await _repository.getOrCreateDraftRequest(entrepriseId);
      state = const AsyncValue.data(null);
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> submitRequest(String requestId, String entrepriseId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitRequest(requestId, entrepriseId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final verificationControllerProvider = StateNotifierProvider<VerificationController, AsyncValue<void>>((ref) {
  final repository = ref.watch(verificationRepositoryProvider);
  return VerificationController(repository);
});

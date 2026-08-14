class FirebaseErrors {
  static String getMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet e-mail.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé par un autre compte.';
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'weak-password':
        return 'Le mot de passe fourni est trop faible.';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n\'est pas activée.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'invalid-verification-code':
        return 'Le code de vérification est invalide.';
      case 'invalid-verification-id':
        return 'L\'ID de vérification est invalide.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}

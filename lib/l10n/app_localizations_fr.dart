// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ChantierTrack';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Content de vous revoir !';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get emailEmptyError => 'Veuillez entrer votre e-mail';

  @override
  String get emailInvalidError => 'E-mail invalide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordEmptyError => 'Veuillez entrer votre mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get orText => 'OU';

  @override
  String get phoneLogin => 'Connexion par téléphone';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get adminAccess => 'Accès Administrateur';

  @override
  String get dashboardTitle => 'Tableau de Bord';

  @override
  String get projectsTab => 'Projets';

  @override
  String get messagesTab => 'Messages';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get profileLabel => 'Profil';

  @override
  String get heroTitle => 'Suivez vos chantiers\nfacilement';

  @override
  String get heroSubtitle =>
      'Trouvez les meilleurs prestataires pour réaliser\nvos projets de construction.';

  @override
  String get createProjectBtn => 'Créer un projet';

  @override
  String get searchHint => 'Rechercher une entreprise ou un projet...';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get logout => 'Se déconnecter';

  @override
  String welcomeMessage(String name) {
    return 'Bonjour, $name';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChantierTrack';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome back!';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get emailEmptyError => 'Please enter your email';

  @override
  String get emailInvalidError => 'Invalid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordEmptyError => 'Please enter your password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orText => 'OR';

  @override
  String get phoneLogin => 'Phone Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get adminAccess => 'Admin Access';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get projectsTab => 'Projects';

  @override
  String get messagesTab => 'Messages';

  @override
  String get settingsTab => 'Settings';

  @override
  String get profileLabel => 'Profile';

  @override
  String get heroTitle => 'Track your sites\neasily';

  @override
  String get heroSubtitle =>
      'Find the best contractors to build\nyour construction projects.';

  @override
  String get createProjectBtn => 'Create a project';

  @override
  String get searchHint => 'Search for a company or project...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get logout => 'Log out';

  @override
  String welcomeMessage(String name) {
    return 'Hello, $name';
  }
}

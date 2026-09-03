# ChantierTrack

ChantierTrack est une application Flutter innovante pour la gestion de chantiers, offrant un design luxueux et moderne. Elle permet aux clients et aux entreprises de suivre et gérer leurs projets de construction de manière fluide.

## Prérequis

- Flutter SDK `^3.11.1` ou supérieur
- Android Studio / Xcode
- Un projet Firebase configuré

## Installation

1. Clonez ce dépôt :
   ```bash
   git clone <repository_url>
   cd chantier_track
   ```

2. Installez les dépendances :
   ```bash
   flutter pub get
   ```

3. Générez les icônes de l'application et le splash screen :
   ```bash
   dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
   dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
   dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
   dart run flutter_native_splash:create --path=flutter_native_splash.yaml
   ```

## Configuration Firebase

Ce projet utilise FlutterFire. Vous devez configurer votre environnement Firebase pour chaque flavor :

1. Installez Firebase CLI et FlutterFire CLI.
2. Exécutez la configuration pour chaque environnement :
   ```bash
   flutterfire configure --project=chantier-track-dev --out=lib/firebase_options_dev.dart
   flutterfire configure --project=chantier-track-prod --out=lib/firebase_options_prod.dart
   ```
   *(Adaptez les identifiants de projet selon votre compte Firebase)*

## Lancer l'Application (Flavors)

L'application utilise des **Flavors** (variantes de build) pour séparer les environnements.

- **Développement (DEV) :**
  ```bash
  flutter run --flavor dev -t lib/main.dart
  ```
- **Staging (STG) :**
  ```bash
  flutter run --flavor staging -t lib/main.dart
  ```
- **Production (PROD) :**
  ```bash
  flutter run --flavor prod -t lib/main.dart
  ```
  
## Signature de l'Application (Release)

Pour générer un build de production (AAB/APK) :

1. Créez un keystore Android et placez-le en toute sécurité (ne le commitez jamais !).
2. Créez un fichier `android/key.properties` (ce fichier est ignoré par `.gitignore`) avec ce contenu :
   ```properties
   storePassword=votre_mot_de_passe
   keyPassword=votre_mot_de_passe
   keyAlias=upload
   storeFile=chemin/vers/votre/fichier.jks
   ```
3. Décommentez la section *Play Store Signing Configuration* dans `android/app/build.gradle.kts`.
4. Lancez le build :
   ```bash
   flutter build appbundle --flavor prod -t lib/main.dart
   ```

## Tests

Pour exécuter les tests unitaires et widgets :
```bash
flutter test
```

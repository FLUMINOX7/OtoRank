# 🚀 OtoRank# otorank_temp



Application mobile professionnelle compatible Android, iOS et Web développée avec Flutter.A new Flutter project.



## 📋 Table des matières## Getting Started



- [Description](#description)This project is a starting point for a Flutter application.

- [Architecture](#architecture)

- [Prérequis](#prérequis)A few resources to get you started if this is your first Flutter project:

- [Installation](#installation)

- [Structure du projet](#structure-du-projet)- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- [Conventions de code](#conventions-de-code)- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- [Gestion des branches](#gestion-des-branches)

- [Messages de commit](#messages-de-commit)For help getting started with Flutter development, view the

- [Commandes utiles](#commandes-utiles)[online documentation](https://docs.flutter.dev/), which offers tutorials,

- [Technologies utilisées](#technologies-utilisées)samples, guidance on mobile development, and a full API reference.


## 📱 Description

OtoRank est une application mobile moderne développée avec Flutter, suivant les meilleures pratiques et l'architecture Clean Architecture.

### Plateformes supportées
- ✅ Android
- ✅ iOS
- ✅ Web (support prévu)

## 🏗️ Architecture

Ce projet suit les principes de **Clean Architecture** et est organisé selon une approche **Feature-First**.

### Principes de Clean Architecture

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (UI, BLoC/Provider, Widgets, Pages)   │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│   (Entities, Use Cases, Repositories)   │
├─────────────────────────────────────────┤
│             Data Layer                  │
│ (Models, Data Sources, Repository Impl) │
└─────────────────────────────────────────┘
```

### Avantages
- ✅ **Séparation des responsabilités** : Chaque couche a un rôle bien défini
- ✅ **Testabilité** : Facile d'écrire des tests unitaires
- ✅ **Maintenabilité** : Code organisé et facile à maintenir
- ✅ **Scalabilité** : Facile d'ajouter de nouvelles fonctionnalités
- ✅ **Indépendance** : Les couches ne dépendent pas des détails d'implémentation

## ⚙️ Prérequis

- **Flutter SDK** : >= 3.24.0
- **Dart** : >= 3.5.0
- **Android Studio** / **Xcode** (pour Android/iOS)
- **Git**

### Vérifier votre installation

```bash
flutter doctor -v
```

## 🔧 Installation

### 1. Cloner le repository

```bash
git clone https://github.com/FLUMINOX7/OtoRank.git
cd OtoRank
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Exécuter l'application

```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Appareil spécifique
flutter devices
flutter run -d <device_id>
```

## 📂 Structure du projet

```
otorank/
├── lib/
│   ├── core/                      # Code partagé dans toute l'app
│   │   ├── constants/             # Constantes globales
│   │   ├── errors/                # Gestion des erreurs (Failures, Exceptions)
│   │   ├── network/               # Configuration réseau
│   │   ├── theme/                 # Thème de l'application
│   │   ├── utils/                 # Utilitaires (Logger, etc.)
│   │   └── widgets/               # Widgets réutilisables
│   │
│   ├── features/                  # Fonctionnalités (Feature-First)
│   │   └── home/                  # Exemple de feature
│   │       ├── data/              # Couche Data
│   │       │   ├── datasources/   # Sources de données (API, Cache)
│   │       │   ├── models/        # Modèles de données
│   │       │   └── repositories/  # Implémentation des repositories
│   │       ├── domain/            # Couche Domain (Logique métier)
│   │       │   ├── entities/      # Entités métier
│   │       │   ├── repositories/  # Interfaces des repositories
│   │       │   └── usecases/      # Cas d'utilisation
│   │       └── presentation/      # Couche Presentation (UI)
│   │           ├── bloc/          # State Management (BLoC)
│   │           ├── pages/         # Pages de l'app
│   │           └── widgets/       # Widgets spécifiques à la feature
│   │
│   ├── config/                    # Configuration de l'app
│   │   ├── routes/                # Gestion de la navigation
│   │   └── di/                    # Injection de dépendances
│   │
│   └── main.dart                  # Point d'entrée de l'application
│
├── test/                          # Tests unitaires
├── integration_test/              # Tests d'intégration
├── assets/                        # Ressources (images, fonts, etc.)
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── android/                       # Configuration Android
├── ios/                           # Configuration iOS
├── web/                           # Configuration Web
│
├── .gitignore
├── analysis_options.yaml          # Configuration du linter
├── pubspec.yaml                   # Dépendances Flutter
└── README.md
```

## 📝 Conventions de code

### Nommage

- **Fichiers** : `snake_case` (ex: `home_page.dart`)
- **Classes** : `PascalCase` (ex: `HomePage`)
- **Variables/Fonctions** : `camelCase` (ex: `getUserData`)
- **Constantes** : `camelCase` (ex: `maxRetries`)
- **Enums** : `PascalCase` avec valeurs en `camelCase`

### Organisation du code

- **1 classe = 1 fichier**
- **Imports groupés** : Flutter SDK → Packages → Projet
- **Widgets const** quand possible pour optimiser les performances
- **Documentation** : Commentaires `///` pour les APIs publiques

### Exemple

```dart
/// Récupère les données utilisateur depuis l'API
///
/// Retourne [Right(UserEntity)] en cas de succès
/// Retourne [Left(Failure)] en cas d'erreur
Future<Either<Failure, UserEntity>> getUserData(String userId) async {
  // Implémentation
}
```

## 🌿 Gestion des branches

### Convention de nommage

```
feature/nom-de-la-fonctionnalite    # Nouvelle fonctionnalité
bugfix/nom-du-bug                   # Correction de bug
hotfix/nom-correction-urgente       # Correction urgente en production
release/version                     # Préparation d'une release
```

### Workflow

1. **Créer une branche** depuis `develop`
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/nouvelle-fonctionnalite
   ```

2. **Développer** et **tester** localement

3. **Pousser** la branche
   ```bash
   git push origin feature/nouvelle-fonctionnalite
   ```

4. **Créer une Pull Request** vers `develop`

5. **Review** et **merge**

## 💬 Messages de commit

Nous suivons la convention **Conventional Commits**.

### Format

```
<type>(<scope>): <description>

[corps optionnel]

[footer optionnel]
```

### Types

- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage, point-virgules manquants, etc.
- `refactor` : Refactorisation du code
- `test` : Ajout ou modification de tests
- `chore` : Tâches de maintenance (dépendances, config, etc.)
- `perf` : Amélioration des performances
- `ci` : Configuration CI/CD

### Exemples

```bash
feat(auth): add login with Google
fix(home): correct data loading issue
docs(readme): update installation instructions
refactor(core): simplify error handling
test(auth): add unit tests for login usecase
chore(deps): update dependencies to latest versions
```

### Scope (optionnel)

Le scope indique quelle partie du projet est affectée :
- `auth`, `home`, `profile`, `settings` (features)
- `core`, `config` (modules)
- `ui`, `api` (couches)

## 🛠️ Commandes utiles

### Développement

```bash
# Lancer l'app
flutter run

# Hot reload (pendant l'exécution)
# Appuyez sur 'r' dans le terminal

# Hot restart (pendant l'exécution)
# Appuyez sur 'R' dans le terminal

# Mode release
flutter run --release
```

### Analyse et qualité du code

```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Vérifier le formatage sans modifier
flutter format --set-exit-if-changed .
```

### Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Tests d'intégration
flutter drive --driver=test_driver/integration_test.dart \
              --target=integration_test/app_test.dart
```

### Build

```bash
# Android APK
flutter build apk

# Android App Bundle (pour Play Store)
flutter build appbundle

# iOS (nécessite macOS)
flutter build ios

# Web
flutter build web
```

### Nettoyage

```bash
# Nettoyer les builds
flutter clean

# Récupérer les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade
```

## 🔧 Technologies utilisées

### Core
- **Flutter** : Framework UI cross-platform
- **Dart** : Langage de programmation

### Architecture & Patterns
- **Clean Architecture** : Séparation des couches
- **BLoC Pattern** : State Management (à implémenter)
- **Repository Pattern** : Abstraction des sources de données

### Packages principaux

```yaml
# Gestion d'état (à décommenter)
# flutter_bloc: ^8.1.3

# Injection de dépendances (à décommenter)
# get_it: ^7.6.4

# Programmation fonctionnelle
dartz: ^0.10.1
equatable: ^2.0.5

# Network (à décommenter)
# http: ^1.1.0
# dio: ^5.4.0

# Stockage local (à décommenter)
# shared_preferences: ^2.2.2
```

## 👥 Contributeurs

- **FLUMINOX7** - Développeur principal

## 📄 Licence

Ce projet est privé et propriétaire.

---

**Made with ❤️ using Flutter**

# Guide de contribution - OtoRank

Merci de votre intérêt pour contribuer à OtoRank ! Ce document vous guide à travers le processus de contribution.

## 🚀 Démarrage rapide

1. **Fork** le projet
2. **Clone** votre fork
3. **Créer une branche** depuis `develop`
4. **Développer** votre fonctionnalité ou correction
5. **Tester** vos modifications
6. **Commit** avec des messages conventionnels
7. **Push** votre branche
8. **Créer une Pull Request**

## 📋 Workflow de développement

### 1. Configuration initiale

```bash
# Cloner votre fork
git clone https://github.com/VOTRE_USERNAME/OtoRank.git
cd OtoRank

# Ajouter le repository original comme remote
git remote add upstream https://github.com/FLUMINOX7/OtoRank.git

# Installer les dépendances
flutter pub get
```

### 2. Créer une branche

Toujours créer une branche depuis `develop` :

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/ma-nouvelle-fonctionnalite
```

### 3. Conventions de nommage des branches

- `feature/` : Nouvelles fonctionnalités
- `bugfix/` : Corrections de bugs
- `hotfix/` : Corrections urgentes
- `refactor/` : Refactorisation de code
- `docs/` : Documentation uniquement
- `test/` : Ajout ou modification de tests

**Exemples :**
```
feature/user-authentication
bugfix/login-crash
hotfix/security-patch
refactor/home-screen-performance
docs/api-documentation
test/auth-unit-tests
```

## 💬 Messages de commit

Nous utilisons la convention **Conventional Commits**.

### Format

```
<type>(<scope>): <description courte>

[corps optionnel]

[footer optionnel]
```

### Types

- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage (pas de changement de code)
- `refactor` : Refactorisation
- `perf` : Amélioration des performances
- `test` : Ajout/modification de tests
- `build` : Changements du système de build
- `ci` : Changements CI/CD
- `chore` : Maintenance

### Exemples

```bash
# Bons exemples
git commit -m "feat(auth): add Google authentication"
git commit -m "fix(home): resolve data loading issue"
git commit -m "docs(readme): update installation steps"
git commit -m "refactor(core): simplify error handling"
git commit -m "test(auth): add unit tests for login"

# Avec un corps
git commit -m "feat(profile): add user profile editing

- Add profile edit form
- Implement image upload
- Add validation logic

Closes #123"
```

### Breaking Changes

Si votre commit introduit un changement incompatible :

```bash
git commit -m "feat(api)!: change authentication endpoint

BREAKING CHANGE: The /auth endpoint now requires a Bearer token"
```

## ✅ Checklist avant de soumettre

Avant de créer une Pull Request, assurez-vous que :

- [ ] Le code compile sans erreurs (`flutter run`)
- [ ] L'analyse statique passe (`flutter analyze`)
- [ ] Le code est formaté (`flutter format .`)
- [ ] Les tests passent (`flutter test`)
- [ ] La documentation est à jour
- [ ] Les commits suivent les conventions
- [ ] La branche est à jour avec `develop`

### Commandes de vérification

```bash
# Analyse du code
flutter analyze

# Formater le code
flutter format .

# Lancer les tests
flutter test

# Build (vérification)
flutter build apk --debug
```

## 📝 Standards de code

### Dart/Flutter

- Utiliser `const` quand possible
- Préférer les `final` aux `var`
- Documenter les APIs publiques avec `///`
- Limiter la longueur des fonctions (< 50 lignes)
- Un fichier = une classe principale

### Organisation des imports

```dart
// 1. Imports Dart/Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Imports de packages
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';

// 3. Imports relatifs du projet
import '../../core/errors/failures.dart';
import '../entities/user.dart';
```

### Nommage

```dart
// Classes : PascalCase
class UserProfile {}

// Fichiers : snake_case
// user_profile.dart

// Variables/Méthodes : camelCase
final String userName = 'John';
void getUserData() {}

// Constantes : camelCase
const int maxAttempts = 3;

// Enums : PascalCase avec valeurs camelCase
enum UserRole { admin, user, guest }
```

## 🏗️ Architecture

Respecter l'architecture Clean Architecture du projet :

```
lib/
├── core/           # Partagé dans toute l'app
├── features/       # Fonctionnalités
│   └── feature/
│       ├── data/        # Couche Data
│       ├── domain/      # Couche Domain
│       └── presentation/  # Couche Presentation
└── config/         # Configuration
```

### Principes

1. **Domain** ne dépend de rien
2. **Data** implémente **Domain**
3. **Presentation** utilise **Domain**
4. Les dépendances vont vers l'intérieur

## 🧪 Tests

### Structure

```
test/
├── core/
│   ├── errors/
│   └── utils/
└── features/
    └── home/
        ├── data/
        ├── domain/
        └── presentation/
```

### Exemples

```dart
// Test unitaire
test('should return data when call is successful', () async {
  // Arrange
  when(mockDataSource.getData())
      .thenAnswer((_) async => testData);
  
  // Act
  final result = await repository.getData();
  
  // Assert
  expect(result, Right(testData));
});

// Test de widget
testWidgets('should display loading indicator', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 🔍 Pull Request

### Titre

Format : `<type>(<scope>): <description>`

Exemples :
- `feat(auth): add Google authentication`
- `fix(home): resolve data loading crash`
- `docs(readme): update contributing guide`

### Description

Incluez :

1. **Quel problème cela résout-il ?**
2. **Comment l'avez-vous résolu ?**
3. **Comment tester ?**
4. **Screenshots** (si applicable)
5. **Breaking changes** (si applicable)

### Template

```markdown
## Description
Brief description of changes

## Type de changement
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code compilé sans erreurs
- [ ] Tests passent
- [ ] Documentation mise à jour
- [ ] Commits suivent les conventions

## Tests effectués
Describe how you tested this

## Screenshots (si applicable)
Add screenshots here
```

## 📖 Ressources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## ❓ Questions

Si vous avez des questions, n'hésitez pas à :

1. Ouvrir une **Issue**
2. Consulter la **Documentation**
3. Contacter l'équipe

## 📄 Licence

En contribuant, vous acceptez que vos contributions soient sous la même licence que le projet.

---

**Merci de contribuer à OtoRank ! 🎉**

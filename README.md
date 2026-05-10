# OtoRank

OtoRank est une application Flutter multi-plateforme orientee musique et productivite, avec un socle technique structure pour evoluer proprement dans la duree.

Le projet est concu pour Android, iOS et Web, avec une architecture modulaire par fonctionnalite.

## Apercu

L'application regroupe plusieurs modules fonctionnels dans une base unique:

- lecteur musical local
- edition audio
- telechargement depuis YouTube
- prise de notes
- minuteur Tabata

## Stack technique

- Flutter
- Dart
- Architecture Clean + organisation Feature-First
- BLoC (sur les modules concernes)

## Prerequis

- Flutter SDK (version recommandee: 3.24+)
- Dart SDK (version recommandee: 3.5+)
- Android Studio et/ou Xcode selon la cible

Verification rapide:

```bash
flutter doctor -v
```

## Installation

```bash
git clone https://github.com/FLUMINOX7/OtoRank.git
cd OtoRank
flutter pub get
```

## Lancer le projet

```bash
# Cible active (emulateur ou appareil)
flutter run

# Web
flutter run -d chrome

# Liste des appareils detectes
flutter devices
```

## Qualite et tests

```bash
# Analyse statique
flutter analyze

# Tests
flutter test

# Build Android (debug)
flutter build apk --debug
```

## Structure du depot

```text
OtoRank/
├── lib/
│   ├── config/
│   ├── core/
│   ├── features/
│   │   ├── audio_editor/
│   │   ├── home/
│   │   ├── music_player/
│   │   ├── notes/
│   │   ├── tabata_timer/
│   │   └── youtube_downloader/
│   ├── shared/
│   └── main.dart
├── assets/
├── android/
├── ios/
├── web/
├── test/
├── analysis_options.yaml
└── pubspec.yaml
```

## Principes d'architecture

- Separation claire entre logique metier, donnees et presentation
- Decoupage par fonctionnalite pour limiter le couplage
- Composants partages centralises dans `core` et `shared`
- Base adaptee a l'ajout progressif de nouvelles fonctionnalites


## Etat du projet

Le projet est en developpement actif. Les evolutions et stabilisations sont publiees progressivement.
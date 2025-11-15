# Tests du Music Player - OtoRank

## Résumé des tests

✅ **35 tests passés avec succès !**

## Tests implémentés

### 1. Tests de gestion de queue (`queue_management_test.dart`)
- ✅ Queue vide au démarrage
- ✅ Ajout de chansons à la queue
- ✅ Réordonnancement des chansons (drag & drop)
- ✅ Suppression de chansons individuelles
- ✅ Effacement complet de la queue
- ✅ Gestion des cas limites (suppression du dernier élément, réordonnancement aux limites)
- ✅ Liste non-modifiable (getCurrentQueue)

### 2. Tests de recherche (`search_test.dart`)
- ✅ Recherche par titre
- ✅ Recherche par artiste  
- ✅ Recherche globale (titre + artiste)
- ✅ Recherche insensible à la casse
- ✅ Requête vide retourne toutes les chansons
- ✅ Terme non trouvé retourne liste vide
- ✅ Filtres fonctionnels (All, Title, Artist)

### 3. Tests de l'égaliseur (`equalizer_test.dart`)
- ✅ Initialisation à 0.0 dB (Flat)
- ✅ Preset Bass Boost
- ✅ Preset Treble Boost
- ✅ Valeurs dans la plage [-12, +12] dB
- ✅ Reset à 0.0 dB
- ✅ Preset Rock avec valeurs spécifiques
- ✅ 10 bandes de fréquences (60Hz à 16kHz)
- ✅ Gestion des valeurs négatives

### 4. Tests d'intégration (`integration_test.dart`)
- ✅ Workflow complet : Load → Play → Queue → Search
- ✅ Persistance de l'état du player
- ✅ Shuffle et repeat modes
- ✅ Navigation next/previous
- ✅ Application de presets d'égaliseur
- ✅ Gestion d'erreurs (queue vide, index invalide, null song)
- ✅ Manipulation complexe de queue multi-étapes

### 5. Tests d'unicité d'état (`state_uniqueness_test.dart`)
**Tests critiques pour le fix du bug "clear queue only works first time"**

- ✅ MusicPlayerInitial a un champ timestamp
- ✅ MusicPlayerStopped a un champ timestamp
- ✅ Timestamp inclus dans props (Equatable)
- ✅ Timestamp en millisecondes depuis epoch
- ✅ États créés en séquence ont timestamps croissants
- ✅ Validation du fix pour clear queue multiple
- ✅ Vérification de la différenciation d'états basée sur timestamp

## Comment exécuter les tests

### Tous les tests du music player
```bash
flutter test test/features/music_player/
```

### Tests spécifiques
```bash
# Queue management
flutter test test/features/music_player/queue_management_test.dart

# Search
flutter test test/features/music_player/search_test.dart

# Equalizer
flutter test test/features/music_player/equalizer_test.dart

# Integration
flutter test test/features/music_player/integration_test.dart

# State uniqueness (bug fix validation)
flutter test test/features/music_player/state_uniqueness_test.dart
```

### Tests avec rapport détaillé
```bash
flutter test test/features/music_player/ --reporter expanded
```

### Tests avec couverture
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
xdg-open coverage/html/index.html
```

## Couverture des tests

### Fonctionnalités testées
1. ✅ Gestion de queue (getCurrentQueue, reorder, remove, clear)
2. ✅ Recherche avec filtres (all, title, artist)
3. ✅ Égaliseur (10 bandes, 8 presets)
4. ✅ Workflows d'intégration complets
5. ✅ Fix du bug clear queue avec timestamps

### Ce qui reste à tester (optionnel)
- Tests BLoC avec mocktail (nécessitent ajustements)
- Tests de widgets UI (nécessitent flutter_test widgets)
- Tests end-to-end avec integration_test

## Bugs corrigés validés par les tests

### Bug: Clear queue ne marchait qu'une fois
**Symptôme**: Après avoir effacé la queue une première fois, impossible de l'effacer à nouveau ou de jouer des chansons.

**Cause**: `MusicPlayerInitial()` et `MusicPlayerStopped()` étaient const, donc multiples appels retournaient la même instance. Equatable ne détectait pas de changement d'état.

**Solution**: Ajout d'un champ `timestamp` initialisé avec `DateTime.now().millisecondsSinceEpoch` dans les constructeurs. Ce timestamp est inclus dans `props`, forçant Equatable à considérer chaque instance comme unique.

**Validation**: 
- ✅ `state_uniqueness_test.dart` vérifie la présence du timestamp
- ✅ `state_uniqueness_test.dart` vérifie l'inclusion dans props
- ✅ `integration_test.dart` teste le workflow de clear queue multiple

## Notes techniques

### Dépendances de test
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7  # Pour tester les BLoCs
  mocktail: ^1.0.4   # Pour créer des mocks
```

### Structure des tests
```
test/features/music_player/
├── queue_management_test.dart  # Tests unitaires queue
├── search_test.dart           # Tests unitaires recherche
├── equalizer_test.dart        # Tests unitaires égaliseur
├── integration_test.dart      # Tests d'intégration
├── state_uniqueness_test.dart # Tests du fix timestamp
└── music_player_bloc_test.dart # Tests BLoC (à améliorer)
```

## Prochaines étapes

1. **Tests manuels sur appareil**
   - Tester queue management sur Samsung Galaxy A23
   - Tester recherche avec vraies chansons
   - Tester égaliseur avec audio

2. **Tests d'interface**
   - Widget tests pour QueuePage
   - Widget tests pour SearchPage
   - Widget tests pour EqualizerPage

3. **Tests BLoC**
   - Corriger les tests BLoC existants
   - Ajouter tests pour tous les events/states

4. **Couverture de code**
   - Viser 80%+ de couverture
   - Identifier zones non testées

# Documentation Architecture – Module Music Player

## Structure principale

```
lib/
└── features/
    └── music_player/
        ├── domain/
        │   ├── entities/
        │   │   └── song.dart
        │   ├── repositories/
        │   │   └── audio_player_repository.dart
        │   └── usecases/
        │       ├── get_local_songs.dart
        │       ├── play_song.dart
        │       └── load_playlist.dart
        ├── data/
        │   └── datasources/
        │       └── player_state_local_data_source.dart
        ├── presentation/
        │   ├── bloc/
        │   │   ├── music_player_bloc.dart
        │   │   ├── music_player_event.dart
        │   │   ├── music_player_state.dart
        │   │   ├── playlist_bloc.dart
        │   │   └── playlist_event.dart
        │   ├── pages/
        │   │   ├── music_player_page.dart
        │   │   ├── full_player_page.dart
        │   │   ├── queue_page.dart
        │   │   └── search_page.dart
        │   └── widgets/
        │       ├── mini_player_widget.dart
        │       ├── song_list_widget.dart
        │       ├── playlist_list_widget.dart
        │       └── ... (autres widgets)
        └── di/
            └── music_player_injection.dart
```

---

## Détail et rôle de chaque fichier

### 1. **domain/entities/song.dart**
- **Rôle** : Définit le modèle de données d’une chanson (id, titre, artiste, etc.).
- **Utilité** : Sert de structure commune pour manipuler les chansons dans toute l’application.

### 2. **domain/repositories/audio_player_repository.dart**
- **Rôle** : Interface abstraite pour les opérations du lecteur audio (play, pause, queue, etc.).
- **Utilité** : Permet de séparer la logique métier de l’implémentation technique.

### 3. **domain/usecases/get_local_songs.dart**
- **Rôle** : Cas d’usage pour récupérer la liste des chansons locales.
- **Utilité** : Centralise la logique d’accès aux fichiers audio.

### 4. **domain/usecases/play_song.dart**
- **Rôle** : Cas d’usage pour lancer la lecture d’une chanson.
- **Utilité** : Encapsule la logique de démarrage de la lecture.

### 5. **domain/usecases/load_playlist.dart**
- **Rôle** : Cas d’usage pour charger une playlist et démarrer la lecture.
- **Utilité** : Gère la logique de lecture séquentielle d’une liste de chansons.

### 6. **data/datasources/player_state_local_data_source.dart**
- **Rôle** : Source de données locale pour sauvegarder/restaurer l’état du lecteur.
- **Utilité** : Permet de reprendre la lecture là où l’utilisateur s’est arrêté.

### 7. **presentation/bloc/music_player_bloc.dart**
- **Rôle** : BLoC principal pour gérer l’état du lecteur de musique (lecture, pause, queue, etc.).
- **Utilité** : Centralise la gestion des événements et des états du player.

### 8. **presentation/bloc/music_player_event.dart**
- **Rôle** : Définition des événements du BLoC (PlaySongEvent, PauseEvent, etc.).
- **Utilité** : Permet de déclencher des actions dans le BLoC.

### 9. **presentation/bloc/music_player_state.dart**
- **Rôle** : Définition des états possibles du BLoC (Playing, Paused, Stopped, etc.).
- **Utilité** : Permet d’afficher l’UI en fonction de l’état du player.

### 10. **presentation/bloc/playlist_bloc.dart**
- **Rôle** : BLoC pour la gestion des playlists (chargement, création, suppression).
- **Utilité** : Sépare la logique playlist de celle du player.

### 11. **presentation/bloc/playlist_event.dart**
- **Rôle** : Événements pour le BLoC playlist.
- **Utilité** : Permet de gérer les actions sur les playlists.

### 12. **presentation/pages/music_player_page.dart**
- **Rôle** : Page principale du lecteur de musique (UI globale, navigation entre tabs).
- **Utilité** : Point d’entrée de l’utilisateur pour la lecture et la gestion des playlists.

### 13. **presentation/pages/full_player_page.dart**
- **Rôle** : Page du lecteur en mode plein écran (contrôles avancés, visuel).
- **Utilité** : Offre une expérience immersive pour la lecture.

### 14. **presentation/pages/queue_page.dart**
- **Rôle** : Page affichant la queue de lecture (ordre, suppression, drag & drop).
- **Utilité** : Permet à l’utilisateur de gérer la liste des chansons à venir.

### 15. **presentation/pages/search_page.dart**
- **Rôle** : Page de recherche de chansons ou playlists.
- **Utilité** : Facilite la navigation dans la bibliothèque musicale.

### 16. **presentation/widgets/mini_player_widget.dart**
- **Rôle** : Widget du mini-player affiché en bas de l’écran.
- **Utilité** : Permet un contrôle rapide de la lecture sans quitter la page courante.

### 17. **presentation/widgets/song_list_widget.dart**
- **Rôle** : Widget affichant la liste des chansons.
- **Utilité** : Permet de parcourir et sélectionner une chanson à jouer.

### 18. **presentation/widgets/playlist_list_widget.dart**
- **Rôle** : Widget affichant la liste des playlists.
- **Utilité** : Permet de gérer et lancer des playlists.

### 19. **di/music_player_injection.dart**
- **Rôle** : Fichier d’injection de dépendances pour le module music player.
- **Utilité** : Facilite la gestion et l’instanciation des classes (BLoC, usecases, etc.).

---

## Résumé

Chaque fichier est organisé selon le principe Clean Architecture :  
- **domain/** : logique métier et modèles  
- **data/** : accès aux données  
- **presentation/** : interface utilisateur et gestion d’état  
- **di/** : injection de dépendances

Cette organisation permet de séparer clairement la logique, l’UI et les données, facilitant la maintenance et l’évolution du projet.

---

N’hésite pas à demander une documentation plus détaillée sur une partie spécifique ou sur l’utilisation des BLoC, widgets, ou usecases !
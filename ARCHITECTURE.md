# Architecture OtoRank

Documentation détaillée de l'architecture de l'application OtoRank.

## 📐 Vue d'ensemble

OtoRank utilise **Clean Architecture** combinée à une approche **Feature-First** pour garantir :

- ✅ Séparation des responsabilités
- ✅ Testabilité maximale
- ✅ Indépendance des frameworks
- ✅ Maintenabilité à long terme
- ✅ Scalabilité

## 🏗️ Les trois couches

### 1. Domain Layer (Couche Domaine)

**Responsabilité** : Logique métier pure, indépendante de toute implémentation.

**Contenu** :
- **Entities** : Objets métier de base
- **Repositories** : Interfaces (contrats)
- **Use Cases** : Logique métier

**Règles** :
- ❌ Aucune dépendance vers les autres couches
- ❌ Pas de dépendances Flutter
- ✅ Uniquement du Dart pur

```dart
// Exemple d'entité
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  
  const User({required this.id, required this.name, required this.email});
  
  @override
  List<Object?> get props => [id, name, email];
}

// Exemple de repository (interface)
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, void>> updateUser(User user);
}

// Exemple de use case
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
```

### 2. Data Layer (Couche Données)

**Responsabilité** : Implémentation des repositories, gestion des sources de données.

**Contenu** :
- **Models** : Représentation des données (JSON ↔ Entity)
- **Data Sources** : Remote (API) et Local (Cache)
- **Repository Implementations** : Implémentation concrète

**Règles** :
- ✅ Implémente les interfaces du Domain
- ✅ Gère la sérialisation/désérialisation
- ✅ Décide entre cache et API

```dart
// Exemple de modèle
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

// Exemple de data source
abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  
  UserRemoteDataSourceImpl(this.client);
  
  @override
  Future<UserModel> getUser(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/users/$id'));
    
    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}

// Exemple de repository impl
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUser(id);
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        return Right(await localDataSource.getCachedUser(id));
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }
}
```

### 3. Presentation Layer (Couche Présentation)

**Responsabilité** : UI et gestion d'état.

**Contenu** :
- **Pages** : Écrans de l'application
- **Widgets** : Composants UI réutilisables
- **BLoC/Provider** : Gestion d'état

**Règles** :
- ✅ Utilise les use cases du Domain
- ✅ Ne connaît pas la Data Layer
- ✅ Gère uniquement l'UI et l'état

```dart
// Exemple de BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUseCase getUser;
  
  UserBloc({required this.getUser}) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }
  
  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    
    final result = await getUser(event.userId);
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }
}

// Exemple de page
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const LoadingWidget();
        } else if (state is UserLoaded) {
          return UserProfile(user: state.user);
        } else if (state is UserError) {
          return ErrorWidget(message: state.message);
        }
        return Container();
      },
    );
  }
}
```

## 🗂️ Organisation Feature-First

Chaque fonctionnalité est autonome et contient ses trois couches :

```
features/
└── authentication/
    ├── data/
    │   ├── datasources/
    │   │   ├── auth_remote_datasource.dart
    │   │   └── auth_local_datasource.dart
    │   ├── models/
    │   │   └── user_model.dart
    │   └── repositories/
    │       └── auth_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── user.dart
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   └── usecases/
    │       ├── login_usecase.dart
    │       ├── logout_usecase.dart
    │       └── register_usecase.dart
    └── presentation/
        ├── bloc/
        │   ├── auth_bloc.dart
        │   ├── auth_event.dart
        │   └── auth_state.dart
        ├── pages/
        │   ├── login_page.dart
        │   └── register_page.dart
        └── widgets/
            ├── login_form.dart
            └── password_field.dart
```

## 🔄 Flux de données

```
User Action (UI)
       ↓
   BLoC/Event
       ↓
    Use Case
       ↓
  Repository (Interface)
       ↓
Repository Implementation
       ↓
  Data Source (Remote/Local)
       ↓
   API / Database
```

### Exemple de flux complet

1. **User clique sur "Login"**
   ```dart
   onPressed: () => context.read<AuthBloc>().add(LoginRequested(email, password))
   ```

2. **BLoC reçoit l'événement**
   ```dart
   on<LoginRequested>((event, emit) async {
     emit(AuthLoading());
     final result = await loginUseCase(LoginParams(event.email, event.password));
     // ...
   });
   ```

3. **Use Case exécute la logique métier**
   ```dart
   Future<Either<Failure, User>> call(LoginParams params) {
     return repository.login(params.email, params.password);
   }
   ```

4. **Repository coordonne les sources**
   ```dart
   Future<Either<Failure, User>> login(String email, String password) async {
     try {
       final user = await remoteDataSource.login(email, password);
       await localDataSource.cacheUser(user);
       return Right(user);
     } catch (e) {
       return Left(ServerFailure());
     }
   }
   ```

5. **Data Source appelle l'API**
   ```dart
   Future<UserModel> login(String email, String password) async {
     final response = await client.post(
       Uri.parse('$baseUrl/auth/login'),
       body: {'email': email, 'password': password},
     );
     // ...
   }
   ```

6. **Résultat retourne vers le BLoC**
   ```dart
   result.fold(
     (failure) => emit(AuthError(failure.message)),
     (user) => emit(AuthSuccess(user)),
   );
   ```

7. **UI se met à jour**
   ```dart
   BlocListener<AuthBloc, AuthState>(
     listener: (context, state) {
       if (state is AuthSuccess) {
         Navigator.pushReplacementNamed(context, '/home');
       }
     },
   );
   ```

## 📦 Core Module

Code partagé dans toute l'application :

```
core/
├── constants/      # Constantes globales
├── errors/         # Gestion des erreurs
├── network/        # Configuration réseau
├── theme/          # Thème de l'app
├── utils/          # Utilitaires
└── widgets/        # Widgets réutilisables
```

## 🧩 Injection de dépendances

Utilisation de **GetIt** pour l'injection de dépendances :

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Authentication
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()));
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}
```

## 🎯 Principes SOLID

### Single Responsibility Principle
Chaque classe a une seule responsabilité :
- Use Case : 1 action métier
- Data Source : 1 type de source
- Repository : 1 domaine de données

### Open/Closed Principle
Ouvert à l'extension, fermé à la modification :
- Utilisation d'interfaces (repositories)
- Injection de dépendances

### Liskov Substitution Principle
Les implémentations peuvent remplacer les abstractions :
- Models extends Entities
- Repository impl implements Repository interface

### Interface Segregation Principle
Interfaces spécifiques et ciblées :
- Data sources séparés (Remote, Local)
- Use cases granulaires

### Dependency Inversion Principle
Dépendre des abstractions, pas des implémentations :
- Presentation → Domain (abstractions)
- Data → Domain (implémente les abstractions)

## 🧪 Testabilité

L'architecture permet de tester facilement chaque couche :

```dart
// Test de Use Case
test('should return user when repository call is successful', () async {
  // Arrange
  when(mockRepository.getUser(any))
      .thenAnswer((_) async => const Right(testUser));
  
  // Act
  final result = await useCase('123');
  
  // Assert
  expect(result, const Right(testUser));
  verify(mockRepository.getUser('123'));
  verifyNoMoreInteractions(mockRepository);
});

// Test de Repository
test('should return remote data when call is successful', () async {
  // Arrange
  when(mockRemoteDataSource.getUser(any))
      .thenAnswer((_) async => testUserModel);
  when(mockNetworkInfo.isConnected)
      .thenAnswer((_) async => true);
  
  // Act
  final result = await repository.getUser('123');
  
  // Assert
  verify(mockRemoteDataSource.getUser('123'));
  verify(mockLocalDataSource.cacheUser(testUserModel));
  expect(result, const Right(testUserModel));
});

// Test de BLoC
blocTest<AuthBloc, AuthState>(
  'should emit [Loading, Success] when login is successful',
  build: () {
    when(mockLoginUseCase(any))
        .thenAnswer((_) async => const Right(testUser));
    return authBloc;
  },
  act: (bloc) => bloc.add(const LoginRequested('email', 'password')),
  expect: () => [
    AuthLoading(),
    const AuthSuccess(testUser),
  ],
);
```

## 📚 Ressources

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture - Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

---

**Cette architecture garantit un code maintenable, testable et évolutif ! 🚀**

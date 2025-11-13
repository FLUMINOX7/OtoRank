/// Bloc pour la gestion de l'état de la page Home
/// 
/// Utilise le pattern BLoC pour gérer l'état de l'interface.
/// Note: Nécessite l'ajout du package flutter_bloc dans pubspec.yaml
/// TODO: Décommenter une fois flutter_bloc ajouté

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../../domain/entities/home_entity.dart';
// import '../../domain/usecases/get_home_data_usecase.dart';

/// Événements du HomeBloc
// abstract class HomeEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadHomeData extends HomeEvent {}

/// États du HomeBloc
// abstract class HomeState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class HomeInitial extends HomeState {}
// class HomeLoading extends HomeState {}
// class HomeLoaded extends HomeState {
//   final List<HomeEntity> data;
//   HomeLoaded(this.data);
//   @override
//   List<Object?> get props => [data];
// }
// class HomeError extends HomeState {
//   final String message;
//   HomeError(this.message);
//   @override
//   List<Object?> get props => [message];
// }

/// BLoC pour la page Home
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   final GetHomeDataUseCase getHomeData;
//   
//   HomeBloc(this.getHomeData) : super(HomeInitial()) {
//     on<LoadHomeData>(_onLoadHomeData);
//   }
//   
//   Future<void> _onLoadHomeData(
//     LoadHomeData event,
//     Emitter<HomeState> emit,
//   ) async {
//     emit(HomeLoading());
//     
//     final result = await getHomeData();
//     
//     result.fold(
//       (failure) => emit(HomeError(failure.message)),
//       (data) => emit(HomeLoaded(data)),
//     );
//   }
// }

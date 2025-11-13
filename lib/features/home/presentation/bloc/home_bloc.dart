/// Bloc pour la gestion de l'état de la page Home/// Bloc pour la gestion de l'état de la page Home

/// /// 

/// Utilise le pattern BLoC pour gérer l'état de l'interface./// Utilise le pattern BLoC pour gérer l'état de l'interface.

/// Note: Nécessite l'ajout du package flutter_bloc dans pubspec.yaml/// Note: Nécessite l'ajout du package flutter_bloc dans pubspec.yaml

/// TODO: Décommenter une fois flutter_bloc ajouté/// TODO: Décommenter une fois flutter_bloc ajouté

library;

// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';// import 'package:equatable/equatable.dart';

// import 'package:equatable/equatable.dart';// import '../../domain/entities/home_entity.dart';

// import '../../domain/entities/home_entity.dart';// import '../../domain/usecases/get_home_data_usecase.dart';

// import '../../domain/usecases/get_home_data_usecase.dart';

/// Événements du HomeBloc

// /// Événements du HomeBloc// abstract class HomeEvent extends Equatable {

// abstract class HomeEvent extends Equatable {//   @override

//   @override//   List<Object?> get props => [];

//   List<Object?> get props => [];// }

// }

// // class LoadHomeData extends HomeEvent {}

// class LoadHomeData extends HomeEvent {}

/// États du HomeBloc

// /// États du HomeBloc// abstract class HomeState extends Equatable {

// abstract class HomeState extends Equatable {//   @override

//   @override//   List<Object?> get props => [];

//   List<Object?> get props => [];// }

// }

// // class HomeInitial extends HomeState {}

// class HomeInitial extends HomeState {}// class HomeLoading extends HomeState {}

// class HomeLoading extends HomeState {}// class HomeLoaded extends HomeState {

// class HomeLoaded extends HomeState {//   final List<HomeEntity> data;

//   final List<HomeEntity> data;//   HomeLoaded(this.data);

//   HomeLoaded(this.data);//   @override

//   @override//   List<Object?> get props => [data];

//   List<Object?> get props => [data];// }

// }// class HomeError extends HomeState {

// class HomeError extends HomeState {//   final String message;

//   final String message;//   HomeError(this.message);

//   HomeError(this.message);//   @override

//   @override//   List<Object?> get props => [message];

//   List<Object?> get props => [message];// }

// }

/// BLoC pour la page Home

// /// BLoC pour la page Home// class HomeBloc extends Bloc<HomeEvent, HomeState> {

// class HomeBloc extends Bloc<HomeEvent, HomeState> {//   final GetHomeDataUseCase getHomeData;

//   final GetHomeDataUseCase getHomeData;//   

//   //   HomeBloc(this.getHomeData) : super(HomeInitial()) {

//   HomeBloc(this.getHomeData) : super(HomeInitial()) {//     on<LoadHomeData>(_onLoadHomeData);

//     on<LoadHomeData>(_onLoadHomeData);//   }

//   }//   

//   //   Future<void> _onLoadHomeData(

//   Future<void> _onLoadHomeData(//     LoadHomeData event,

//     LoadHomeData event,//     Emitter<HomeState> emit,

//     Emitter<HomeState> emit,//   ) async {

//   ) async {//     emit(HomeLoading());

//     emit(HomeLoading());//     

//     //     final result = await getHomeData();

//     final result = await getHomeData();//     

//     //     result.fold(

//     result.fold(//       (failure) => emit(HomeError(failure.message)),

//       (failure) => emit(HomeError(failure.message)),//       (data) => emit(HomeLoaded(data)),

//       (data) => emit(HomeLoaded(data)),//     );

//     );//   }

//   }// }

// }

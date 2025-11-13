/// Source de données distante pour Home
/// 
/// Gère les appels API pour la fonctionnalité Home.
import '../models/home_model.dart';

/// Interface de la source de données distante
abstract class HomeRemoteDataSource {
  /// Récupère les données home depuis l'API
  /// 
  /// Lance une [ServerException] en cas d'erreur serveur
  Future<List<HomeModel>> getHomeData();
}

/// Implémentation de la source de données distante
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // final http.Client client;
  
  // HomeRemoteDataSourceImpl({required this.client});
  
  @override
  Future<List<HomeModel>> getHomeData() async {
    // TODO: Implémenter l'appel API réel
    // Exemple:
    // final response = await client.get(
    //   Uri.parse('${AppConstants.baseUrl}/home'),
    //   headers: {'Content-Type': 'application/json'},
    // );
    // 
    // if (response.statusCode == 200) {
    //   final List<dynamic> jsonList = json.decode(response.body);
    //   return jsonList.map((json) => HomeModel.fromJson(json)).toList();
    // } else {
    //   throw ServerException();
    // }
    
    // Données mockées pour l'exemple
    await Future.delayed(const Duration(seconds: 1));
    return [
      HomeModel(
        id: '1',
        title: 'Bienvenue sur OtoRank',
        description: 'Ceci est un exemple de données',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

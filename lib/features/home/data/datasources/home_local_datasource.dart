/// Source de données locale pour Home
/// 
/// Gère la persistance locale des données (cache).
library;

import '../models/home_model.dart';

/// Interface de la source de données locale
abstract class HomeLocalDataSource {
  /// Récupère les données home depuis le cache
  /// 
  /// Lance une [CacheException] si aucune donnée n'est en cache
  Future<List<HomeModel>> getCachedHomeData();
  
  /// Sauvegarde les données home en cache
  Future<void> cacheHomeData(List<HomeModel> dataToCache);
}

/// Implémentation de la source de données locale
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  // final SharedPreferences sharedPreferences;
  // static const String cachedHomeDataKey = 'CACHED_HOME_DATA';
  
  // HomeLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<HomeModel>> getCachedHomeData() async {
    // TODO: Implémenter la récupération depuis le cache
    // final jsonString = sharedPreferences.getString(cachedHomeDataKey);
    // if (jsonString != null) {
    //   final List<dynamic> jsonList = json.decode(jsonString);
    //   return jsonList.map((json) => HomeModel.fromJson(json)).toList();
    // } else {
    //   throw CacheException();
    // }
    
    throw UnimplementedError('Cache non implémenté');
  }
  
  @override
  Future<void> cacheHomeData(List<HomeModel> dataToCache) async {
    // TODO: Implémenter la sauvegarde en cache
    // final jsonString = json.encode(
    //   dataToCache.map((model) => model.toJson()).toList(),
    // );
    // await sharedPreferences.setString(cachedHomeDataKey, jsonString);
  }
}

/// Interface pour vérifier la connectivité réseau
/// 
/// Cette classe abstraite définit le contrat pour vérifier
/// si l'appareil est connecté à Internet.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implémentation de NetworkInfo utilisant le package connectivity_plus
/// 
/// Note: Nécessite l'ajout du package connectivity_plus dans pubspec.yaml
/// TODO: Implémenter avec connectivity_plus une fois le package ajouté
class NetworkInfoImpl implements NetworkInfo {
  // final Connectivity connectivity;
  
  // NetworkInfoImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected async {
    // TODO: Implémenter avec connectivity_plus
    // final result = await connectivity.checkConnectivity();
    // return result != ConnectivityResult.none;
    
    // Temporairement, on suppose qu'on est toujours connecté
    return true;
  }
}

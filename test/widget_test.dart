/// Tests unitaires pour l'application OtoRank
///
/// Ce fichier contient les tests de base pour l'application.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:otorank/main.dart';

void main() {
  testWidgets('HomePage displays welcome message', (WidgetTester tester) async {
    // Construit l'application et déclenche un frame
    await tester.pumpWidget(const OtoRankApp());

    // Vérifie que le message de bienvenue est affiché
    expect(find.text('Bienvenue sur OtoRank'), findsOneWidget);
    expect(find.text('OtoRank'), findsWidgets);
  });
}

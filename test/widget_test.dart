import 'package:flutter_test/flutter_test.dart';

import 'package:studiobox_music_importer/src/app.dart';

void main() {
  testWidgets('renders StudioBox Music Importer shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudioBoxMusicImporterApp());

    expect(find.text('StudioBox Music Importer'), findsOneWidget);
    expect(
      find.text('Prepare novas musicas para o padrao do Karaoke StudioBox.'),
      findsOneWidget,
    );
    expect(find.text('Biblioteca oficial'), findsOneWidget);
    expect(find.text('Novas musicas'), findsOneWidget);
    expect(find.text('Revisao segura'), findsOneWidget);
    expect(find.text('Saida'), findsOneWidget);
    expect(find.text('Motor preparado'), findsOneWidget);
    expect(find.text('- Parser oficial'), findsOneWidget);
    expect(find.text('- Plano de importacao'), findsOneWidget);
    expect(find.text('- Manifesto em memoria'), findsOneWidget);
    expect(find.text('Round 9 - Dominio organizado'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poetica/theme/artistic_palettes.dart';

void main() {
  testWidgets('Theme and Palettes smoke test', (WidgetTester tester) async {
    expect(ArtisticPalette.allPalettes.length, 6);
    final nebulosa = ArtisticPalette.getByType(AppPaletteType.nebulosa);
    expect(nebulosa.name, 'Nebulosa Mística');
    expect(nebulosa.emoji, '🌌');

    final oled = ArtisticPalette.getByType(AppPaletteType.medianocheOled);
    expect(oled.name, 'Medianoche OLED');
  });
}

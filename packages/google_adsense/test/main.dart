import 'package:google_adsense/adsense.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<Adsense>()])
import 'main.mocks.dart';

void main() {
  test('init API on web', () {
    var adClient = "123";
    // Given
    var adsense = MockAdsense();
    // When
    adsense.initialize(adClient);
    // Then
    verify(adsense.initialize(adClient));
  });
}

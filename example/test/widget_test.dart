import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders every sample', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static policy: product lib must not reference mock runtime paths (015).
void main() {
  test('lib/ has no useMockApi or shared/mocks imports', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);
    final violations = <String>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      if (content.contains('useMockApi')) {
        violations.add('${entity.path}: useMockApi');
      }
      if (content.contains('shared/mocks') ||
          content.contains("shared\\mocks")) {
        violations.add('${entity.path}: shared/mocks');
      }
      if (content.contains('ApiMode.')) {
        violations.add('${entity.path}: ApiMode');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Slight raster differences between Linux (CI) and Windows dev machines.
const _maxGoldenDiffPercent = 1.0;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final defaultComparator = goldenFileComparator;
  if (defaultComparator is LocalFileComparator) {
    goldenFileComparator = _TolerantLocalFileComparator(
      defaultComparator,
      maxDiffPercent: _maxGoldenDiffPercent,
    );
  }
  await testMain();
}

class _TolerantLocalFileComparator extends LocalFileComparator {
  _TolerantLocalFileComparator(this._delegate, {required this.maxDiffPercent})
    : super(_delegate.basedir);

  final LocalFileComparator _delegate;
  final double maxDiffPercent;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri goldenUri) async {
    final goldenBytes = await _delegate.getGoldenBytes(goldenUri);
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    if (result.passed || result.diffPercent <= maxDiffPercent) {
      return true;
    }
    return _delegate.compare(imageBytes, goldenUri);
  }
}

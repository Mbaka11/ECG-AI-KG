import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        ['NotoSans'], 'Noto Sans is licensed under the SIL Open Font License 1.1. See assets/fonts/OFL.txt.');
  });
  runApp(const ProviderScope(child: EcgApp()));
}

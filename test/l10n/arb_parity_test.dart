import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ARB Localization Parity', () {
    test(
      'app_bn.arb and app_en.arb contain identical keys and no empty values',
      () {
        final bnFile = File('lib/l10n/app_bn.arb');
        final enFile = File('lib/l10n/app_en.arb');

        expect(bnFile.existsSync(), isTrue, reason: 'app_bn.arb exists');
        expect(enFile.existsSync(), isTrue, reason: 'app_en.arb exists');

        final bnJson =
            json.decode(bnFile.readAsStringSync()) as Map<String, dynamic>;
        final enJson =
            json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;

        final bnKeys = bnJson.keys.where((k) => !k.startsWith('@')).toSet();
        final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();

        // Check key parity
        final missingInEn = bnKeys.difference(enKeys);
        final missingInBn = enKeys.difference(bnKeys);

        expect(
          missingInEn,
          isEmpty,
          reason: 'Keys in bn but missing in en: $missingInEn',
        );
        expect(
          missingInBn,
          isEmpty,
          reason: 'Keys in en but missing in bn: $missingInBn',
        );

        // Check no empty values
        for (final key in bnKeys) {
          final val = bnJson[key] as String;
          expect(
            val.trim().isNotEmpty,
            isTrue,
            reason: 'app_bn.arb key "$key" is empty',
          );
        }

        for (final key in enKeys) {
          final val = enJson[key] as String;
          expect(
            val.trim().isNotEmpty,
            isTrue,
            reason: 'app_en.arb key "$key" is empty',
          );
        }
      },
    );
  });
}

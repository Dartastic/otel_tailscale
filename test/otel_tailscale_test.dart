// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_tailscale/otel_tailscale.dart';
import 'package:test/test.dart';

void main() {
  group('otel_tailscale', () {
    test('suppression toggles in zone', () async {
      expect(tailscaleInstrumentationSuppressed(), isFalse);
      await runWithoutTailscaleInstrumentationAsync(() async {
        expect(tailscaleInstrumentationSuppressed(), isTrue);
      });
      expect(tailscaleInstrumentationSuppressed(), isFalse);
    });

    test('TailscaleResult fields default null', () {
      const r = TailscaleResult();
      expect(r.statusCode, isNull);
    });
  });
}

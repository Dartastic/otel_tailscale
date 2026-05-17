# otel_tailscale

Dartastic OpenTelemetry bridge for Tailscale (zero-trust mesh VPN).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_tailscale/otel_tailscale.dart';

await tracedTailscale<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return TailscaleCallResult(value: r, result: TailscaleResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutTailscaleInstrumentationAsync(() async {
  await client.someInternalSync();
});
```

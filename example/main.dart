// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_tailscale/otel_tailscale.dart';

/// Traces Tailscale calls with OpenTelemetry.
///
/// `otel_tailscale` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Tailscale call in
/// [tracedTailscale]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'tailscale-example');

  // Traces a Tailscale call.
  final tailscaleId = await tracedTailscale<String>(
    operation: 'create',
    invoke: () async {
      // Make the Tailscale call here, then report what it returned.
      const id = 'tailscale_8f3a2c';
      return const TailscaleCallResult(
          value: id,
          result: TailscaleResult(
              tailnet: 'example',
              nodeId: 'node_8f3a2c',
              nodeName: 'example',
              nodeAddress: 'example',
              user: 'example',
              acl: 'example',
              tag: 'example',
              exitNode: true,
              subnetRoutes: 1,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedTailscale create returned $tailscaleId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutTailscaleInstrumentationAsync.
  await runWithoutTailscaleInstrumentationAsync(
    () => tracedTailscale<String>(
      operation: 'create',
      invoke: () async {
        const id = 'tailscale_8f3a2c';
        return const TailscaleCallResult(
            value: id,
            result: TailscaleResult(
                tailnet: 'example',
                nodeId: 'node_8f3a2c',
                nodeName: 'example',
                nodeAddress: 'example',
                user: 'example',
                acl: 'example',
                tag: 'example',
                exitNode: true,
                subnetRoutes: 1,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}

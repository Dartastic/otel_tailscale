// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_tailscale_suppression.dart';

class TailscaleResult {
  /// Creates a result.
  const TailscaleResult({
    this.tailnet,
    this.nodeId,
    this.nodeName,
    this.nodeAddress,
    this.user,
    this.acl,
    this.tag,
    this.exitNode,
    this.subnetRoutes,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? tailnet;
  final String? nodeId;
  final String? nodeName;
  final String? nodeAddress;
  final String? user;
  final String? acl;
  final String? tag;
  final bool? exitNode;
  final int? subnetRoutes;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class TailscaleCallResult<T> {
  /// Creates a call result.
  const TailscaleCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final TailscaleResult? result;
}

Future<T> tracedTailscale<T>({
  required String operation,
  required Future<TailscaleCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (tailscaleInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_tailscale');
  final span = t.startSpan('tailscale $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'tailscale')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tailnet != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.tailnet', res.tailnet!)]));
      }
      if (res.nodeId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.node.id', res.nodeId!)]));
      }
      if (res.nodeName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.node.name', res.nodeName!)]));
      }
      if (res.nodeAddress != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('server.address', res.nodeAddress!)]));
      }
      if (res.user != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.email', res.user!)]));
      }
      if (res.acl != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.acl', res.acl!)]));
      }
      if (res.tag != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.tag', res.tag!)]));
      }
      if (res.exitNode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeBool('tailscale.exit_node', res.exitNode!)]));
      }
      if (res.subnetRoutes != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
            'tailscale.subnet_routes.count',
            res.subnetRoutes!,
          )
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('tailscale.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'tailscale.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

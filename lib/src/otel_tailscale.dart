// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_tailscale_suppression.dart';

class TailscaleResult {
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

class TailscaleCallResult<T> {
  const TailscaleCallResult({required this.value, this.result});
  final T value;
  final TailscaleResult? result;
}

Future<T> tracedTailscale<T>({
  required String operation,
  required Future<TailscaleCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (tailscaleInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_tailscale');
  final span = t.startSpan('tailscale $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'tailscale')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.tailnet != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('tailscale.tailnet', res.tailnet!)]));
      }
      if (res.nodeId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('tailscale.node.id', res.nodeId!)]));
      }
      if (res.nodeName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('tailscale.node.name', res.nodeName!)]));
      }
      if (res.nodeAddress != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('server.address', res.nodeAddress!)]));
      }
      if (res.user != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('user.email', res.user!)]));
      }
      if (res.acl != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('tailscale.acl', res.acl!)]));
      }
      if (res.tag != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('tailscale.tag', res.tag!)]));
      }
      if (res.exitNode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeBool('tailscale.exit_node', res.exitNode!)]));
      }
      if (res.subnetRoutes != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeInt(
            'tailscale.subnet_routes.count',
            res.subnetRoutes!,
          )
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('tailscale.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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

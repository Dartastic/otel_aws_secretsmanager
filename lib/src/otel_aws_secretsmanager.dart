// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_secretsmanager_suppression.dart';

const _tracerName = 'dartastic_otel_libs_aws_secretsmanager';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

/// Wraps an AWS Secrets Manager call (GetSecretValue, CreateSecret,
/// PutSecretValue, RotateSecret, ListSecrets) in a CLIENT span.
/// Never records the secret value itself.
Future<T> tracedAwsSecretsmanager<T>({
  required String operation,
  required Future<T> Function() invoke,
  String? secretId,
  String? versionId,
  String? region,
}) async {
  if (awsSecretsmanagerInstrumentationSuppressed()) {
    return invoke();
  }
  final m = <String, Object>{
    'rpc.system': 'aws-api',
    'rpc.service': 'SecretsManager',
    'rpc.method': operation,
  };
  if (secretId != null) m['aws.secretsmanager.secret.id'] = secretId;
  if (versionId != null) m['aws.secretsmanager.version.id'] = versionId;
  if (region != null) m['cloud.region'] = region;

  final span = _tracer().startSpan(
    'secretsmanager $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    return await invoke();
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_secretsmanager/otel_aws_secretsmanager.dart';

/// Traces AWS Secrets Manager calls with OpenTelemetry.
///
/// `otel_aws_secretsmanager` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AWS Secrets Manager call in
/// [tracedAwsSecretsmanager]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-secretsmanager-example');

  // Wraps an AWS Secrets Manager call (GetSecretValue, CreateSecret, PutSecretValue, RotateSecret, ListSecrets) in a CLIENT span.
  final awsSecretsmanagerId = await tracedAwsSecretsmanager<String>(
    operation: 'create',
    secretId: 'secret_8f3a2c',
    versionId: 'version_8f3a2c',
    region: 'us-east-1',
    invoke: () async {
      // Make the AWS Secrets Manager call here, then report what it returned.
      return 'aws_secretsmanager_8f3a2c';
    },
  );
  OTelLog.info('tracedAwsSecretsmanager create returned $awsSecretsmanagerId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsSecretsmanagerInstrumentationAsync.
  await runWithoutAwsSecretsmanagerInstrumentationAsync(
    () => tracedAwsSecretsmanager<String>(
      operation: 'create',
      secretId: 'secret_8f3a2c',
      versionId: 'version_8f3a2c',
      region: 'us-east-1',
      invoke: () async {
        return 'aws_secretsmanager_8f3a2c';
      },
    ),
  );

  await OTel.shutdown();
}

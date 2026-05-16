// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_aws_secretsmanager/otel_aws_secretsmanager.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_aws_secretsmanager-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('GetSecretValue records CLIENT span', () async {
    await tracedAwsSecretsmanager<String>(
      operation: 'GetSecretValue',
      secretId: 'prod/db/password',
      region: 'us-east-1',
      invoke: () async => 'redacted',
    );
    final a = attrsOf(spans.findSpanByName('secretsmanager GetSecretValue')!);
    expect(a['rpc.service'], 'SecretsManager');
    expect(a['rpc.method'], 'GetSecretValue');
    expect(a['aws.secretsmanager.secret.id'], 'prod/db/password');
    expect(a['cloud.region'], 'us-east-1');
  });

  test('suppression skips spans', () async {
    await runWithoutAwsSecretsmanagerInstrumentationAsync(() async {
      await tracedAwsSecretsmanager<String>(
        operation: 'ListSecrets',
        invoke: () async => 'ok',
      );
    });
    expect(spans.findSpansStartingWith('secretsmanager '), isEmpty);
  });
}

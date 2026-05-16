// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #dartastic_otel_libs_aws_secretsmanager_suppress;

bool awsSecretsmanagerInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

T runWithoutAwsSecretsmanagerInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

Future<T> runWithoutAwsSecretsmanagerInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

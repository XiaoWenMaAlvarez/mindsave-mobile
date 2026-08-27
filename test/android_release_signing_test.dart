import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la compilación Android release no utiliza la firma debug', () {
    final buildScript = File('android/app/build.gradle.kts').readAsStringSync();

    expect(buildScript, contains('rootProject.file("key.properties")'));
    expect(buildScript, contains('create("release")'));
    expect(buildScript, contains('signingConfigs.getByName("release")'));
    expect(buildScript, isNot(contains('signingConfigs.getByName("debug")')));
  });

  test('los secretos de firma están excluidos y existe una plantilla', () {
    final androidGitignore = File('android/.gitignore').readAsStringSync();
    final template = File('android/key.properties.example').readAsStringSync();

    expect(androidGitignore, contains('key.properties'));
    expect(androidGitignore, contains('**/*.jks'));
    expect(template, contains('storePassword='));
    expect(template, contains('keyPassword='));
    expect(template, contains('keyAlias='));
    expect(template, contains('storeFile='));
  });
}

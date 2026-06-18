import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('pre-commit hook', () {
    late Directory tempDir;
    late String githooksPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('pre_commit_test_');

      await Process.run('git', ['init'], workingDirectory: tempDir.path);
      await Process.run('git', ['config', 'user.email', 'test@example.com'], workingDirectory: tempDir.path);
      await Process.run('git', ['config', 'user.name', 'Test User'], workingDirectory: tempDir.path);

      var repoRoot = Directory.current;
      while (repoRoot.path != '/' && !Directory(p.join(repoRoot.path, '.git')).existsSync()) {
        repoRoot = repoRoot.parent;
      }

      githooksPath = p.join(repoRoot.path, 'script', 'githooks');
      
      // Set the hooksPath to the actual githooks directory
      await Process.run('git', ['config', 'core.hooksPath', githooksPath], workingDirectory: tempDir.path);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    Future<ProcessResult> runHook() async {
      // Actually run git commit to trigger the hook!
      return Process.run('git', ['commit', '-m', 'test'], workingDirectory: tempDir.path);
    }

    test('passes on a clean commit', () async {
      final file = File(p.join(tempDir.path, 'test_file.dart'));
      await file.writeAsString('''
void main() {
  print('Hello, world!');
}
''');

      await Process.run('git', ['add', 'test_file.dart'], workingDirectory: tempDir.path);

      final result = await runHook();
      expect(result.exitCode, 0);
      final output = '${result.stdout}${result.stderr}';
      expect(output, contains('Formatting looks good.'));
      expect(output, contains('Static analysis looks good.'));
    });

    test('fails on formatting error', () async {
      final file = File(p.join(tempDir.path, 'test_file.dart'));
      await file.writeAsString('''
void main(){
  print('Hello, world!');
}
''');

      await Process.run('git', ['add', 'test_file.dart'], workingDirectory: tempDir.path);

      final result = await runHook();
      expect(result.exitCode, 1);
      final output = '${result.stdout}${result.stderr}';
      expect(output, contains('Formatting issues found'));
    });

    test('fails on analysis error', () async {
      final file = File(p.join(tempDir.path, 'test_file.dart'));
      await file.writeAsString('''
void main() {
  print('Hello, world!')
}
''');

      await Process.run('git', ['add', 'test_file.dart'], workingDirectory: tempDir.path);

      final result = await runHook();
      expect(result.exitCode, 1);
      final output = '${result.stdout}${result.stderr}';
      expect(output, contains('Static analysis errors found'));
    });

    test('ignores non-dart files', () async {
      final file = File(p.join(tempDir.path, 'README.md'));
      await file.writeAsString('# Hello');

      await Process.run('git', ['add', 'README.md'], workingDirectory: tempDir.path);

      final result = await runHook();
      expect(result.exitCode, 0);
      final output = '${result.stdout}${result.stderr}';
      expect(output, isNot(contains('Checking formatting...')));
    });
  });
}

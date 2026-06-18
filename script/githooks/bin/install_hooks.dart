import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  var repoRoot = Directory.current;
  while (repoRoot.path != '/' && !Directory(p.join(repoRoot.path, '.git')).existsSync()) {
    repoRoot = repoRoot.parent;
  }

  if (repoRoot.path == '/') {
    print('❌ Could not find .git directory.');
    exit(1);
  }

  final result = await Process.run('git', ['config', 'core.hooksPath', 'script/githooks'], workingDirectory: repoRoot.path);
  if (result.exitCode == 0) {
    print('✅ Git hooks installed successfully!');
  } else {
    print('❌ Failed to install Git hooks: ${result.stderr}');
    exit(1);
  }
}

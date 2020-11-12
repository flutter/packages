// @dart = 2.4
import 'dart:io';

import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:file/memory.dart';
import 'package:fuchsia_ctl/src/ssh_key_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  group('SystemSshKeyManager', () {
    MemoryFileSystem fs;
    final MockProcessManager processManager = MockProcessManager();

    setUp(() async {
      fs = MemoryFileSystem();
    });
    test('CreateAuthorizedKeys', () async {
      const SystemSshKeyManager systemSshKeyManager = SystemSshKeyManager();
      final File authorizedKeys = fs.file('authorized_keys');
      final File pkeyPub = fs.file('key.pub');
      pkeyPub.writeAsString('ssh-rsa AAAA== abc@cde.com');
      systemSshKeyManager.createAuthorizedKeys(authorizedKeys, pkeyPub);
      final String result = await authorizedKeys.readAsString();
      expect(result, equals('ssh-rsa AAAA==\n'));
    });

    test('KeysNotGenerated_PubKeyPassed', () async {
      final File pkeyPub = fs.file('key.pub');
      pkeyPub.writeAsString('ssh-rsa AAAA== abc@cde.com');
      final SystemSshKeyManager systemSshKeyManager = SystemSshKeyManager(
          processManager: processManager, fs: fs, pkeyPubPath: pkeyPub.path);
      await systemSshKeyManager.createKeys();
      final File authorizedKeys = fs.file(path.join('.ssh', 'authorized_keys'));
      final String result = await authorizedKeys.readAsString();
      expect(result, equals('ssh-rsa AAAA==\n'));
      verifyNever(processManager.run(any));
    });

    test('KeysGenerated', () async {
      when(processManager.run(any)).thenAnswer((_) async {
        final File pkeyPub = fs.file(path.join('.ssh', 'pkey.pub'));
        pkeyPub.writeAsString('ssh-rsa AAAA== abc@cde.com');
        final File pkey = fs.file(path.join('.ssh', 'pkey'));
        pkey.create();
        return ProcessResult(0, 0, 'Good job', '');
      });
      final SystemSshKeyManager systemSshKeyManager =
          SystemSshKeyManager(processManager: processManager, fs: fs);
      await systemSshKeyManager.createKeys();
      final File authorizedKeys = fs.file(path.join('.ssh', 'authorized_keys'));
      expect(await authorizedKeys.exists(), isTrue);
      final File pkey = fs.file(path.join('.ssh', 'pkey'));
      expect(await pkey.exists(), isTrue);
      final File pkeyPub = fs.file(path.join('.ssh', 'pkey.pub'));
      expect(await pkeyPub.exists(), isTrue);
    });
  });
}

class MockProcessManager extends Mock implements ProcessManager {}

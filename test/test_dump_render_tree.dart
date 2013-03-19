library test_dump_render_tree;

import 'dart:io';
import 'package:unittest/unittest.dart';

void main() {
  testRun();
}

void testCore(Configuration config) {
  configure(config);
  groupSep = ' - ';
  testRun();
}

void testRun() {
  final browserTests = ['test/tests.html'];

  group('DumpRenderTree', () {
    browserTests.forEach((file) {
      test(file, () {
        _runDrt(file);
      });
    });
  });
}

void _runDrt(String htmlFile) {
  final allPassedRegExp = new RegExp('All \\d+ tests passed');

  final future = Process.run('DumpRenderTree', [htmlFile])
    .then((ProcessResult pr) {
      expect(pr.exitCode, 0, reason: 'DumpRenderTree should return exit code 0 - success');

      if(!allPassedRegExp.hasMatch(pr.stdout)) {
        print(pr.stdout);
        fail('Could not find success value in stdout: ${allPassedRegExp.pattern}');
      }
    });

  expect(future, completes);
}

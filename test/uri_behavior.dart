/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
part of asset_pack_tests;



class UriBehavior {
  static void runTests() {
    var b01 = 'http://dummy/d0/d1/';
    var b01index = '${b01}index.pack';
    var b01indexh = '${b01}index.pack#hello';
    var b01indexq = '${b01}index.pack?hello';
    group('uri behavior', () {
      test('test resolve absolute url http', () {
        expect(
          Uri.parse('${b01}').resolve('http://foo/hello.txt').toString(),
          equals('http://foo/hello.txt')
        );
      });
      test('test resolve relative url', () {
        expect(
          Uri.parse('${b01}').resolve('hello.txt').toString(),
          equals('${b01}hello.txt')
        );
        expect(
          Uri.parse('${b01}').resolve('f2/hello.txt').toString(),
          equals('${b01}f2/hello.txt')
        );
        expect(
          Uri.parse('${b01index}').resolve('hello.txt').toString(),
          equals('${b01}hello.txt')
        );
        expect(
          Uri.parse('${b01indexh}').resolve('hello.txt').toString(),
          equals('${b01}hello.txt')
        );
        expect(
          Uri.parse('${b01indexq}').resolve('hello.txt').toString(),
          equals('${b01}hello.txt')
        );
      });
      test('test resolve absolute path', () {
        expect(
          Uri.parse('${b01}').resolve('/hello.txt').toString(),
          equals('http://dummy/hello.txt')
        );
        expect(
          Uri.parse('${b01}').resolve('/f2/hello.txt').toString(),
          equals('http://dummy/f2/hello.txt')
        );
        expect(
          Uri.parse('${b01index}').resolve('/hello.txt').toString(),
          equals('http://dummy/hello.txt')
        );
        expect(
          Uri.parse('${b01indexh}').resolve('/hello.txt').toString(),
          equals('http://dummy/hello.txt')
        );
        expect(
          Uri.parse('${b01indexq}').resolve('/hello.txt').toString(),
          equals('http://dummy/hello.txt')
        );
      });
      test('test resolve sibling path', () {
        expect(
          Uri.parse('${b01}').resolve('../hello.txt').toString(),
          equals('http://dummy/d0/hello.txt')
        );
        expect(
          Uri.parse('${b01}').resolve('../f2/hello.txt').toString(),
          equals('http://dummy/d0/f2/hello.txt')
        );
        expect(
          Uri.parse('${b01index}').resolve('../hello.txt').toString(),
          equals('http://dummy/d0/hello.txt')
        );
        expect(
          Uri.parse('${b01indexh}').resolve('../hello.txt').toString(),
          equals('http://dummy/d0/hello.txt')
        );
        expect(
          Uri.parse('${b01indexq}').resolve('../hello.txt').toString(),
          equals('http://dummy/d0/hello.txt')
        );
      });
    });
  }
}

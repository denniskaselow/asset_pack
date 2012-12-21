/*
  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

class Importer {
  static void textTest() {
    AssetLoaderText textLoader = new AssetLoaderText();
    test('404', () {
      Future loaded;
      loaded = textLoader.load('notthere.json');
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
        AssetImporterText importer = new AssetImporterText();
        String imported = importer.import(text, {});
        Expect.equals(importer.fallback, imported);
      }));
    });
    test('text', () {
      Future loaded;
      loaded = textLoader.load('test.json');
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        AssetImporterText importer = new AssetImporterText();
        String imported = importer.import(text, {});
        Expect.equals('{"a":[1,2,3]}\n', imported);
      }));
    });
  }

  static void jsonTest() {
    AssetLoaderText textLoader = new AssetLoaderText();
    test('404', () {
      Future loaded;
      loaded = textLoader.load('notthere.json');
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
        AssetImporterJson importer = new AssetImporterJson();
        var imported = importer.import(text, {});
        Expect.equals(importer.fallback.length, imported.length);
      }));
    });
    test('map', () {
      Future loaded;
      loaded = textLoader.load('map.json');
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        AssetImporterJson importer = new AssetImporterJson();
        var imported = importer.import(text, {});
        Expect.equals("b", imported["a"]);
      }));
    });
    test('list', () {
      Future loaded;
      loaded = textLoader.load('list.json');
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        AssetImporterJson importer = new AssetImporterJson();
        var imported = importer.import(text, {});
        Expect.equals(5, imported.length);
      }));
    });
  }

  static void runTests() {
    group('AssertImporterText', () {
      Importer.textTest();
    });
    group('AssertImporterJson', () {
      Importer.jsonTest();
    });
  }
}

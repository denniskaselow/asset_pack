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

class Importer {
  static void textTest() {
    TextLoader textLoader = new TextLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
        TextImporter importer = new TextImporter();
        importer.import(text, assetRequest).then(
            (imported) {
              Expect.equals(importer.fallback, imported);
            });
      }));
    });
    test('text', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'test.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        TextImporter importer = new TextImporter();
        importer.import(text, assetRequest).then((imported) {
          Expect.equals('{"a":[1,2,3]}\n', imported);
        });
      }));
    });
  }

  static void jsonTest() {
    TextLoader textLoader = new TextLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
        JsonImporter importer = new JsonImporter();
        importer.import(text, assetRequest).then(
            (imported) {
              Expect.equals(importer.fallback.length, imported.length);
            });
      }));
    });
    test('map', () {
      Future loaded;
      var assetRequest = new AssetRequest('map', '', 'map.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        JsonImporter importer = new JsonImporter();
        importer.import(text, assetRequest).then((imported) {
          Expect.equals("b", imported["a"]);
        });
      }));
    });
    test('list', () {
      Future loaded;
      var assetRequest = new AssetRequest('list', '', 'list.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        JsonImporter importer = new JsonImporter();
        importer.import(text, assetRequest).then((imported) {
          Expect.equals(5, imported.length);
        });
      }));
    });
  }

  static void propertyMapTest() {
    TextLoader textLoader = new TextLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
        PropertyMapImporter importer = new PropertyMapImporter();
        importer.import(text, assetRequest).then(
            (imported) {
              Expect.equals(importer.fallback.length, imported.length);
            });
      }));
    });
    test('map', () {
      Future loaded;
      var assetRequest = new AssetRequest('map', '', 'map.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        PropertyMapImporter importer = new PropertyMapImporter();
        importer.import(text, assetRequest).then((imported) {
          Expect.equals("b", imported.a);
        });
      }));
    });
    test('list', () {
      Future loaded;
      var assetRequest = new AssetRequest('list', '', 'list.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        PropertyMapImporter importer = new PropertyMapImporter();
        importer.import(text, assetRequest).then((imported) {
          Expect.equals(5, imported.length);
        });
      }));
    });
  }

  static void runTests() {
    group('TextImporter', () {
      Importer.textTest();
    });
    group('JsonImporter', () {
      Importer.jsonTest();
    });
    group('PropertyMapImporter', () {
      Importer.propertyMapTest();
    });
  }
}

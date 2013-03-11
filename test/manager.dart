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

class Manager {
  static void loadTest() {
    AssetManager assetManager = new AssetManager();
    Future<AssetPack> futurePack;
    test('success.', () {
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack == null, false);
        expect(pack.loadedSuccessfully, true);
        expect(pack.length, 5);
        expect(pack.subpack.length, 1);
        expect(assetManager.root.testpack.subpack.length, 1);
        expect(assetManager.root.testpack.subpack.somemap.containsKey('a'), true);
        expect(assetManager.root.testpack.subpack.somemap['a'], 'b');
        expect(pack.subpack.type('somemap'), 'json');
        expect(assetManager.root.length, 1);
        expect(assetManager.root.testpack.length, 5);
        expect(assetManager.root.testpack, pack);
        expect(assetManager.root.testpack.list,
               assetManager.getAssetAtPath('testpack.list').imported);
        expect(assetManager.getAssetAtPath('testpack').imported, pack);
        expect(() {
          assetManager.getAssetAtPath('testpack.');
        }, throws);
        expect(() {
          assetManager.getAssetAtPath('.');
        }, throws);
        expect(() {
          assetManager.getAssetAtPath('');
        }, throws);
        expect(pack.type('list') , 'json');
        expect(pack.type('map')  , 'json');
        expect(pack.type('test') , 'json');
        expect(pack.type('tests'), 'text');
        test('duplicate pack', () {
          expect(() => assetManager.loadPack('testpack', 'testpack.pack'), throws);
        });
      }));
    });
    test('failure', () {
      futurePack = assetManager.loadPack('testpack2', 'testpackbadname.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack, null);
      }));
    });
    test('badpack', () {
      futurePack = assetManager.loadPack('brokenpack', 'brokenpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack, null);
      }));
    });
  }

  static void unloadTest() {
    test('unload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack.loadedSuccessfully, true);
        expect(assetManager.root.length, 1);
        expect(assetManager.root.testpack == null, false);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(assetManager.root.length, 0);
        expect(pack.type('list') , null);
        expect(pack.type('map')  , null);
        expect(pack.type('test') , null);
        expect(pack.type('tests'), null);
        expect(() => assetManager.root.testpack, throws);
      }));
    });
    test('reload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack.loadedSuccessfully, true);
        expect(assetManager.root.length, 1);
        expect(assetManager.root.testpack == null, false);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(() => assetManager.root.testpack, throws);
        futurePack = assetManager.loadPack('testpack', 'testpack.pack');
        futurePack.then((pack) {
          expect(pack.loadedSuccessfully, true);
          expect(pack.length, 5);
          expect(assetManager.root.length, 1);
          expect(assetManager.root.testpack, pack);
          expect(pack.type('list') , 'json');
          expect(pack.type('map')  , 'json');
          expect(pack.type('test') , 'json');
          expect(pack.type('tests'), 'text');
          expect(assetManager.root.testpack == null, false);
          assetManager.deregisterPack('testpack');
          expect(() => assetManager.deregisterPack('testpack'), throws);
          expect(() => assetManager.root.testpack, throws);
        });
      }));
    });
  }

  static void dynamicPackTest() {
    test('registerAsset', () {
      AssetManager assetManager = new AssetManager();
      Asset asset1 = assetManager.registerAssetAtPath('packy.text', 'text', 'hello');
      expect(() {
        // Second attempt to register asset 'packy.text' throws argument error.
        Asset asset2 = assetManager.registerAssetAtPath('packy.text', 'foo', '');
      }, throws);
      // Asset can be accessed via assets map.
      Asset foundAsset = assetManager.getAssetAtPath('packy.text');
      expect(foundAsset, asset1);
      // Asset properly registered:
      expect(assetManager.root.packy.text, 'hello');
      expect(asset1.importer, null);
      expect(asset1.loader, null);
      expect(asset1.status, 'OK');
      expect(asset1.type, 'text');
      expect(asset1.pack.type('text'), 'text');
      assetManager.deregisterAssetAtPath('packy.text');
      // Pack is removed.
      expect(() {
        // Access a non-existant asset throws.
        var i = assetManager.root.packy;
      }, throws);
      // Asset is not findable.
      expect(() {
        assetManager.getAssetAtPath('packy.text');
      }, throws);
    });
  }

  static void dynamicLoadTest() {
    test('loadAndRegisterAsset', () {
      AssetManager assetManager = new AssetManager();
      Future load = assetManager.loadAndRegisterAsset('test', 'testpack/json/test.json', 'text', {}, {});

      load.then(expectAsync1((asset) {
        String expected = '{"a":[1,2,3]}';
        expect(asset.startsWith(expected), true);
      }));
    });
  }

  static void runTests() {
    group('loadPack', () {
      loadTest();
    });
    group('unloadpack', () {
      unloadTest();
    });
    group('dynamicpack', () {
      dynamicPackTest();
      dynamicLoadTest();
    });
  }
}

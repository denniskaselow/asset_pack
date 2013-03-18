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
        expect(pack.length, 5);
        expect(pack['subpack'].length, 1);
        expect(assetManager['testpack.subpack'].length, 1);
        expect(assetManager['testpack.subpack.somemap'].containsKey('a'), true);
        expect(assetManager['testpack.subpack.somemap']['a'], 'b');
        expect(assetManager['testpack.subpack'].parent,
               assetManager['testpack']);
        expect(pack['subpack'].type('somemap'), 'json');
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'].length, 5);
        expect(assetManager['testpack'], pack);
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
          expect(() => assetManager.loadPack('testpack', 'testpack.pack'),
                                             throws);
        });
      }));
    });
    test('failure', () {
      futurePack = assetManager.loadPack('testpack2', 'testpackbadname.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack.length, 0);
      }));
    });
    test('badpack', () {
      futurePack = assetManager.loadPack('brokenpack', 'brokenpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(pack.length, 0);
      }));
    });
  }

  static void unloadTest() {
    test('unload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'] == null, false);
        expect(assetManager['testpack'].parent, assetManager.root);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(pack.parent, null);
        expect(assetManager.root.assets.length, 0);
        expect(pack.type('list') , null);
        expect(pack.type('map')  , null);
        expect(pack.type('test') , null);
        expect(pack.type('tests'), null);
        expect(() => assetManager['testpack'], throws);
      }));
    });
    test('reload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'] == null, false);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(() => assetManager['testpack'], throws);
        futurePack = assetManager.loadPack('testpack', 'testpack.pack');
        futurePack.then((pack) {
          expect(pack.assets.length, 5);
          expect(assetManager.root.assets.length, 1);
          expect(assetManager['testpack'], pack);
          expect(pack.type('list') , 'json');
          expect(pack.type('map')  , 'json');
          expect(pack.type('test') , 'json');
          expect(pack.type('tests'), 'text');
          expect(assetManager['testpack'] == null, false);
          assetManager.deregisterPack('testpack');
          expect(() => assetManager.deregisterPack('testpack'), throws);
          expect(() => assetManager['testpack'], throws);
        });
      }));
    });
  }

  static void dynamicPackTest() {
    test('registerAsset', () {
      AssetManager assetManager = new AssetManager();
      AssetPack pack = assetManager.root.registerPack('packy', '');
      expect(pack.parent, assetManager.root);
      Asset asset1 = pack.registerAsset('text', 'text', '', '', {}, {});
      expect(asset1.pack, pack);
      asset1.imported = 'hello'; // Set imported object.
      expect(() {
        // Second attempt to register asset 'packy.text' throws argument error.
        Asset asset2 = pack.registerAsset('text', 'text', '', '', {}, {});
      }, throws);
      // Asset can be accessed via assets map.
      Asset foundAsset = assetManager.getAssetAtPath('packy.text');
      expect(foundAsset, asset1);
      // Asset properly registered:
      expect(assetManager['packy.text'], 'hello');
      expect(asset1.importer, isNotNull);
      expect(asset1.loader, isNotNull);
      expect(asset1.status, 'OK');
      expect(asset1.type, 'text');
      expect(asset1.pack.type('text'), 'text');
      pack.deregisterAsset('text');
      assetManager.root.deregisterPack('packy');
      // Pack is removed.
      expect(() {
        // Access a non-existant asset throws.
        var i = assetManager['packy'];
      }, throws);
      expect(pack.parent, null);
      // Asset is not findable.
      expect(() {
        assetManager.getAssetAtPath('packy.text');
      }, throws);
    });
  }

  static void dynamicLoadTest() {
    test('loadAndRegisterAsset', () {
      AssetManager assetManager = new AssetManager();
      Future load = assetManager.loadAndRegisterAsset(
          'test',
          'text',
          'testpack/json/test.json',
          {},
          {});

      load.then(expectAsync1((asset) {
        // Test the asset itself
        expect(asset.pack, assetManager.root);
        expect(asset.status, 'OK');
        String expected = '{"a":[1,2,3]}';
        expect(asset.imported.startsWith(expected), true);
        expect(assetManager.root.assets.length, 1);
        expect(assetManager.root.length, 1);
        // Test the asset access through the assetManager
        expect(assetManager['test'].startsWith(expected), true);
        expect(assetManager.root.type('test'), 'text');
        // Deregister the asset
        assetManager.root.deregisterAsset('test');
        expect(() {
          // Access a non-existant asset throws.
          var i = assetManager['test'];
        }, throws);
        expect(assetManager.root.assets.length, 0);
        expect(assetManager.root.length, 0);
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

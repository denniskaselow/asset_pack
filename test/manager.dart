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
        Expect.notEquals(pack, null);
        Expect.equals(true, pack.loadedSuccessfully);
        Expect.equals(5, pack.length);
        Expect.equals(1, pack.subpack.length);
        Expect.equals(1, assetManager.root.testpack.subpack.length);
        Expect.isTrue(
            assetManager.root.testpack.subpack.somemap.containsKey('a'));
        Expect.equals('b', assetManager.root.testpack.subpack.somemap['a']);
        Expect.equals('json', pack.subpack.type('somemap'));
        Expect.equals(1, assetManager.root.length);
        Expect.equals(5, assetManager.root.testpack.length);
        Expect.equals(pack, assetManager.root.testpack);
        Expect.equals(assetManager.getAssetAtPath('testpack.list').imported,
                      assetManager.root.testpack.list);
        Expect.equals(pack, assetManager.getAssetAtPath('testpack').imported);
        Expect.throws(() {
          assetManager.getAssetAtPath('testpack.');
        });
        Expect.throws(() {
          assetManager.getAssetAtPath('.');
          });
        Expect.throws(() {
          assetManager.getAssetAtPath('');
        });
        Expect.equals('json', pack.type('list'));
        Expect.equals('json', pack.type('map'));
        Expect.equals('json', pack.type('test'));
        Expect.equals('text', pack.type('tests'));
        test('duplicate pack', () {
          Expect.throws(() => assetManager.loadPack('testpack', 'testpack.pack'));
        });
      }));
    });
    test('failure', () {
      futurePack = assetManager.loadPack('testpack2', 'testpackbadname.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.equals(null, pack);
      }));
    });
    test('badpack', () {
      futurePack = assetManager.loadPack('brokenpack', 'brokenpack.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.equals(null, pack);
      }));
    });
  }

  static void unloadTest() {
    test('unload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.equals(true, pack.loadedSuccessfully);
        Expect.equals(1, assetManager.root.length);
        Expect.notEquals(null, assetManager.root.testpack);
        assetManager.deregisterPack('testpack');
        Expect.equals(0, pack.length);
        Expect.equals(0, assetManager.root.length);
        Expect.equals(null, pack.type('list'));
        Expect.equals(null, pack.type('map'));
        Expect.equals(null, pack.type('test'));
        Expect.equals(null, pack.type('tests'));
        Expect.throws(() => assetManager.root.testpack);
      }));
    });
    test('reload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.equals(true, pack.loadedSuccessfully);
        Expect.equals(1, assetManager.root.length);
        Expect.notEquals(null, assetManager.root.testpack);
        assetManager.deregisterPack('testpack');
        Expect.equals(0, pack.length);
        Expect.throws(() => assetManager.root.testpack);
        futurePack = assetManager.loadPack('testpack', 'testpack.pack');
        futurePack.then((pack) {
          Expect.equals(true, pack.loadedSuccessfully);
          Expect.equals(5, pack.length);
          Expect.equals(1, assetManager.root.length);
          Expect.equals(pack, assetManager.root.testpack);
          Expect.equals('json', pack.type('list'));
          Expect.equals('json', pack.type('map'));
          Expect.equals('json', pack.type('test'));
          Expect.equals('text', pack.type('tests'));
          Expect.notEquals(null, assetManager.root.testpack);
          assetManager.deregisterPack('testpack');
          Expect.throws(() => assetManager.deregisterPack('testpack'));
          Expect.throws(() => assetManager.root.testpack);
        });
      }));
    });
  }

  static void dynamicPackTest() {
    test('registerAsset', () {
      AssetManager assetManager = new AssetManager();
      Asset asset1 = assetManager.registerAssetAtPath('packy.text', 'text',
          'hello');
      Expect.throws(() {
        // Second attempt to register asset 'packy.text' throws argument error.
        Asset asset2 = assetManager.registerAssetAtPath('packy.text', 'foo', '');
      });
      // Asset can be accessed via assets map.
      Asset foundAsset = assetManager.getAssetAtPath('packy.text');
      Expect.equals(foundAsset, asset1);
      // Asset properly registered:
      Expect.equals(assetManager.root.packy.text, 'hello');
      Expect.equals(asset1.importer, null);
      Expect.equals(asset1.loader, null);
      Expect.equals(asset1.status, 'OK');
      Expect.equals(asset1.type, 'text');
      Expect.equals(asset1.pack.type('text'), 'text');
      assetManager.deregisterAssetAtPath('packy.text');
      // Pack is removed.
      Expect.throws(() {
        // Access a non-existant asset throws.
        var i = assetManager.root.packy;
      });
      // Asset is not findable.
      Expect.throws(() {
        assetManager.getAssetAtPath('packy.text');
      });
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
    });
  }
}

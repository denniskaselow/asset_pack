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

class Manager {
  static void loadTest() {
    AssetManager assetManager = new AssetManager();
    Future<AssetPack> futurePack;
    test('success.', () {
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.notEquals(pack, null);
        Expect.equals(true, pack.loadedSuccessfully);
        Expect.equals(4, pack.length);
        Expect.equals(1, assetManager.length);
        Expect.equals(4, assetManager.testpack.length);
        Expect.equals(pack, assetManager.testpack);
        Expect.equals(assetManager.getAssetAtPath('testpack.list'),
                      assetManager.testpack.list);
        Expect.equals(assetManager.getAssetAtPath('testpack'), null);
        Expect.equals(assetManager.getAssetAtPath('testpack.'), null);
        Expect.equals(assetManager.getAssetAtPath('.'), null);
        Expect.equals(assetManager.getAssetAtPath(''), null);
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
        Expect.equals(1, assetManager.length);
        Expect.notEquals(null, assetManager.testpack);
        assetManager.unloadPack('testpack');
        Expect.equals(0, pack.length);
        Expect.equals(0, assetManager.length);
        Expect.equals(null, pack.type('list'));
        Expect.equals(null, pack.type('map'));
        Expect.equals(null, pack.type('test'));
        Expect.equals(null, pack.type('tests'));
        Expect.throws(() => assetManager.testpack);
      }));
    });
    test('reload', () {
      AssetManager assetManager = new AssetManager();
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack.pack');
      futurePack.then(expectAsync1((pack) {
        Expect.equals(true, pack.loadedSuccessfully);
        Expect.equals(1, assetManager.length);
        Expect.notEquals(null, assetManager.testpack);
        assetManager.unloadPack('testpack');
        Expect.equals(0, pack.length);
        Expect.throws(() => assetManager.testpack);
        futurePack = assetManager.loadPack('testpack', 'testpack.pack');
        futurePack.then((pack) {
          Expect.equals(true, pack.loadedSuccessfully);
          Expect.equals(4, pack.length);
          Expect.equals(1, assetManager.length);
          Expect.equals(pack, assetManager.testpack);
          Expect.equals('json', pack.type('list'));
          Expect.equals('json', pack.type('map'));
          Expect.equals('json', pack.type('test'));
          Expect.equals('text', pack.type('tests'));
          Expect.notEquals(null, assetManager.testpack);
          assetManager.unloadPack('testpack');
          assetManager.unloadPack('testpack');
          Expect.throws(() => assetManager.testpack);
        });
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
  }
}

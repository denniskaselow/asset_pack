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

class Loader {
  static void imageTest() {
    AssetLoaderImage imageLoader = new AssetLoaderImage();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.png',
                                          'png', {}, {});
      loaded = imageLoader.load(assetRequest);
      loaded.then(expectAsync1((ImageElement imageElement) {
        Expect.equals(null, imageElement);
      }));
    });
    test('64x64 png', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'test.png', 'png', {},
                                          {});
      loaded = imageLoader.load(assetRequest);
      loaded.then(expectAsync1((ImageElement imageElement) {
        Expect.notEquals(null, imageElement);
        Expect.equals(64, imageElement.width);
        Expect.equals(64, imageElement.height);
      }));
    });
  }

  static void arrayBufferTest() {
    AssetLoaderArrayBuffer arrayBufferLoader = new AssetLoaderArrayBuffer();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'bin', {}, {});
      loaded = arrayBufferLoader.load(assetRequest);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        Expect.equals(null, arrayBuffer);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var assetRequest = new AssetRequest('binarydata', '', 'binarydata.bin',
                                          'bin', {}, {});
      loaded = arrayBufferLoader.load(assetRequest);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        Expect.notEquals(null, arrayBuffer);
        Expect.equals(32, arrayBuffer.byteLength);
      }));
    });
  }

  static void blobTest() {
    AssetLoaderBlob blobLoader = new AssetLoaderBlob();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'bin', {}, {});
      loaded = blobLoader.load(assetRequest);
      loaded.then(expectAsync1((Blob blob) {
        Expect.equals(null, blob);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var assetRequest = new AssetRequest('binarydata', '', 'binarydata.bin',
                                          'bin', {}, {});
      loaded = blobLoader.load(assetRequest);
      loaded.then(expectAsync1((Blob blob) {
        Expect.notEquals(null, blob);
        Expect.equals(32, blob.size);
      }));
    });
  }

  static void textTest() {
    AssetLoaderText textLoader = new AssetLoaderText();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'text', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.equals(null, text);
      }));
    });
    test('test.json', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'test.json',
                                          'json', {}, {});
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        Expect.notEquals(null, text);
        Expect.equals('{"a":[1,2,3]}\n', text);
      }));
    });
  }


  static void runTests() {
    group('AssetLoaderImage', () {
      Loader.imageTest();
    });
    group('AssetLoaderArrayBuffer', () {
      Loader.arrayBufferTest();
    });
    group('AssetLoaderBlob', () {
      Loader.blobTest();
    });
    group('AssetLoaderText', () {
      Loader.textTest();
    });
  }
}
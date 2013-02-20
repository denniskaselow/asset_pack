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

class Loader {
  static final AssetPackTrace trace = new AssetPackTrace();
  static void imageTest() {
    ImageLoader imageLoader = new ImageLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.png',
                                          'png', {}, {}, trace);
      loaded = imageLoader.load(assetRequest);
      loaded.then(expectAsync1((ImageElement imageElement) {
        expect(imageElement, null);
      }));
    });
    test('64x64 png', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'test.png', 'png', {},
                                          {}, trace);
      loaded = imageLoader.load(assetRequest);
      loaded.then(expectAsync1((ImageElement imageElement) {
        expect(imageElement == null, false);
        expect(imageElement.width, 64);
        expect(imageElement.height, 64);
      }));
    });
  }

  static void arrayBufferTest() {
    ArrayBufferLoader arrayBufferLoader = new ArrayBufferLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'bin', {}, {}, trace);
      loaded = arrayBufferLoader.load(assetRequest);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        expect(arrayBuffer, null);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var assetRequest = new AssetRequest('binarydata', '', 'binarydata.bin',
                                          'bin', {}, {}, trace);
      loaded = arrayBufferLoader.load(assetRequest);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        expect(arrayBuffer == null, false);
        expect(arrayBuffer.byteLength, 32);
      }));
    });
  }

  static void blobTest() {
    BlobLoader blobLoader = new BlobLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'bin', {}, {}, trace);
      loaded = blobLoader.load(assetRequest);
      loaded.then(expectAsync1((Blob blob) {
        expect(blob, null);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var assetRequest = new AssetRequest('binarydata', '', 'binarydata.bin',
                                          'bin', {}, {}, trace);
      loaded = blobLoader.load(assetRequest);
      loaded.then(expectAsync1((Blob blob) {
        expect(blob == null, false);
        expect(blob.size, 32);
      }));
    });
  }

  static void textTest() {
    TextLoader textLoader = new TextLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.bin',
                                          'text', {}, {}, trace);
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        expect(text, null);
      }));
    });
    test('test.json', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'test.json',
                                          'json', {}, {}, trace);
      loaded = textLoader.load(assetRequest);
      loaded.then(expectAsync1((String text) {
        expect(text == null, false);
        expect(text, '{"a":[1,2,3]}\n');
      }));
    });
  }

  static void videoTest() {
    VideoLoader videoLoader = new VideoLoader();
    test('404', () {
      Future loaded;
      var assetRequest = new AssetRequest('notthere', '', 'notthere.mp4',
                                          'mp4', {}, {}, trace);
      loaded = videoLoader.load(assetRequest);
      loaded.then(expectAsync1((VideoElement videoElement) {
        expect(videoElement, null);
      }));
    });
    test('webm', () {
      Future loaded;
      var assetRequest = new AssetRequest('test', '', 'big_buck_bunny.webm',
                                          'webm', {}, {}, trace);
      loaded = videoLoader.load(assetRequest);
      loaded.then(expectAsync1((VideoElement videoElement) {
        expect(videoElement == null, false);
        expect(videoElement.videoWidth, 640);
        expect(videoElement.videoHeight, 360);
      }));
    });
  }

  static void runTests() {
    group('ImageLoader', () {
      Loader.imageTest();
    });
    group('ArrayBufferLoader', () {
      Loader.arrayBufferTest();
    });
    group('BlobLoader', () {
      Loader.blobTest();
    });
    group('TextLoader', () {
      Loader.textTest();
    });
    group('VideoLoader', () {
      Loader.videoTest();
    });
  }
}
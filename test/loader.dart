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

  static void expectLoadTrace(AssetPackTraceAccumulator tracer, {bool withError : false}) {
    var es = tracer.events;
    if (withError) {
      expect(
          es.singleWhere((e) => e.type == AssetPackTraceEvent.assetLoadError),
          isNot(throws)
      );
    } else {
      expect(
          () => es.singleWhere(
              (e) => e.type == AssetPackTraceEvent.assetLoadError
          ),
          throws
      );
    }
    expect(
        es.singleWhere((e) => e.type == AssetPackTraceEvent.assetLoadStart),
        isNot(throws)
    );
    expect(
        es.singleWhere((e) => e.type == AssetPackTraceEvent.assetLoadEnd),
        isNot(throws)
    );
  }

  static void imageTest() {
    ImageLoader imageLoader = new ImageLoader();
    test('404', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var asset = new Asset(null, 'notthere', '', 'notthere.png',
                            'png', null, {}, null, {});
      loaded = imageLoader.load(asset, tracer);
      loaded.then(expectAsync1((ImageElement imageElement) {
        expect(imageElement, null);
        expectLoadTrace(tracer, withError : true);
      }));
    });
    test('64x64 png', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var asset = new Asset(null, 'test', '', 'test.png', 'png',
                            null, {}, null, {});
      loaded = imageLoader.load(asset, tracer);
      loaded.then(expectAsync1((ImageElement imageElement) {
        expect(imageElement == null, false);
        expect(imageElement.width, 64);
        expect(imageElement.height, 64);
        expectLoadTrace(tracer, withError : false);
      }));
    });
  }

  static void arrayBufferTest() {
    ArrayBufferLoader arrayBufferLoader = new ArrayBufferLoader();
    test('404', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'notthere', '', 'notthere.bin',
                                   'bin', null, {}, null, {});
      loaded = arrayBufferLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        expect(arrayBuffer, null);
        expectLoadTrace(tracer, withError : true);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'binarydata', '', 'binarydata.bin',
                                   'bin', null, {}, null, {});
      loaded = arrayBufferLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((ArrayBuffer arrayBuffer) {
        expect(arrayBuffer == null, false);
        expect(arrayBuffer.byteLength, 32);
        expectLoadTrace(tracer, withError : false);
      }));
    });
  }

  static void blobTest() {
    BlobLoader blobLoader = new BlobLoader();
    test('404', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'notthere', '', 'notthere.bin',
                                   'bin', null, {}, null, {});
      loaded = blobLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((Blob blob) {
        expect(blob, null);
        expectLoadTrace(tracer, withError : true);
      }));
    });
    test('32 bytes', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'binarydata', '', 'binarydata.bin',
                                   'bin', null, {}, null, {});
      loaded = blobLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((Blob blob) {
        expect(blob == null, false);
        expect(blob.size, 32);
        expectLoadTrace(tracer, withError : false);
      }));
    });
  }

  static void textTest() {
    TextLoader textLoader = new TextLoader();
    test('404', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'notthere', '', 'notthere.bin',
                                   'text', null, {}, null, {});
      loaded = textLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((String text) {
        expect(text, null);
        expectLoadTrace(tracer, withError : true);
      }));
    });
    test('test.json', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'test', '', 'test.json',
                                   'json', null, {}, null, {});
      loaded = textLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((String text) {
        expect(text == null, false);
        String expected = '{"a":[1,2,3]}';
        expect(text.startsWith(expected), true);
        expectLoadTrace(tracer, withError : false);
      }));
    });
  }

  static void videoTest() {
    VideoLoader videoLoader = new VideoLoader();
    test('404', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'notthere', '', 'notthere.mp4',
                                   'mp4', null, {}, null, {});
      loaded = videoLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((VideoElement videoElement) {
        expect(videoElement, null);
        expectLoadTrace(tracer, withError : true);
      }));
    });
    test('webm', () {
      Future loaded;
      var tracer = new AssetPackTraceAccumulator();
      var assetRequest = new Asset(null, 'test', '', 'big_buck_bunny.webm',
                                   'webm', null, {}, null, {});
      loaded = videoLoader.load(assetRequest, tracer);
      loaded.then(expectAsync1((VideoElement videoElement) {
        expect(videoElement == null, false);
        expect(videoElement.videoWidth, 640);
        expect(videoElement.videoHeight, 360);
        expectLoadTrace(tracer, withError : false);
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
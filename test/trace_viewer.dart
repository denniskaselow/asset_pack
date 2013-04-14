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

class TraceViewer {
  static void generateTraceViewForPack() {
    AssetManager assetManager = new AssetManager(new AssetPackTrace());
    test('manual test load trace view into "chrome://tracing/"', () {
      Future.wait([
        assetManager.loadPack('testpack', 'testpack.pack'),
        assetManager.loadPack('testpack2', 'testpackbadname.pack'),
        assetManager.loadPack('brokenpack', 'brokenpack.pack')
      ]).then(expectAsync1((packs) {
        expect(packs.length, 3);
        var traceView = assetManager.tracer.toTraceViewer();
        print("""
          Manual test :
          1. save the following json into a file:
             ${traceView}
          2. load in "chrome://tracing/"
        """);
//        var blob = new Blob([traceView], 'application/json');
//        window.requestFileSystem(1024*1024).then((fs) =>
//          fs.root.createFile('testpack.trace')
//        )
//        .then((f) {
//          print('trace view to load in "chrome://tracing/" : ${f.fullPath}');
//          return (f as FileEntry).createWriter();
//        })
//        .then(expectAsync1((fw) => fw.write(blob)))
//        .catchError((err){
//          print(err.stackTrace);
//          expect(err, isNull);
//        })
//        ;
      }));
    });
  }

  static void runTests() {
    group('traceview', () {
      generateTraceViewForPack();
    });
  }
}



import 'dart:io';
import 'dart:json';

class PackedAsset {
  final String name;
  final String url;
  final String type;
  PackedAsset(this.name, this.url, this.type);
}

class PackGenerator {
  final List<PackedAsset> assets = new List<PackedAsset>();
  bool _valid = false;
  Future generate(String dirPath) {
    assets.clear();
    _valid = false;
    Directory directory = new Directory(dirPath);
    var list = directory.list(recursive:true);
    list.onFile = (file) {
      if (file.startsWith(dirPath) == false) {
        return;
      }
      file = file.substring(dirPath.length);
      Path filePath = new Path(file);
      String type = filePath.directoryPath.filenameWithoutExtension;
      String filename = filePath.filenameWithoutExtension;
      String url = file;
      PackedAsset asset = new PackedAsset(filename, url, type);
      assets.add(asset);
    };
    Completer completer = new Completer();
    list.onDone = (_) {
      assets.sort((a, b) {
        return Comparable.compare(a.name, b.name);
      });
      completer.complete(true);
    };
    return completer.future;
  }

  void lint() {
    String prevName = null;
    _valid = true;
    assets.forEach((asset) {
      if (prevName == null) {
        prevName = asset.name;
        return;
      }
      if (prevName == asset.name) {
        print('Error duplicate name: ${asset.name}');
        _valid = false;
      }
      prevName = asset.name;
    });
  }

  bool get isValid => _valid;

  List<Map> prepareOutput() {
    List<Map> output = new List<Map>();
    assets.forEach((asset) {
      Map assetEntry = {
                        "name": asset.name,
                        "type": asset.type,
                        "url": asset.url,
                        "loadArguments": {},
                        "importArguments": {},
      };
      output.add(assetEntry);
      print(assetEntry);
    });
    return output;
  }

  void output(String path) {
    File out = new File(path);
    RandomAccessFile raf = out.openSync(FileMode.WRITE);
    raf.writeStringSync(JSON.stringify(prepareOutput()));
    raf.closeSync();
  }
}

main() {
  String path = '/Users/johnmccutchan/workspace/assetpack/test/testpack';
  PackGenerator generator = new PackGenerator();
  generator.generate(path).then((_) {
    generator.lint();
    if (generator.isValid == false) {
      print('Cannot generate pack file.');
      return;
    }
    generator.output('$path.pack');
  });
}
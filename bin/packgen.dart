import 'dart:io';
import 'dart:json';
import 'package:asset_pack/asset_pack_file.dart';

Future<List<String>> findAllAssetPaths(String dirPath) {
  var assetPaths = new List<String>();
  var completer = new Completer<List<String>>();
  var directory = new Directory(dirPath);
  var list = directory.list(recursive:true);
  list.onFile = (file) {
    if (file.startsWith(dirPath) == false) {
      return;
    }
    file = file.substring(dirPath.length);
    assetPaths.add(file);
  };
  list.onDone = (_) {
    completer.complete(assetPaths);
  };
  return completer.future;
}

AssetPackFile openAssetPackFile(String path) {
  File out = new File(path);
  String contents;
  try {
    contents = out.readAsStringSync();
  } catch (_) {
    print('Could not open existing asset pack file.');
    print('Creating new assset pack.');
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  List<Map> json;
  try {
    json = JSON.parse(contents);
  } catch (_) {
    print('Could not parse existing asset pack file.');
    print('Creating new assset pack.');
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  print('Loaded existing asset pack file.');
  return new AssetPackFile.fromJson(json);
}

void merge(AssetPackFile packFile, List<String> assetPaths) {
  assetPaths.forEach((assetPath) {
    Path path = new Path(assetPath);
    String name = path.filenameWithoutExtension;
    String type = path.directoryPath.filename;
    String url = assetPath;
    if (packFile.assets.containsKey(name)) {
      print('Old asset pack already has $name');
      return;
    }
    print('Adding new asset $name ($url) (type=$type)');
    packFile.assets[name] = new AssetPackFileAsset(name, url, type);
  });
  packFile.assets.forEach((k, v) {
    if (assetPaths.contains(v.url)) {
      return;
    }
    print('Removing asset $k which no longer exists.');
    packFile.assets.remove(k);
  });
}

void output(AssetPackFile packFile, String path) {
  File out = new File(path);
  RandomAccessFile raf;
  try {
    raf = out.openSync(FileMode.WRITE);
  } catch (_) {
    print('Could not open $path for writing.');
    return;
  }
  String serialized;
  try {
    serialized = JSON.stringify(packFile);
  } catch (_) {
    print('Could not serialize pack file into JSON');
    return;
  }
  print('Writing packfile to: $path');
  raf.writeStringSync(serialized);
  raf.closeSync();
}

String inPath = '/Users/johnmccutchan/workspace/assetpack/test/testpack';
String outPath = '$inPath.pack';

main() {
  var futureAssetPaths = findAllAssetPaths(inPath);
  futureAssetPaths.then((assetPaths) {
    AssetPackFile packFile = openAssetPackFile(outPath);
    merge(packFile, assetPaths);
    output(packFile, outPath);
  });
}
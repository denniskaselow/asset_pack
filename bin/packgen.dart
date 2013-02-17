import 'dart:io';
import 'dart:json' as JSON;
import 'package:asset_pack/asset_pack_file.dart';

AssetPackFile openAssetPackFile(String path) {
  File out = new File.fromPath(new Path(path));
  String contents;
  try {
    contents = out.readAsStringSync();
  } catch (_) {
    print('Could not open existing asset pack file.');
    print('Creating new assset pack.');
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  var json;
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
    String type = '';
    String url = assetPath;
    if (packFile.assets.containsKey(name)) {
      print('Old asset pack already has $name');
      return;
    }
    if (name == '') {
      print('Skipping $url because it has no name.');
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
  File out = new File.fromPath(new Path(path));
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

main() {
  Options options = new Options();
  String pathString;

  // There are some workarounds required for running on Windows
  bool isWindows = Platform.operatingSystem == 'windows';

  if (options.arguments.length == 0) {
    print('Usage: dart packgen.dart <path>.');
    return;
  } else {
    pathString = options.arguments[0];
  }

  // Always have a / at the end of the path.
  pathString = '$pathString\/';
  Path path = new Path(pathString).canonicalize().directoryPath;

  // If the path is not absolute create the absolute path
  if (path.isAbsolute == false) {
    Directory working = new Directory.current();
    Path fullPath = new Path(working.path);
    path = fullPath.join(path);
  }

  String packPathString = '${path}.pack';
  print('Scanning $path for assets.');
  print('Adding assets to $packPathString');
  List<String> assetPaths = new List<String>();
  Directory dir = new Directory.fromPath(path);
  pathString = path.toString();

  // Workaround for Windows
  //
  // The path string is prefixed with a '/' but the results
  // of File.fullPathSync are not prefixed with that. To do the
  // matching the '/' must be removed.
  if (isWindows) {
    pathString = pathString.substring(1);
  }

  int pathStringLength = pathString.length;
  dir.listSync(recursive:true).forEach((listing) {
    if (listing is File) {
      String filePathString = listing.fullPathSync();

      // Workaround for Windows
      //
      // File.fullPathSync returns a string with '\' as the
      // path separator.
      if (isWindows) {
        filePathString = filePathString.replaceAll('\\', '/');
      }

      // Workaround for pub symbolic links
      if (filePathString.startsWith(pathString)) {
        assetPaths.add(filePathString.substring(pathStringLength));
      }
    }
  });
  AssetPackFile packFile = openAssetPackFile(packPathString);
  merge(packFile, assetPaths);
  output(packFile, packPathString);
}
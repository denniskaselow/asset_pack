import 'dart:async';
import 'dart:io';
import 'dart:json' as Json;
import 'package:unittest/unittest.dart';
import 'package:asset_pack/asset_pack_file.dart';

/// Signature for a packgen test.
typedef Future PackgenTest();
typedef void PackgenTestStartup();

//---------------------------------------------------------------------
// Test callback
//---------------------------------------------------------------------

int completed = 0;
Function finished;

/// Dummy callback to trick unittest.
void testComplete(name) {
  completed++;
  print('Test $completed $name completed');
}

//---------------------------------------------------------------------
// Utility functions
//---------------------------------------------------------------------

/// Opens an [AssetPackFile] at the given [path].
AssetPackFile openAssetPackFile(String path) {
  File out = new File(path);
  String contents;
  try {
    contents = out.readAsStringSync();
  } catch (_) {
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  var json;
  try {
    json = Json.parse(contents);
  } catch (e) {
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  return new AssetPackFile.fromJson(json);
}

/// Copy the contents of a file to another file.
void copyFileContents(File original, File copy) {
  var input = original.openRead();
  var output = copy.openWrite();
  input.pipe(output).then((_) => output.close());
}

/// Copy the contents of the directory.
void copyDirectoryContents(Directory original, Directory copy) {
  String originalPath = original.path;
  String copyPath = copy.path;

  original.listSync().forEach((listing) {
    if (listing is File) {
      File originalFile = listing as File;

      // File.name outputs the full path
      // Convert '\' to '/' since Windows uses '\' as a separator
      // Determine the filename by looking at the last '/'. This works since
      // the traversal is not recursive
      String fullPath = originalFile.path.replaceAll('\\', '/');
      String filename = fullPath.substring(fullPath.lastIndexOf('/') + 1);

      // Create the new File
      String copyFilePath = '$copyPath/$filename';
      File copyFile = new File(copyFilePath);
      copyFile.createSync();

      // Copy the file
      copyFileContents(originalFile, copyFile);
    }
  });
}

/// Delete the contents of the directory.
void deleteDirectoryContents(Directory directory) {
  directory.listSync().forEach((listing) {
    if (listing is File) {
      File file = listing as File;

      file.deleteSync();
    }
  });

  directory.deleteSync();
}

//---------------------------------------------------------------------
// Test functions
//---------------------------------------------------------------------

/// Compares the contents of the [AssetPackFile] vs the given [directory].
void checkPackFile(AssetPackFile assetPack, Directory directory) {
  List<String> filePaths = new List<String>();
  int directoryPathLength = directory.path.length;

  // Check that all files are present
  directory.listSync(recursive: true).forEach((listing) {
    if (listing is File) {
      File file = listing as File;

      // Get the relative path
      // Make sure the path separator is '/'
      String relativeFilePath = file.fullPathSync().substring(directoryPathLength);
      relativeFilePath = relativeFilePath.replaceAll('\\', '/');

      filePaths.add(relativeFilePath);
    }
  });

  expect(assetPack.assets.length, filePaths.length);

  // Check that each individual file is contained in the pack
  assetPack.assets.values.forEach((value) {
    expect(filePaths.contains(value.url), true);
  });
}

/// Compares the contents of two [AssetPackFile]s.
void comparePackFiles(AssetPackFile actual, AssetPackFile expected) {
  // Should have the same length
  Map actualAssets = actual.assets;
  Map expectedAssets = expected.assets;

  expect(actualAssets.length, expectedAssets.length);

  // Compare the individual keys
  expectedAssets.keys.forEach((key) {
    expect(actualAssets.containsKey(key), true);

    // Compare the two JSON maps
    Map actualAsset = actualAssets[key].toJson();
    Map expectedAsset = expectedAssets[key].toJson();

    expect(actualAsset, expectedAsset);
  });
}

/// Runs an individual test
Future runPackgenTest(String name, Directory directory, dynamic onStartup, dynamic onTest) {
  // Run the function to setup the enviornment
  onStartup();

  Completer completer = new Completer();
  Process.start('dart', ['bin/packgen.dart', directory.path]).then((process) {
    // Add a delay to give some time for file operations to complete
    Timer delay = new Timer(new Duration(milliseconds:100), () {
      test(name, () {
        AssetPackFile generatedPackFile = openAssetPackFile('test/testpack_copy.pack');

        onTest(generatedPackFile, directory);
        completer.complete();
      });
    });
  });

  return completer.future;
}

/// Runs the individual tests.
///
/// Each test requires an asynchronous operation, this is the packgen process,
/// to occur. And each test needs to be run in succession. This function is a
/// hack to ensure this happens.
void runTest(List<PackgenTest> tests, int index) {
  if (index == tests.length) {
    return;
  }

  tests[index]().then((_) {
    runTest(tests, index + 1);
  });
}

void main() {
  // Copy the directory to a temporary one
  // Working directory is the root asset_pack dir by default
  // Directory.path does not give the full path unless the full path is
  // specified. There's also no way to get the full path so use the working
  // directory to get the full path because File.name has the full path.
  Directory workingDirectory = Directory.current;
  Path currentPath = new Path(workingDirectory.path);

  Directory original = new Directory.fromPath(currentPath.join(new Path('test/testpack')));
  Directory originalSubpack = new Directory.fromPath(currentPath.join(new Path('test/testpack/subpack')));
  Directory originalJson = new Directory.fromPath(currentPath.join(new Path('test/testpack/json')));
  Directory originalText = new Directory.fromPath(currentPath.join(new Path('test/testpack/text')));

  Directory copy = new Directory.fromPath(currentPath.join(new Path('test/testpack_copy')));
  Directory copySubpack = new Directory.fromPath(currentPath.join(new Path('test/testpack_copy/subpack')));
  Directory copyJson = new Directory.fromPath(currentPath.join(new Path('test/testpack_copy/json')));
  Directory copyText = new Directory.fromPath(currentPath.join(new Path('test/testpack_copy/text')));
  copy.createSync();

  List<PackgenTest> tests = new List<PackgenTest>();
  PackgenTestStartup setup;

  tests.add(() => runPackgenTest('empty file', copy, () { }, checkPackFile));
  tests.add(() => runPackgenTest('single file', copy, () { copyDirectoryContents(original, copy); }, checkPackFile));

  // Add the subpack directory
  Function subpackCreate = () {
    copySubpack.createSync();
    copyDirectoryContents(originalSubpack, copySubpack);
  };

  tests.add(() => runPackgenTest('subpack', copy, subpackCreate, checkPackFile));

  // Add the JSON directory
  Function jsonCreate = () {
    copyJson.createSync();
    copyDirectoryContents(originalJson, copyJson);
  };

  tests.add(() => runPackgenTest('subpack + json', copy, jsonCreate, checkPackFile));

  // Add the text directory
  Function textCreate = () {
    copyText.createSync();
    copyDirectoryContents(originalText, copyText);
  };

  // Add an additional check that compares the asset pack file
  Function compareOutput = (AssetPackFile assetPack, Directory directory) {
    AssetPackFile expected = openAssetPackFile('test/testpack_expected.pack');

    checkPackFile(assetPack, directory);
    comparePackFiles(assetPack, expected);
  };

  tests.add(() => runPackgenTest('subpack + json + text', copy, textCreate, compareOutput));

  // Remove the test directory
  Function textDelete = () {
    deleteDirectoryContents(copyText);
  };

  tests.add(() => runPackgenTest('subpack + json - text', copy, textDelete, checkPackFile));

  // Remove the json directory
  Function jsonDelete = () {
    deleteDirectoryContents(copyJson);
  };

  tests.add(() => runPackgenTest('subpack - json - text', copy, jsonDelete, checkPackFile));

  // Remove the subpack directory
  Function subpackDelete = () {
    deleteDirectoryContents(copySubpack);
  };

  tests.add(() => runPackgenTest('-subpack - json - text', copy, subpackDelete, checkPackFile));

  // Not a test but lets us cleanup after all the tests are complete
  tests.add(() {
    deleteDirectoryContents(copy);
    return new Future.value(null);
  });

  runTest(tests, 0);
}

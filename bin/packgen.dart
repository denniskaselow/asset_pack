import 'dart:io';

class PackedAsset {
  final String name;
  final String url;
  final String type;
  PackedAsset(this.name, this.url, this.type);
}

class PackGenerator {
  void generate(String dirPath) {
    Directory directory = new Directory(dirPath);
    var list = directory.list(recursive:true);
    List<PackedAsset> assets = new List<PackedAsset>();
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
    list.onDone = (_) {
      assets.sort((a, b) {
        return Comparable.compare(a.type, b.type);
      });
      assets.forEach((asset) {
        print('${asset.type} ${asset.name} [/${asset.url}]');
      });
    };
  }
}

main() {
  PackGenerator generator = new PackGenerator();
  generator.generate('/Users/johnmccutchan/workspace/javelin/web/demo_launcher/data/');
}
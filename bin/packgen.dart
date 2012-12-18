
class PackedAsset {
  String name;
  String url;
  String type;
}

class PackGenerator {
  void generate(String directory) {
    // Directory contains subdirectories for each type, e.g. texture2d
    // Walk each type directory creating packed asset.
  }
}

main() {
  PackGenerator generator = new PackGenerator();
  generator.generate('/asset_path/');
}
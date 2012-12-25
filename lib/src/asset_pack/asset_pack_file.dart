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

part of asset_pack_file;

class AssetPackFileAsset {
  /** The name of the asset. */
  final String name;
  /** The url of the asset. */
  final String url;
  /** The type of the asset. */
  final String type;
  /** Arguments passed to the loader */
  final Map<String, dynamic> loadArguments = new Map<String, dynamic>();
  /** Arguments passed to the importer */
  final Map<String, dynamic> importArguments = new Map<String, dynamic>();

  /** Convert to JSON */
  Map toJson() {
    Map assetMap = new Map();
    assetMap['name'] = name;
    assetMap['url'] = url;
    assetMap['type'] = type;
    assetMap['loadArguments'] = loadArguments;
    assetMap['importArguments'] = importArguments;
    return assetMap;
  }

  /** Construct a new instance with no load or import arguments */
  AssetPackFileAsset(this.name, this.url, this.type);

  /** Construct a new instance from a Map */
  static AssetPackFileAsset fromJson(Map map) {
    String name = map['name'];
    String url = map['url'];
    String type = map['type'];
    Map loadArguments = map['loadArguments'];
    Map importArguments = map['importArguments'];
    AssetPackFileAsset asset = new AssetPackFileAsset(name, url, type);
    loadArguments.forEach((k, v) {
      asset.loadArguments[k] = v;
    });
    importArguments.forEach((k, v) {
      asset.importArguments[k] = v;
    });
    return asset;
  }
}

class AssetPackFile {
  /** Assets in the pack file */
  final Map<String, AssetPackFileAsset> assets =
      new Map<String, AssetPackFileAsset>();

  void _add(AssetPackFileAsset asset) {
    assets[asset.name] = asset;
  }

  void _copyArguments(AssetPackFileAsset newAsset, AssetPackFileAsset asset) {
    asset.loadArguments.forEach((k,v) {
      newAsset.loadArguments[k] = v;
    });
    asset.importArguments.forEach((k,v) {
      newAsset.importArguments[k] = v;
    });
  }

  /** Each pack file asset is added to the pack file. If an asset with the
   * same name already exists, its load and import arguments are copied.
   */
  void merge(List<AssetPackFileAsset> parsed) {
    parsed.forEach((asset) {
      AssetPackFileAsset existingAsset = assets[asset.name];
      if (existingAsset != null) {
        _copyArguments(asset, existingAsset);
        assets.remove(existingAsset.name);
        _add(asset);
      } else {
        _add(asset);
      }
    });
  }

  /** Each pack file asset is added to the pack file. If an asset with the
   * same name already exists, it is replaced.
   */
  void replace(List<AssetPackFileAsset> parsed) {
    parsed.forEach((asset) {
      AssetPackFileAsset existingAsset = assets[asset.name];
      if (existingAsset != null) {
        assets.remove(asset.name);
      }
      _add(asset);
    });
  }

  /** Clear all pack file assets. */
  void clear() {
    assets.clear();
  }

  /** Convert the pack file to JSON. */
  List<Map> toJson() {
    List<Map> json = new List<Map>();
    assets.forEach((name, asset) {
      json.add(asset.toJson());
    });
    return json;
  }

  /** Parse the packFile string into a list of pack file assets. */
  static List<AssetPackFileAsset> parse(String packFile) {
    var assets = new List<AssetPackFileAsset>();
    List<Map> parsed;
    try {
       parsed = JSON.parse(packFile);
    } catch (_) {
      return assets;
    }

    parsed.forEach((map) {
      assets.add(AssetPackFileAsset.fromJson(map));
    });

    return assets;
  }

  AssetPackFile();

  AssetPackFile.fromJson(List<Map> json) {
    if (json == null) {
      return;
    }
    json.forEach((map) {
      AssetPackFileAsset packFileAsset = AssetPackFileAsset.fromJson(map);
      assets[packFileAsset.name] = packFileAsset;
    });
  }
}

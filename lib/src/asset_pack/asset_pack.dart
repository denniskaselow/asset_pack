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

part of asset_pack;


/**
 * A set of assets. The importer property of an asset can be accessed as if
 * it were a property on the pack with the name of the asset. Metadata for
 * an asset can be accessed via the [assets] map. That means that the
 * following is true:
 *
 * pack.assets["assetName"].imported == pack.assetName
 *
 * Asset packs can contain other asset packs.
 *
 * You can determine the path of an asset pack by getting it's path variable.
 *
 */
class AssetPack extends PropertyMap {
  final AssetManager manager;
  final String name;
  final Map<String, Asset> assets = new Map<String, Asset>();
  bool _loadedSuccessfully = false;

  /// Was this pack loaded successfully?
  bool get loadedSuccessfully => _loadedSuccessfully;
  /// Parent pack or null.
  AssetPack parent;
  /// Path to this pack.
  String get path {
    if (parent == null) {
      return '';
    }
    String parentPath = parent.path;
    if (parentPath == '') {
      return name;
    } else {
      return '$parentPath.$name';
    }
  }

  AssetPack(this.manager, this.name) : super(_propertyMapConfig);

  /// Returns the type of [assetName].
  String type(String assetName) {
    Asset asset = assets[assetName];
    if (asset != null) {
      return asset.type;
    }
    return null;
  }

  /// Returns the url of [assetName].
  String url(String assetName) {
    Asset asset = assets[assetName];
    if (asset != null) {
      return asset.url;
    }
    return null;
  }

  /// Add asset to this pack.
  Asset registerAsset(String name, String type, dynamic imported) {
    if (AssetPackFile.validAssetName(name) == false) {
      throw new ArgumentError('$name is an invalid name.');
    }
    Asset asset = assets[name];
    if (asset != null) {
      throw new ArgumentError('$name already exists.');
    }
    // Create asset.
    asset = new Asset(this, name, '', type, null, null);
    asset.imported = imported;
    asset._status = 'OK';
    // Register asset in pack.
    assets[name] = asset;
    this[name] = imported;
    return asset;
  }

  /// Adds and loads an [Asset] to this pack.
  Future<Asset> loadAndRegisterAsset(String name, String url, String type, Map loaderArguments, Map importerArguments) {
    AssetPackTrace trace = new AssetPackTrace();
    trace.packLoadStart(name);
    AssetRequest assetRequest = new AssetRequest(name, url, '',
                                                 type, loaderArguments, importerArguments,
                                                 trace);
    Future futureAsset = manager._loadAndImport(assetRequest);

    Completer completer = new Completer();
    futureAsset.then((imported) {
      Asset asset = (imported != null) ? registerAsset(name, type, imported) : null;
      trace.packLoadEnd(name);
      completer.complete(asset);
    });

    return completer.future;
  }

  /// Remove an asset from this pack.
  void deregisterAsset(String name) {
    final asset = assets[name];
    if (asset == null) {
      throw new ArgumentError('$name does not exist.');
    }
    // Unregister asset in pack.
    assets.remove(name);
    remove(name);
  }

  /// Get asset's imported property at [path].
  dynamic getImportedAtPath(String path) {
    Asset asset = getAssetAtPath(path);
    if (asset != null) {
      return asset.imported;
    }
    return null;
  }

  /// Get asset metadata at [path]. Returns the [Asset] not the imported value
  Asset getAssetAtPath(String path) {
    List<String> splitPath = path.split(".");
    return _getAssetAtPath(path, splitPath);
  }

  Asset _getAssetAtPath(String fullAssetPath, List<String> assetPath) {
    if (assetPath.length == 0) {
      throw new ArgumentError('$fullAssetPath does not exist.');
    }
    String name = assetPath.removeAt(0);
    Asset asset = assets[name];
    if (asset.isPack && assetPath.length > 0) {
      AssetPack pack = asset.imported;
      return pack._getAssetAtPath(fullAssetPath, assetPath);
    }
    if (assetPath.length > 0) {
      throw new ArgumentError('$fullAssetPath does not exist.');
    }
    return asset;
  }

  /// Add a child asset pack to this asset pack.
  AssetPack registerPack(String name) {
    if (AssetPackFile.validAssetName(name) == false) {
      throw new ArgumentError('$name is an invalid name.');
    }
    Asset asset = assets[name];
    if (asset != null) {
      throw new ArgumentError('$name already exists.');
    }
    AssetPack pack = new AssetPack(manager, name);
    pack.parent = this;
    registerAsset(name, 'pack', pack);
    return pack;
  }

  /// Remove a child pack from this asset pack.
  void deregisterPack(String name) {
    if (AssetPackFile.validAssetName(name) == false) {
      throw new ArgumentError('$name is an invalid name.');
    }
    Asset asset = assets[name];
    if (asset == null) {
      throw new ArgumentError('$name does not exist.');
    }
    if (asset.isPack == false) {
      throw new ArgumentError('$name is not an asset pack.');
    }
    AssetPack pack = asset.imported;
    pack.parent = null;
    deregisterAsset(name);
    pack._unload();
  }

  /// Load the pack at [url] and add it as a child pack named [name].
  Future<AssetPack> loadPack(String name, String url) {
    if (assets[name] != null) {
      throw new ArgumentError('$name already exists.');
    }
    AssetPackTrace trace = new AssetPackTrace();
    trace.packLoadStart(name);
    AssetRequest assetRequest = new AssetRequest(name, url, '',
                                                 'pack', {}, {},
                                                 trace);
    Future<AssetPack> futurePack = manager._loadAndImport(assetRequest);
    return futurePack.then((p) {
      if (p != null) {
        p.parent = this;
        registerAsset(name, 'pack', p);
      }
      trace.packLoadEnd(name);
      print(trace.toTraceViewer());
      return new Future.immediate(p);
    });
  }

  /// Load many packs, adding each one as a child pack.
  /// [['packName', 'packUrl'], ['packName2', 'packUrl2']]
  Future loadPacks(List<List<String>> packs) {
    if (packs == null) {
      return new Future.immediate(null);
    }
    var futurePacks = new List<Future<AssetPack>>();
    packs.forEach((pack) {
      String name = pack[0];
      String url = pack[1];
      var futurePack = loadPack(name, url);
      futurePacks.add(futurePack);
    });
    return Future.wait(futurePacks);
  }

  /// Add an asset of [type] at [assetPath]. Will recursively
  /// create child packs.
  Asset registerAssetAtPath(String assetPath, String type, dynamic imported) {
    List<String> splitPath = assetPath.split(".");
    return _registerAssetAtPath(assetPath, splitPath, type, imported);
  }

  Asset _registerAssetAtPath(String fullAssetPath, List<String> assetPath,
                             String type, dynamic imported) {
    String name = assetPath.removeAt(0);
    if (assetPath.length == 0) {
      // Leaf
      return registerAsset(name, type, imported);
    } else {
      // Inner
      Asset packAsset = assets[name];
      if (packAsset != null) {
        if (packAsset.isPack == false) {
          throw new ArgumentError('Cannot register $fullAssetPath'
                                  'because of a conflict.');
        } else {
          AssetPack pack = packAsset.imported;
          return pack._registerAssetAtPath(fullAssetPath, assetPath, type,
                                           imported);
        }
      } else {
        AssetPack pack = registerPack(name);
        return pack._registerAssetAtPath(fullAssetPath, assetPath, type, imported);
      }
    }
  }

  /// Remove the asset at [assetPath].
  void deregisterAssetAtPath(String assetPath) {
    List<String> splitPath = assetPath.split(".");
    _deregisterAssetAtPath(assetPath, splitPath);
  }

  void _deregisterAssetAtPath(String fullAssetPath, List<String> assetPath) {
    String name = assetPath.removeAt(0);
    if (assetPath.length == 0) {
      // Leaf
      deregisterAsset(name);
    } else {
      // Inner
      Asset packAsset = assets[name];
      if (packAsset != null) {
        if (packAsset.isPack == false) {
          throw new ArgumentError('Cannot deregister $fullAssetPath'
                                  'because of a conflict.');
        } else {
          AssetPack pack = packAsset.imported;
          pack._deregisterAssetAtPath(fullAssetPath, assetPath);
          if (pack.assets.length == 0) {
            // Remove empty packs.
            deregisterAsset(name);
          }
        }
      } else {
        throw new ArgumentError('$fullAssetPath does not exist.');
      }
    }
  }

  void _unload() {
    _loadedSuccessfully = false;
    assets.forEach((name, asset) {
      asset._delete();
    });
    assets.clear();
    this.clear();
  }
}

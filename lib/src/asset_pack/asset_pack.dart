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


/** A pack of assets. You access the imported asset using named properties,
 * for example, if you have an asset named 'foo', you would acecss it by:
 *
 * assetPack.foo;
 */
class AssetPack extends PropertyMap {
  bool _invalidName(String name) {
    return name == 'manager' ||
           name == 'name' ||
           name == 'assets';
           name == 'loadedSuccessfully';
  }
  final AssetManager manager;
  final String name;
  final Map<String, Asset> assets = new Map<String, Asset>();
  bool _loadedSuccessfully = false;
  bool get loadedSuccessfully => _loadedSuccessfully;

  AssetPack(this.manager, this.name) : super(_propertyMapConfig);

  Asset registerAsset(String assetName, String type, dynamic imported) {
    if (_invalidName(assetName)) {
      throw new ArgumentError('$assetName is an invalid name.');
    }
    Asset asset = assets[assetName];
    if (asset != null) {
      throw new ArgumentError('$assetName already exists.');
    }
    // Create asset.
    asset = new Asset(this, assetName, '', type, null, null);
    asset._imported = imported;
    asset._status = 'OK';
    // Register asset in pack.
    assets[assetName] = asset;
    this[assetName] = imported;
    return asset;
  }

  void deregisterAsset(String assetName) {
    final asset = assets[assetName];
    if (asset == null) {
      throw new ArgumentError('$assetName does not exist.');
    }
    // Unregister asset in pack.
    assets.remove(assetName);
    remove(assetName);
  }

  Asset getAssetAtPath(String assetPath) {
    List<String> splitPath = assetPath.split(".");
    return _getAssetAtPath(assetPath, splitPath);
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

  AssetPack registerAssetPack(String assetPackName) {
    if (_invalidName(assetPackName)) {
      throw new ArgumentError('$assetPackName is an invalid name.');
    }
    Asset asset = assets[assetPackName];
    if (asset != null) {
      throw new ArgumentError('$assetPackName already exists.');
    }
    AssetPack pack = new AssetPack(manager, assetPackName);
    registerAsset(assetPackName, 'pack', pack);
    return pack;
  }

  /** Register a pack with [name] and load the contents from [url]. */
  Future<AssetPack> loadPack(String name, String url) {
    if (assets[name] != null) {
      throw new ArgumentError('$name already exists.');
    }
    AssetRequest assetRequest = new AssetRequest(name, url, '',
                                                 'pack', {}, {});
    Future<AssetPack> futurePack = manager._loadAndImport(assetRequest);
    return futurePack.then((p) {
      if (p != null) {
        registerAsset(name, 'pack', p);
      }
      return new Future.immediate(p);
    });
  }

  /** Load many packs at once. Results in a single Future to wait on.:
   *
   * [['packName', 'packUrl.pack'], ['packName2', 'packUrl2.pack']]
   */
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

  /** Unload pack with [name]. */
  void unloadPack(String name) {
    Asset asset = assets[name];
    if (asset == null) {
      throw new ArgumentError('$name does not exist.');
    }
    if (asset.isPack == false) {
      throw new ArgumentError('$name is not a pack.');
    }
    AssetPack pack = asset.imported;
    deregisterAsset(name);
    pack._unload();
  }

  /// Register an imported asset of [type] at [assetPath].
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
        AssetPack pack = registerAssetPack(name);
        return pack._registerAssetAtPath(fullAssetPath, assetPath, type, imported);
      }
    }
  }

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

  /** Returns the type of [assetName]. */
  String type(String assetName) {
    Asset asset = assets[assetName];
    if (asset != null) {
      return asset.type;
    }
    return null;
  }

  /** Returns the url of [assetName]. */
  String url(String assetName) {
    Asset asset = assets[assetName];
    if (asset != null) {
      return asset.url;
    }
    return null;
  }
}

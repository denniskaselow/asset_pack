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

part of asset_pack;

class AssetManager extends PropertyMap {
  /** A map from asset type to importers. Add your own importers. */
  final Map<String, AssetImporter> importers = new Map<String, AssetImporter>();
  /** A map from asset type to loader. Add your own loaders. */
  final Map<String, AssetLoader> loaders = new Map<String, AssetLoader>();
  AssetManager() {
    importers['json'] = new AssetImporterJson();
    importers['text'] = new AssetImporterText();
    loaders['json'] = new AssetLoaderText();
    loaders['text'] = loaders['json'];
  }

  /// Get imported asset at [assetPath].
  dynamic getAssetAtPath(String assetPath) {
    List<String> splitPath = assetPath.split(".");
    if (splitPath.length != 2) {
      return null;
    }
    String packName = splitPath[0];
    String assetName = splitPath[1];
    AssetPack pack = this[packName];
    if (pack == null) {
      return null;
    }
    return pack[assetName];
  }

  /// Register a new asset pack.
  AssetPack registerAssetPack(String assetPackName) {
    AssetPack pack = this[assetPackName];
    if (pack != null) {
      return pack;
    }
    pack = new AssetPack(this, assetPackName);
    this[assetPackName] = pack;
    return pack;
  }

  /// Register an imported asset of [type] at [assetPath].
  Asset registerAssetAtPath(String assetPath, String type, dynamic imported) {
    List<String> splitPath = assetPath.split(".");
    if (splitPath.length != 2) {
      return null;
    }
    String packName = splitPath[0];
    String assetName = splitPath[1];
    AssetPack pack = this[packName];
    if (pack == null) {
      // Add new pack.
      pack = registerAssetPack(packName);
    }
    Asset asset = pack.assets[assetName];
    if (asset != null) {
      return asset;
    }
    // Create asset.
    asset = new Asset(pack, assetName, '', type, null, null);
    asset._imported = imported;
    asset._status = 'OK';
    // Register asset in pack.
    pack.assets[assetName] = asset;
    pack[assetName] = imported;
    return asset;
  }

  void deregisterAssetAtPath(String assetPath) {
    List<String> splitPath = assetPath.split(".");
    if (splitPath.length != 2) {
      return;
    }
    String packName = splitPath[0];
    String assetName = splitPath[1];
    AssetPack pack = this[packName];
    if (pack == null) {
      return;
    }
    Asset asset = pack.assets[assetName];
    if (asset == null) {
      return;
    }
    // Remove asset from pack.
    pack.assets.remove(assetName);
    // Remove empty packs.
    if (pack.assets.length == 0) {
      this.remove(packName);
    }
  }

  /** Register a pack with [name] and load the contents from [url].
   * The future will complete to [null] if the asset pack cannot be loaded. */
  Future<AssetPack> loadPack(String name, String url) {
    AssetPack assetPack = new AssetPack(this, name);
    if (containsKey(name)) {
      throw new ArgumentError('Already have a pack loaded with name: $name');
    }
    Completer<AssetPack> completer = new Completer<AssetPack>();
    assetPack._load(url).then((assetPack) {
      if (assetPack.loadedSuccessfully == true) {
        this[name] = assetPack;
        completer.complete(assetPack);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
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
    AssetPack assetPack = this[name];
    if (assetPack == null) {
      return;
    }
    remove(name);
    assetPack._unload();
  }
}

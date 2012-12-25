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

/** A pack of assets. You access the imported asset using named properties,
 * for example, if you have an asset named 'foo', you would acecss it by:
 *
 * assetPack.foo;
 *
 */
class AssetPack extends PropertyMap {
  final AssetManager manager;
  final String name;
  final Map<String, Asset> _assets = new Map<String, Asset>();
  //final Set<String> missingResources = new Set<String>();
  String _baseURL;

  bool _loadedSuccessfully = false;
  bool get loadedSuccessfully => _loadedSuccessfully;

  AssetPack(this.manager, this.name);

  void _setBaseURL(String url) {
    _baseURL = url.substring(0, url.lastIndexOf('.'));
  }

  Future<AssetPack> _load(String url) {
    _setBaseURL(url);
    _unload();
    AssetLoaderText loader = new AssetLoaderText();
    Future f = loader.load(url, {});
    Completer<AssetPack> completer = new Completer<AssetPack>();
    f.then((text) {
      if (text == null) {
        completer.complete(this);
        return;
      }
      List<Map> parsed = JSON.parse(text);
      _loadedSuccessfully = true;
      List<Future<Asset>> futureAssets = new List<Future<Asset>>();
      parsed.forEach((m) {
        String assetURL = '$_baseURL${m['url']}';
        String name = m['name'];
        String type = m['type'];
        AssetImporter importer = manager.importers[type];
        AssetLoader loader = manager.loaders[type];
        if (importer == null) {
          print('Cannot load $name ($assetURL) because there is no importer for $type');
          return;
        }
        if (loader == null) {
          print('Cannot load $name ($assetURL) because there is no loader for $type');
          return;
        }
        print('Loading $name from $assetURL');
        Asset asset = new Asset(this, name, assetURL, type, loader, importer);
        var futureAsset = asset._loadAndImport(m['load'], m['import']);
        futureAssets.add(futureAsset);
      });
      Futures.wait(futureAssets).then((List<Asset> assets) {
        assets.forEach((asset) {
          _assets[asset.name] = asset;
          this[asset.name] = asset.imported;
        });
        completer.complete(this);
      });
    });
    return completer.future;
  }

  void _unload() {
    //missingResources.clear();
    _loadedSuccessfully = false;
    _assets.forEach((name, asset) {
      asset._delete();
    });
    _assets.clear();
    this.clear();
  }

  /** Returns the type of [assetName]. */
  String type(String assetName) {
    Asset asset = _assets[assetName];
    if (asset != null) {
      return asset.type;
    }
    return null;
  }

  /** Returns the url of [assetName]. */
  String url(String assetName) {
    Asset asset = _assets[assetName];
    if (asset != null) {
      return asset.url;
    }
    return null;
  }
}

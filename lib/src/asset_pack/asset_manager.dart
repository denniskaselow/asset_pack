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

final PropertyMapConfig _propertyMapConfig = new PropertyMapConfig();

class AssetManager {
  /** A map from asset type to importers. Add your own importers. */
  final Map<String, AssetImporter> importers = new Map<String, AssetImporter>();
  /** A map from asset type to loader. Add your own loaders. */
  final Map<String, AssetLoader> loaders = new Map<String, AssetLoader>();

  AssetManager() {
    _propertyMapConfig.allowNonSerializables = true;
    _propertyMapConfig.autoConvertLists = false;
    _propertyMapConfig.autoConvertMaps = false;
    _root = new AssetPack(this, 'root');
    importers['json'] = new JsonImporter();
    importers['text'] = new TextImporter();
    importers['pack'] = new PackImporter(this);
    loaders['json'] = new TextLoader();
    loaders['text'] = loaders['json'];
    loaders['pack'] = loaders['json'];
  }

  AssetPack _root;
  /// The root pack.
  AssetPack get root => _root;

  /// Forwarded to root.
  dynamic getAssetAtPath(String assetPath) => root.getAssetAtPath(assetPath);

  /// Forwarded to root. See [AssetPack] for method documentation.
  Asset registerAssetAtPath(String assetPath, String type, dynamic imported) {
    return root.registerAssetAtPath(assetPath, type, imported);
  }

  /// Forwarded to root. See [AssetPack] for method documentation.
  void deregisterAssetAtPath(String assetPath) {
    root.deregisterAssetAtPath(assetPath);
  }

  /// Forwarded to root. See [AssetPack] for method documentation.
  AssetPack registerPack(String assetPackName) {
    return _root.registerAssetPack(assetPackName);
  }

  /// Forwared to root. See [AssetPack] for method documentation.
  void deregisterPack(String name) {
    return _root.deregisterPack(name);
  }

  /// Forwarded to root. See [AssetPack] for method documentation.
  Future<AssetPack> loadPack(String name, String url) {
    return _root.loadPack(name, url);
  }

  /// Forwarded to root. See [AssetPack] for method documentation.
  Future loadPacks(List<List<String>> packs) {
    return _root.loadPacks(packs);
  }

  Future _loadAndImport(AssetRequest request) {
    AssetImporter importer = importers[request.type];
    if (importer == null) {
      throw new ArgumentError('Cannot find importer for ${request.type}.');
    }
    AssetLoader loader = loaders[request.type];
    if (loader == null) {
      throw new ArgumentError('Cannot find loader for ${request.type}.');
    }
    request.trace.assetLoadStart(request);
    return loader.load(request).then((payload) {
      request.trace.assetLoadEnd(request);
      request.trace.assetImportStart(request);
      return importer.import(payload, request);
    }).then((v) {
      if (v == null) {
        request.trace.assetEvent(request, 'ERROR_NullImport');
      }
      request.trace.assetImportEnd(request);
      return new Future.immediate(v);
    });
  }
}
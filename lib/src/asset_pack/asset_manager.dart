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
    importers['json'] = new AssetImporterJson();
    importers['text'] = new AssetImporterText();
    importers['pack'] = new AssetImporterPack(this);
    loaders['json'] = new AssetLoaderText();
    loaders['text'] = loaders['json'];
    loaders['pack'] = loaders['json'];
  }

  AssetPack _root;
  AssetPack get root => _root;

  /// Get imported asset at [assetPath].
  dynamic getAssetAtPath(String assetPath) => root.getAssetAtPath(assetPath);

  /// Registers a new asset at path. Will automatically create asset packs.
  Asset registerAssetAtPath(String assetPath, String type, dynamic imported) {
    return root.registerAssetAtPath(assetPath, type, imported);
  }

  /// Deregisters assetPath.
  void deregisterAssetAtPath(String assetPath) {
    root.deregisterAssetAtPath(assetPath);
  }

  /// Register a new asset pack.
  AssetPack registerAssetPack(String assetPackName) {
    return _root.registerAssetPack(assetPackName);
  }

  Future<AssetPack> loadPack(String name, String url) {
    return _root.loadPack(name, url);
  }

  Future loadPacks(List<List<String>> packs) {
    return _root.loadPacks(packs);
  }

  void unloadPack(String name) {
    _root.unloadPack(name);
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
    return loader.load(request).then((payload) {
      return importer.import(payload, request);
    });
  }
}
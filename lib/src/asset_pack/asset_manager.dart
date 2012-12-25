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

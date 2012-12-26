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

class Asset {
  final AssetPack pack;
  /** The name of the asset. */
  final String name;
  /** The url the asset was loaded from. */
  final String url;
  /** The type of the asset. */
  final String type;
  /** The loader for the asset */
  final AssetLoader loader;
  /** The importer for the asset */
  final AssetImporter importer;

  String _status = 'Unloaded';
  String get status => _status;
  bool get _isLoaded => status == 'OK';

  dynamic _loaded;
  dynamic _imported;

  /** The imported asset */
  dynamic get imported {
    if (_imported != null)
      return _imported;
    return importer.fallback;
  }

  Asset(this.pack, this.name, this.url, this.type, this.loader, this.importer);

  Future<Asset> _loadAsset(Map loadArguments) {
    Completer<Asset> completer = new Completer<Asset>();
    Future<dynamic> loadedFuture = loader.load(name, url, type, loadArguments);
    loadedFuture.then((loaded) {
      _loaded = loaded;
      completer.complete(this);
    });
    return completer.future;
  }

  Future<Asset> _importAsset(dynamic payload, Map importArguments) {
    Completer<Asset> completer = new Completer<Asset>();
    Future<dynamic> importedFuture = importer.import(payload, name, url, type,
                                                     importArguments);
    importedFuture.then((imported) {
      _imported = imported;
      completer.complete(this);
    });
    return completer.future;
  }

  Future<Asset> _loadAndImport(Map loadArguments, Map importArguments) {
    return _loadAsset(loadArguments).chain((asset) {
      return _importAsset(asset._loaded, importArguments);
    });
  }

  void _delete() {
    importer.delete(_imported);
    loader.delete(_loaded);
  }
}

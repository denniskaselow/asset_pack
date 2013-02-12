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

class PackImporter extends AssetImporter {
  final AssetManager manager;
  PackImporter(this.manager);

  dynamic get fallback => null;

  Future<dynamic> import(dynamic payload, AssetRequest assetRequest) {
    if (payload == null) {
      return new Future.immediate(fallback);
    }
    String url = assetRequest.baseURL;
    String baseURL = url.substring(0, url.lastIndexOf('.'));
    var parsed;
    if (payload is String) {
      try {
        parsed = JSON.parse(payload);
      } catch (_) {
        return new Future.immediate(fallback);
      }
    }
    AssetPackFile packFile = new AssetPackFile.fromJson(parsed);
    AssetPack pack = new AssetPack(manager, assetRequest.name);
    List<Future<Asset>> futureAssets = new List<Future<Asset>>();
    packFile.assets.forEach((_, packFileAsset) {
      String assetURL = packFileAsset.url;
      String name = packFileAsset.name;
      String type = packFileAsset.type;
      if (type == 'fill_me_in' || type == '') {
        print('Ignoring asset $name');
        return;
      }
      AssetRequest request = new AssetRequest(name, baseURL, assetURL, type,
          packFileAsset.loadArguments,
          packFileAsset.importArguments);
      var futureAsset = manager._loadAndImport(request).then((imported) {
        Asset asset = new Asset(pack, request.name, request.assetURL,
                                request.type,
                                manager.loaders[request.type],
                                manager.importers[request.type]);
        asset._imported = imported;
        pack.assets[asset.name]= asset;
        pack[asset.name] = asset.imported;
      });
      futureAssets.add(futureAsset);
    });
    return Future.wait(futureAssets).then((loaded) {
      // TODO(johnmccutchan): Be honest and check.
      pack._loadedSuccessfully = true;
      return pack;
    });
  }

  void delete(dynamic imported) {
    if (imported == null) {
      return;
    }
    AssetPack pack = imported;
    try {
      if (pack.parent != null) {
        pack.parent.deregisterPack(pack.name);
      }
    } catch(_) {}
  }
}
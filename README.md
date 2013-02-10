# asset_pack #
==============

## Introduction ##

An asset management library for Dart games. Assets packs are sets of assets
which are loaded and unloaded atomically. Assets are any resource from
simple text strings to complex skinned characters. Libraries extend asset_pack
by adding new loaders and importers for application specific types. Accessing
loaded resources is as simple as accessing an object property.

## Key Concepts ##

* `AssetPack` A set of assets which are loaded and unloaded atomically. May
reference other asset packs.
* `Asset` A resource which has been loaded and importer.
* `AssetManager` The root of the asset tree.
* `AssetLoader` A class which loads data from a URL. 
* `AssetImporter` A class which imports data loaded from an `AssetLoader`.

## How are assets loaded? ##

The only way to load assets is to load an asset pack. When an asset pack is
loaded all the referenced assets are loaded. Asset loading is a two stage
process:

1\. An `AssetLoader` fetches the resource at the asset URL.
2\. An `AssetImporter` processes the data so that it is ready to be used immediately. 

## I want to add support for a new resource type, what do I do? ##

You most likely do not need to write a loader. There are already loaders which
can fetch array buffers, blobs, images, and text from the network. You will
have to write a custom importer. See `AssetImporter` for reference.

## Features ##

* Friendly developer tools for building, editing, and listing `.pack` files.
* Powerful runtime asset importing.
* API for adding assets programatically.
* Integration with third party libraries including `spectre`, `simple_audio`, and `javelin`.

## Why asset_pack ? ##

1\. Friendly developer tools.  
2\. 

## Getting Started ##

1\. Add the following to your project's **pubspec.yaml** and run ```pub install```.

```yaml
dependencies:
  asset_pack:
    git: https://github.com/johnmccutchan/asset_pack.git
```

2\. Add the correct import for your project. 

```dart
import 'package:asset_pack/asset_pack.dart';
```

# Documentation #

## API ##

[Reference Manual](http://www.dartgamedevs.org/packages/assetpack/asset_pack.thml)

## Samples ##

1\. unit.html

## Examples ##

1\. Initialize an AssetManager:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManager();
}
```

2\. Load a pack:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManager();
  // Load 'explosions' from 'explosions.pack'.
  AssetPack explosions = assets.load('explosions', 'domain/explosions.pack');
}
```

3\. Iterate over assets in an AssetPack:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManager();
  // Load 'explosions' from 'explosions.pack'.
  AssetPack explosions = assets.load('explosions', 'domain/explosions.pack');
  explosions.forEach((asset) {
    print('${asset.name} as ${asset.type} from ${asset.url} [loaded: ${asset.isLoaded} status: ${asset.status}]');
  });
}
```


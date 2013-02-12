# asset_pack #
==============

## Introduction ##

An asset management library for Dart games. Assets are organized into a tree
of asset packs. Assets can be any resource from a simple text string to a
complex skinned character. 

Typically an asset pack file is loaded from the network, parsed, and all child
assets are loaded from the network and imported. An asset pack file is a JSON
text file describing the child assets. Asset packs and assets can also be
programmaticaly added. 

`asset_pack` is designed to be extended by third party libraries which provide
their own loaders and importers. 

## Overview ##

Each asset manager has a tree of asset packs. Each asset pack contains
assets and other asset packs. Every asset has a logical asset path, which
is a `.` separated list of strings. Example asset paths follow:

1. animals.cats.pic
2. animals.kinds
3. animals.dogs.pic

## Why asset_pack ? ##

The `asset_pack` library makes runtime loading of game assets a breeze. Also,
the library has friendly developer tools for creating pack files and
deep integration with other game libraries for Dart.

## Features ##

* Powerful runtime asset importing.
* Friendly developer tools for building, editing, and listing `.pack` files.
* API for adding assets programatically.
* Integration with third party libraries including `spectre` and `simple_audio`.

## How are assets accessed ? ##

Imported assets are accessed via a property tree. The root of the tree is
accessed via the `root` property on an `AssetManager`. Example: 

`ImageElement image = assetManager.root.animals.cats.picture;`

Each imported asset also has an associated `Asset` instance. An `Asset` holds
metadata associated with the imported asset. It can be accessed via the
`assets` map of the `AssetPack`. Example:

`Asset asset = assetManager.root.animals.cats.assets["picture"]`;

## How are assets loaded? ##

Assets are loaded by loading an asset pack. Each asset listed in an asset pack
is loaded via an `AssetLoader` and then imported by an `AssetImporter`.

## Which loaders and importers come out of the box? ##

Loaders:
1. ArrayBufferLoader
2. BlobLoader
3. ImageLoader
4. TextLoader

Importers:
1. JsonImporter
2. PackImporter
3. TextImporter

## I want to add an importer for a new asset type, what do I do? ##

Implement an `AssetImporter` and add it to the the `importers` map of the
`AssetManager`.

## I want to add a loader for a new asset type, what do I do? ##

Implement an `AssetLoader` and add it to the the `loaders` map of the
`AssetManager`.

*NOTE:* In many cases it's unnecessary to write a new loader. 

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

## Key Classes ##

* `AssetPack` A set of assets which are loaded and unloaded atomically. May
reference other asset packs.
* `Asset` The metadata for an asset which has been loaded and imported.
* `AssetManager` Holds the root of the asset tree.
* `AssetLoader` A class which loads data from a URL. 
* `AssetImporter` A class which imports data loaded from an `AssetLoader`.

## API ##

[Reference Manual](http://www.dartgamedevs.org/packages/assetpack/asset_pack.thml)

## Samples ##

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

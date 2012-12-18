# asset_pack #
==============

## Introduction ##

An Asset Management Library for Dart Games.

## Features ##

* A
* B

## Why asset_pack ? ##

1\. 
2\. 

## Getting Started ##

1\. Add the following to your project's **pubspec.yaml** and run ```pub install```.

```yaml
dependencies:
  asset_pack:
    git: https://github.com/johnmccutchan/assetpack.git
```

2\. Add the correct import for your project. 

```dart
import 'package:assetpack/assetpack.dart';
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
  AssetPack explosions = assets.load('localhost/explosions.pack', 'explosions');
}
```

3\. Iterate over assets in an AssetPack:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManager();
  // Load 'explosions' from 'explosions.pack'.
  AssetPack explosions = assets.load('localhost/explosions.pack', 'explosions');
  explosions.forEach((asset) {
    print('${asset.name} as ${asset.type} from ${asset.url} [loaded: ${asset.isLoaded} status: ${asset.status}]');
  });
}
```


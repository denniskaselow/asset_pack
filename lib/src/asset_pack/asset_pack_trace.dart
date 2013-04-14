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

class AssetPackTraceEvent {
  static const packImportStart = 'PackImportStart';
  static const packImportEnd = 'PackImportEnd';
  static const assetLoadStart = 'AssetLoadStart';
  static const assetLoadEnd = 'AssetLoadEnd';
  static const assetLoadError = 'AssetLoadError';
  static const assetImportStart = 'AssetImportStart';
  static const assetImportEnd = 'AssetImportEnd';
  static const assetImportError = 'AssetImportError';

  final String type;
  final String label;
  final int microseconds;
  AssetPackTraceEvent(this.type, this.label, this.microseconds );

  dynamic toJson() {
    Map json = new Map();
    json['type'] = type;
    json['label'] = label;
    json['timestamp'] = microseconds;
  }

  String toString() {
    return '${microseconds}, ${type}, ${label}';
  }

  /**
   * Convert event into a map (json) in the format loadable by chrome://tracing
   *
   * * see [Using Chrome://tracing to view your inline profiling data](http://www.altdevblogaday.com/2012/08/21/using-chrometracing-to-view-your-inline-profiling-data/)
   * * see [TraceEventFormat](https://code.google.com/p/trace-viewer/wiki/TraceEventFormat)
   */
  dynamic toTraceViewer() {
    Map json = new Map();
    json['ts'] = microseconds;
    if (type == 'AssetImportEnd') {
      json['ph'] = 'E';
      json['name'] = 'import $label';
    } else if (type == assetImportStart) {
      json['ph'] = 'B';
      json['name'] = 'import $label';
    } else if (type == assetLoadStart) {
      json['ph'] = 'B';
      json['name'] = 'load $label';
    } else if (type == assetLoadEnd) {
      json['ph'] = 'E';
      json['name'] = 'load $label';
    } else if (type == 'JsonParseStart') {
      json['ph'] = 'B';
      json['name'] = 'json $label';
    } else if (type == 'JsonParseEnd') {
      json['ph'] = 'E';
      json['name'] = 'json $label';
    } else if (type == packImportEnd) {
      json['ph'] = 'E';
      json['name'] = 'pack $label';
    } else if (type == packImportStart) {
      json['ph'] = 'B';
      json['name'] = 'pack $label';
    } else if (type == assetLoadError || type == assetImportError) {
      json['ph'] = 'I';
      json['name'] = '${type} $label';
    } else {
      throw new ArgumentError('Unknown type $type');
      assert(false);
    }
    json['cat'] = 'asset';
    json['tid'] = 1;
    json['pid'] = 1;
    return json;
  }
}

class AssetPackTraceLabelSummary {
  final String label;
  final List<AssetPackTraceEvent> events = new List<AssetPackTraceEvent>();
  AssetPackTraceLabelSummary(this.label);
  void dump() {
    events.forEach((event) {
      print(event);
    });
  }
}

class AssetPackTraceSummary {
  final Map<String, AssetPackTraceLabelSummary> summaries =
      new Map<String, AssetPackTraceLabelSummary>();

  AssetPackTraceSummary(List<AssetPackTraceEvent> events) {
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      var summary = summaries[event.label];
      if (summary == null) {
        summary = new AssetPackTraceLabelSummary(event.label);
        summaries[event.label] = summary;
      }
      summary.events.add(event);
    }
    summaries.forEach((k, v) {
      v.events.sort((a, b) => a.microseconds.compareTo(b.microseconds));
    });
  }

  void dump() {
    summaries.forEach((k, v) {
      v.dump();
    });
  }
}

class AssetPackTrace {
  final Performance _perf = window.performance;
  final List<AssetPackTraceEvent> events = new List<AssetPackTraceEvent>();

  int _now() => (_perf.now() * 1000).toInt();

  void packImportStart(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.packImportStart,
        asset.name,
        _now()
    );
    events.add(event);
  }

  void packImportEnd(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.packImportEnd,
        asset.name,
        _now()
    );
    events.add(event);
  }

  void assetLoadStart(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetLoadStart,
        asset.assetUrl,
        _now()
    );
    events.add(event);
  }

  void assetLoadEnd(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetLoadEnd,
        asset.assetUrl,
        _now()
    );
    events.add(event);
  }

  void assetLoadError(Asset asset, String errorLabel) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetLoadError,
        "${asset.assetUrl} >> ${errorLabel}",
        _now()
    );
    events.add(event);
  }

  void assetImportStart(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetImportStart,
        asset.assetUrl,
        _now()
    );
    events.add(event);
  }

  void assetImportEnd(Asset asset) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetImportEnd,
        asset.assetUrl,
        _now()
    );
    events.add(event);
  }

  void assetImportError(Asset asset, String errorLabel) {
    var event = new AssetPackTraceEvent(
        AssetPackTraceEvent.assetImportError,
        "${asset.assetUrl} >> ${errorLabel}",
        _now()
    );
    events.add(event);
  }
  void assetEvent(Asset asset, String type) {
    var event = new AssetPackTraceEvent(type, asset.assetUrl, _now());
    events.add(event);
  }

  dynamic toJson() {
    return events;
  }

  void dump() {
    print('Raw Events:');
    for (int i = 0; i < events.length; i++) {
      print(events[i]);
    }
    print('Summary: ');
    var summary = new AssetPackTraceSummary(events);
    summary.dump();
  }

  String toTraceViewer() {
    var lists = events.map((event) => event.toTraceViewer()).toList();
    return '{"traceEvents":${JSON.stringify(lists)}}';
  }
}

/// An [AssetPackTrace] that doesn't trace anything.
///
/// Used to turn off tracing.
class NullAssetPackTrace extends AssetPackTrace {
  void packImportStart(Asset asset) {}
  void packImportEnd(Asset asset) {}
  void assetLoadStart(Asset asset) {}
  void assetLoadEnd(Asset asset) {}
  void assetLoadError(Asset asset, String errorLabel) {}
  void assetImportStart(Asset asset) {}
  void assetImportEnd(Asset asset) {}
  void assetImportError(Asset asset, String errorLabel) {}
  void assetEvent(Asset asset, String type) {}
}

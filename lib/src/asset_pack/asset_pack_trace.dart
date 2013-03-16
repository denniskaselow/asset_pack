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
  final String type;
  final String label;
  final int microseconds;
  AssetPackTraceEvent(this.type, this.label, Stopwatch sw) :
      microseconds = sw.elapsedMicroseconds;

  dynamic toJson() {
    Map json = new Map();
    json['type'] = type;
    json['label'] = label;
    json['timestamp'] = microseconds;
  }

  String toString() {
    return '${microseconds}, ${type}, ${label}';
  }

  dynamic toTraceViewer() {
    Map json = new Map();
    json['ts'] = microseconds;
    if (type == 'AssetImportEnd') {
      json['ph'] = 'E';
      json['name'] = 'import $label';
    } else if (type == 'AssetImportStart') {
      json['ph'] = 'B';
      json['name'] = 'import $label';
    } else if (type == 'AssetLoadStart') {
      json['ph'] = 'B';
      json['name'] = 'load $label';
    } else if (type == 'AssetLoadEnd') {
      json['ph'] = 'E';
      json['name'] = 'load $label';
    } else if (type == 'JsonParseStart') {
      json['ph'] = 'B';
      json['name'] = 'json $label';
    } else if (type == 'JsonParseEnd') {
      json['ph'] = 'E';
      json['name'] = 'json $label';
    } else if (type == 'PackLoadEnd') {
      json['ph'] = 'E';
      json['name'] = 'pack $label';
    } else if (type == 'PackLoadStart') {
      json['ph'] = 'B';
      json['name'] = 'pack $label';
    } else if (type == 'ERROR_NullImport') {
      json['ph'] = 'I';
      json['name'] = 'NULLImport $label';
    } else {
      throw new ArgumentError('Unknown type $type');
      assert(false);
    }
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
  final Stopwatch time = new Stopwatch();
  final List<AssetPackTraceEvent> events = new List<AssetPackTraceEvent>();

  void packLoadStart(String name) {
    events.clear();
    time.reset();
    time.start();
    var event = new AssetPackTraceEvent('PackLoadStart', name, time);
    events.add(event);
  }

  void packLoadEnd(String name) {
    time.stop();
    var event = new AssetPackTraceEvent('PackLoadEnd', name, time);
    events.add(event);
  }

  void assetLoadStart(Asset asset) {
    var event = new AssetPackTraceEvent('AssetLoadStart', asset.assetUrl,
                                        time);
    events.add(event);
  }

  void assetLoadEnd(Asset asset) {
    var event = new AssetPackTraceEvent('AssetLoadEnd', asset.assetUrl, time);
    events.add(event);
  }

  void assetImportStart(Asset asset) {
    var event = new AssetPackTraceEvent('AssetImportStart', asset.assetUrl,
                                        time);
    events.add(event);
  }

  void assetImportEnd(Asset asset) {
    var event = new AssetPackTraceEvent('AssetImportEnd', asset.assetUrl,
                                        time);
    events.add(event);
  }

  void assetEvent(Asset asset, String type) {
    var event = new AssetPackTraceEvent(type, asset.assetUrl, time);
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
    List<Map> lists = new List<Map>();
    events.forEach((event) {
      var eventMap = event.toTraceViewer();
      eventMap['tid'] = 1;
      eventMap['pid'] = 1;
      lists.add(eventMap);
    });
    return JSON.stringify(lists);
  }
}

/// An [AssetPackTrace] that doesn't trace anything.
///
/// Used to turn off tracing.
class NullAssetPackTrace implements AssetPackTrace {
  final Stopwatch time = new Stopwatch();
  final List<AssetPackTraceEvent> events = new List<AssetPackTraceEvent>();

  void packLoadStart(String name) {}
  void packLoadEnd(String name) {}
  void assetLoadStart(Asset asset) {}
  void assetLoadEnd(Asset asset) {}
  void assetImportStart(Asset asset) {}
  void assetImportEnd(Asset asset) {}
  void assetEvent(Asset asset, String type) {}
  dynamic toJson() { return {}; }
  void dump() {}
  String toTraceViewer() { return ''; }
}

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

class AssetLoaderArrayBuffer extends AssetLoader {

  Future<dynamic> load(String name, String url, String type,
                       Map loadArguments) {
    var completer = new Completer<dynamic>();
    var httpRequest = new HttpRequest();
    httpRequest.responseType = 'arraybuffer';
    httpRequest.on.load.add((event) {
      if (httpRequest.status == 200) {
        completer.complete(httpRequest.response);
      } else {
        completer.complete(null);
      }
    });
    httpRequest.open('GET', url);
    httpRequest.send();
    return completer.future;
  }

  void delete(dynamic arg) {

  }
}

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

part of asset_pack_tests;

class Decoder {
  static void decodeToStringTest() {
    test('Base64Decoder string', () {
      // Example strings taken from Wikipedia (http://en.wikipedia.org/wiki/Base64)
      List<String> encoded = [
        // 'any carnal pleasure.' variations
        'YW55IGNhcm5hbCBwbGVhc3VyZS4=',
        'YW55IGNhcm5hbCBwbGVhc3VyZQ==',
        'YW55IGNhcm5hbCBwbGVhc3Vy',
        'YW55IGNhcm5hbCBwbGVhc3U=',
        'YW55IGNhcm5hbCBwbGVhcw==',
        // 'pleasure.' variations
        'cGxlYXN1cmUu',
        'bGVhc3VyZS4=',
        'ZWFzdXJlLg==',
        'YXN1cmUu',
        'c3VyZS4=',
        // A quote from Thomas Hobbes' Leviathan
        'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4='
      ];

      List<String> expected = [
         // 'any carnal pleasure.' variations
        'any carnal pleasure.',
        'any carnal pleasure',
        'any carnal pleasur',
        'any carnal pleasu',
        'any carnal pleas',
        // 'pleasure.' variations
        'pleasure.',
        'leasure.',
        'easure.',
        'asure.',
        'sure.',
        // A quote from Thomas Hobbes' Leviathan
        'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.'
      ];

      Base64Decoder decoder = new Base64Decoder();
      int testLength = encoded.length;

      for (int i = 0; i < testLength; ++i) {
        ArrayBuffer binary = decoder.decode(encoded[i]);
        Uint8Array charCodes = new Uint8Array.fromBuffer(binary);

        String actual = new String.fromCharCodes(charCodes);
        expect(actual, expected[i]);
      }
    });
  }

  static void runTests() {
    group('decodeToString', () {
      decodeToStringTest();
    });
  }
}

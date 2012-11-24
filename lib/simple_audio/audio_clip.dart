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
part of simple_audio;

/** An [AudioClip] stores sound data. To play an [AudioClip],
 * see [AudioSource], [AudioMusic], and [AudioManager].
 */
class AudioClip {
  final AudioManager _manager;
  String _name;
  String _url;
  String get url => _url;
  AudioBuffer _buffer;
  bool _hasError = false;
  String _errorString = '';
  bool _isReadyToPlay = false;

  AudioClip._internal(this._manager, this._name);

  void _empty() {
    _isReadyToPlay = false;
    _buffer = null;
  }

  Map toJson() {
    // Serialize buffer contents as well.
    return {
      "_url":_url,
      "_name": _name,
    };
  }

  AudioClip fromMap(Map map) {
    _url = map['_url'];
    _name = map['_name'];
    return this;
  }

  /** Does the clip have an error? */
  bool get hasError => _hasError;
  /** Human readable error */
  String get errorString => _errorString;

  void _clearError() {
    _hasError = false;
    _errorString = 'OK';
  }

  void _setError(String error) {
    _hasError = true;
    _errorString = error;
  }

  void _onDecode(AudioBuffer buffer, Completer<bool> completer) {
    if (buffer == null) {
      _empty();
      _setError('Error decoding buffer.');
      completer.complete(false);
      return;
    }
    _clearError();
    _buffer = buffer;
    _isReadyToPlay = true;
    print('ready');
    completer.complete(true);
  }

  void _onRequestSuccess(HttpRequest request, Completer<bool> completer) {
    var response = request.response;
    _manager._context.decodeAudioData(response,
                                      (b) => _onDecode(b, completer),
                                      (b) => _onDecode(b, completer));
  }

  void _onRequestError(HttpRequest request, Completer<bool> completer) {
    _empty();
    _setError('Error fetching data');
    completer.complete(false);
  }

  /** Fetch [url] and decode it into the clip buffer.
   * Returns a [Future<bool>] which completes to true if the clip was
   * succesfully loaded and decoded. Will complete to false if the clip
   * could not be loaded or could not be decoded. On error,
   * check [hasError] and [errorString].
   */
  Future<bool> loadFrom(String url) {
    var request = new HttpRequest();
    var completer = new Completer<bool>();
    _url = url;
    request.responseType = 'arraybuffer';
    request.on.load.add((e) => _onRequestSuccess(request, completer));
    request.on.error.add((e) => _onRequestError(request, completer));
    request.on.abort.add((e) => _onRequestError(request, completer));
    request.open('GET', '${_manager.baseURL}/$url');
    request.send();
    return completer.future;
  }

  /** Make an empty clip buffer with [numberOfSampleFrames] in
   * each [numberOfChannels]. The buffer plays at a rate of [sampleRate].
   * The duration (in seconds) of the buffer is equal to:
   * numberOfSampleFrames / sampleRate
   */
  void makeBuffer(num numberOfSampleFrames, num numberOfChannels, num sampleRate) {
    _buffer = _manager._context.createBuffer(numberOfChannels,
                                             numberOfChannels,
                                             sampleRate);
  }

  /** Return the sample frames array for [channel]. Assuming a stereo setup,
   * the left and right speakers are mapped to channel 0 and 1 respectively. */
  Float32Array getSampleFramesForChannel(num channel) {
    if (_buffer == null) {
      return null;
    }
    return _buffer.getChannelData(channel);
  }

  /** Number of clip channels. */
  num get numberOfChannels {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.numberOfChannels;
  }

  /** Length of clip in seconds. */
  num get length {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.duration;
  }

  /** Length of clip in samples. */
  num get samples {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.length;
  }

  /** Samples per second. */
  num get frequency {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.sampleRate;
  }

  /** Is the clip ready to be played? */
  bool get isReadyToPlay => _isReadyToPlay;
}

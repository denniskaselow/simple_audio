import 'dart:html';
import 'package:audio/simple_audio.dart';

AudioManager audioManager = new AudioManager();
AudioSound loopingSound = null;
String sourceName = 'Page';

String baseURL = 'http://127.0.0.1:3030/Users/johnmccutchan/workspace/simpleaudio/clips';
String clipName = 'Wilhelm';
String clipURL = '$baseURL/wilhelm.ogg';
String musicClipName = 'Deeper';
String musicClipURL = '$baseURL/deeper.ogg';

void main() {
  audioManager.makeClip(clipName);
  audioManager.makeClip(musicClipName);
  audioManager.findClip(clipName).loadFrom(clipURL);
  audioManager.findClip(musicClipName).loadFrom(musicClipURL);
  audioManager.makeSource(sourceName);

  query("#clip_once")
    ..on.click.add(playOnce);
  query("#clip_once_delay")
  ..on.click.add(playOnceDelay);
  query("#clip_loop_start")
    ..on.click.add(startLoop);
  query("#clip_loop_stop")
    ..on.click.add(stopLoop);
  query("#pause_sources")
    ..on.click.add(pauseLoop);
  query("#pause_all")
    ..on.click.add(pauseAll);

  query("#music_play")
    ..on.click.add(startMusic);
  query("#music_stop")
    ..on.click.add(stopMusic);
  query("#pause_music")
    ..on.click.add(pauseMusic);

  {
    InputElement ie;
    ie = query("#masterVolume");
    ie.on.change.add((e) => adjustVolume("master", ie));
  }
  {
    InputElement ie;
    ie = query("#musicVolume");
    ie.on.change.add((e) => adjustVolume("music", ie));
  }
  {
    InputElement ie;
    ie = query("#sourceVolume");
    ie.on.change.add((e) => adjustVolume("source", ie));
  }
  query("#mute")
    ..on.click.add(muteEverything);
}

void playOnce(Event event) {
  audioManager.playClipFromSourceIn(0.0, sourceName, clipName);
}

void playOnceDelay(Event event) {
  audioManager.playClipFromSourceIn(2.0, sourceName, clipName);
}

void startLoop(Event event) {
  if (loopingSound != null) {
    loopingSound.stop();
  }
  loopingSound = audioManager.playClipFromSource(sourceName, clipName, true);
}

void stopLoop(Event event) {
  loopingSound.stop();
}

void pauseLoop(Event event) {
  audioManager.findSource(sourceName).pause = !audioManager.findSource(sourceName).pause;
}

void startMusic(Event event) {
  audioManager.music.play(audioManager.findClip(musicClipName));
}

bool _allPaused = false;
void pauseAll(Event event) {
  if (_allPaused) {
    audioManager.resumeAll();
    _allPaused = false;
  } else {
    audioManager.pauseAll();
    _allPaused = true;
  }
}

void stopMusic(Event event) {
  audioManager.music.stop();
}

void pauseMusic(Event event) {
  audioManager.music.pause = !audioManager.music.pause;
}

void adjustVolume(String volume, InputElement el) {
  num val = el.valueAsNumber;
  if (volume == "master") {
    audioManager.masterVolume = val;
  } else if (volume == "music") {
    audioManager.musicVolume = val;
  } else if (volume == "source") {
    audioManager.sourceVolume = val;
  }
  print('$volume -> $val');
}

void muteEverything(Event event) {
  audioManager.mute = !audioManager.mute;
}
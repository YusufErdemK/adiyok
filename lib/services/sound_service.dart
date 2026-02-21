import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static Future<void> _play(String fileName) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print('Ses hatası: $e');
    }
  }

  static Future<void> playSuccess() => _play('success.mp3');
  static Future<void> playDelete() => _play('delete.mp3');
  static Future<void> playClick() => _play('click.mp3');
}
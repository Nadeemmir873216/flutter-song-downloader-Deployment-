import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/io.dart';


// Storage permission
import 'package:permission_handler/permission_handler.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SongDownloader(),
    );
  }
}

class SongDownloader extends StatefulWidget {
  const SongDownloader({super.key});

  @override
  _SongDownloaderState createState() => _SongDownloaderState();
}

class _SongDownloaderState extends State<SongDownloader> {
  final TextEditingController _controller = TextEditingController();
  String? _audioUrl;
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Function to call the Flask API and download the song
  Future<void> _downloadSong() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      // Uri.parse('http://10.0.2.2:5000/download'),  // Update with the actual Flask server IP
      Uri.parse('https://flutter-song-downloader-deployment.onrender.com/download'),  //for actual device
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'song_name': _controller.text}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _audioUrl = data['audio_file'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error: ${response.body}');
    }
  }

  // Function to play the downloaded song from assets

  // Future<void> _playAudio() async {
  //   try {
  //     // Replace the HTTP call with loading audio from the assets
  //     await _audioPlayer.play(AssetSource('audio/temp_audio.mp3'));
  //   } catch (e) {
  //     print('Error playing audio: $e');
  //   }
  // }




  // void _playAudio() {
  //   if (_audioUrl != null) {
  //     _audioPlayer.play(_audioUrl! as Source);
  //   }
  // }

  Future<void> requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //play song function
  // final String _songUrl = 'http://10.0.2.2:5000/audio'; 192.168.1.16:5000//for emulator
// final link :: https://flutter-song-downloader-deployment.onrender.com
  final String _songUrl = 'https://flutter-song-downloader-deployment.onrender.com/audio'; //for actual device


  Future<void> _songPlay() async{
    try{
      final response = await http.get(Uri.parse(_songUrl));
      if(response.statusCode == 200)
        {
          _audioPlayer.play(BytesSource(response.bodyBytes));
        }
      else {
        print("error playing : ${response.statusCode}" );
      }
    }catch (e){
      print("error playing : $e ");
    }
  }

  Future<void> _downloadSongInExternal() async{

    requestPermission();

    var directory = Directory('/storage/emulated/0/Download/SongsDownloader');
    String songName = _controller.text;
    String savePath = '${directory.path}/$songName.mp3';

    Dio dio = Dio();
    try {
      await dio.download('https://flutter-song-downloader-deployment.onrender.com/audio', savePath);
      print('Download complete: $savePath');
    } catch(e)
    {
      print('Error : $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Song Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _downloadSong,
              child: const Text('Load Song'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _downloadSongInExternal,
              child: const Text('Download Song'),
            ),
            const SizedBox(height: 16),
            _audioUrl != null
                ? ElevatedButton(
              onPressed: _songPlay,
              child: const Text('Play Audio'),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
from flask import Flask, request, jsonify , send_file
import os
import yt_dlp

app = Flask(__name__)

def download_audio(song_name):
    download_folder = 'assets/audio'
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)

    ydl_opts = {
        'format': 'bestaudio/best',
        'postprocessors': [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3', 'preferredquality': '192'}],
        'outtmpl': os.path.join(download_folder, 'temp_audio.%(ext)s')
    }
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([f"ytsearch:{song_name}"])

    return os.path.join(download_folder, 'temp_audio.mp3')

@app.route('/download', methods=['POST','GET'])
def download_song():
    song_name = request.json.get('song_name')
    if song_name:
        audio_path = download_audio(song_name)
        # Returning the path of the downloaded file or a success message
        return jsonify({'message': 'Download complete', 'audio_file': audio_path})
    return jsonify({'error': 'Song name is required'}), 400

@app.route('/audio', methods=['POST', 'GET'])
def audio():
    audio_file = 'assets/audio/temp_audio.mp3'
    return send_file(audio_file, mimetype='audio/mpeg')

# if __name__ == '__main__':
#     app.run(host="0.0.0.0", debug=False , port='5000')

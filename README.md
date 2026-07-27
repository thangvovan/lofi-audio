# Lofi Radio - Flutter Music Player

Lofi Radio is a modern, aesthetic Flutter music player for Lofi radio streaming. It features playlists of streaming radio from the official Lofi Girl Youtube Channel with a beautiful dark theme and a smooth audio player.

## Features

- **Music Streaming**: Stream high-quality music directly from the official Lofi Girl Youtube Channel.
- **Audio Playback**: Seamless audio player with handful of essential controls.
- **Persistent Player**: The player continues to play music even when navigating through the app.
- **Sleek UI**: Modern, dark-themed interface with smooth animations and glassmorphism effects.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Youtube Streaming Extraction**: youtube_explode_dart

## Project Structure

```
lib/
├── main.dart          # App entry point
├── screens/           # Main UI screens
│   ├── home_screen.dart
│   └── player_screen.dart
├── theme/             # Theme for the app
├── providers/         # Riverpod providers
├── models/            # Data models
└── services/          # Services for music streaming and audio playback
    ├── youtube_service.dart
    └── audio_service.dart
```
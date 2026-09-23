import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Online gym music — no key, no backend, no cost.
///
/// Primary: **Audius** (free tier, full-length MP3 streams).
///   GET https://discoveryprovider.audius.co/v1/tracks/search?query=..&app_name=..
///   GET https://discoveryprovider.audius.co/v1/tracks/trending?genre=..&app_name=..
///   Stream: /v1/tracks/{id}/stream?app_name=.. (302 → MP3, Range-capable)
/// Fallback: **iTunes Search API** (30-sec previews) if Audius is unreachable.
///
/// Future options (need signup/key, not wired): Jamendo (client_id,
/// full CC tracks + radios), Spotify (SDK, login required).
class Track {
  final String id;
  final String title;
  final String artist;
  final String artwork;
  final String stream; // full mp3 or 30s preview
  final Duration duration;
  final String genre;
  final bool isFull;
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artwork,
    required this.stream,
    required this.duration,
    required this.genre,
    this.isFull = true,
  });

  /// Long DJ mixes (common in workout content) vs regular songs.
  bool get isMix => duration.inMinutes >= 20;
}

/// Curated gym moods → search terms. Data-driven; add moods freely.
class Mood {
  final String label;
  final String term;
  const Mood(this.label, this.term);
}

const gymMoods = [
  Mood('Workout', 'workout'),
  Mood('Cardio', 'cardio'),
  Mood('Running', 'running'),
  Mood('Motivation', 'gym motivation'),
  Mood('HIIT', 'hiit'),
  Mood('Cooldown', 'chill stretch'),
];

const _app = 'TOTALFITGYM';
const _host = 'discoveryprovider.audius.co';

Track _audiusTrack(Map<String, dynamic> j) {
  final art = (j['artwork'] as Map?) ?? {};
  final img = (art['1000x1000'] as String?) ??
      (art['480x480'] as String?) ??
      (art['150x150'] as String?) ??
      '';
  final user = (j['user'] as Map?) ?? {};
  final id = '${j['id'] ?? ''}';
  return Track(
    id: id,
    title: '${j['title'] ?? 'Unknown'}',
    artist: '${user['name'] ?? user['handle'] ?? 'Unknown artist'}',
    artwork: img,
    stream:
        'https://$_host/v1/tracks/$id/stream?app_name=$_app',
    duration: Duration(seconds: (j['duration'] as num?)?.toInt() ?? 0),
    genre: '${j['genre'] ?? ''}',
  );
}

Future<List<Track>> _audius(String term) async {
  final uri = Uri.https(_host, '/v1/tracks/search', {
    'query': term,
    'limit': '30',
    'app_name': _app,
  });
  final res =
      await http.get(uri).timeout(const Duration(seconds: 12));
  if (res.statusCode != 200) throw Exception('Audius ${res.statusCode}');
  final data = json.decode(res.body) as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  final tracks = list
      .whereType<Map<String, dynamic>>()
      .where((e) =>
          e['is_stream_gated'] != true &&
          e['is_delete'] != true &&
          '${e['id'] ?? ''}'.isNotEmpty)
      .map(_audiusTrack)
      .toList();
  if (tracks.isEmpty) throw Exception('Audius empty');
  return tracks;
}

Track _itunesTrack(Map<String, dynamic> j) {
  final art = (j['artworkUrl100'] as String? ?? '')
      .replaceAll('100x100bb', '600x600bb');
  return Track(
    id: '${(j['trackId'] as num?)?.toInt() ?? 0}',
    title: '${j['trackName'] ?? 'Unknown'}',
    artist: '${j['artistName'] ?? 'Unknown'}',
    artwork: art,
    stream: '${j['previewUrl'] ?? ''}',
    duration: Duration(
        milliseconds: (j['trackTimeMillis'] as num?)?.toInt() ?? 30000),
    genre: '${j['primaryGenreName'] ?? ''}',
    isFull: false,
  );
}

Future<List<Track>> _itunes(String term) async {
  final uri = Uri.https('itunes.apple.com', '/search', {
    'term': term,
    'media': 'music',
    'entity': 'song',
    'limit': '30',
  });
  final res =
      await http.get(uri).timeout(const Duration(seconds: 12));
  if (res.statusCode != 200) throw Exception('iTunes ${res.statusCode}');
  final data = json.decode(res.body) as Map<String, dynamic>;
  final list = (data['results'] as List?) ?? [];
  return list
      .whereType<Map<String, dynamic>>()
      .where((e) => (e['previewUrl'] as String?)?.isNotEmpty == true)
      .map(_itunesTrack)
      .toList();
}

/// Full songs first, previews as safety net.
Future<List<Track>> fetchTracks(String term) async {
  try {
    return await _audius(term);
  } catch (_) {
    return _itunes(term);
  }
}

// ─────────────────────────────────────────────────────────────
// Collections: playlists + albums (artist collections).
// Audius has no album entities, so Albums = artist + top tracks.
// ─────────────────────────────────────────────────────────────

/// A playable collection: playlist or artist-album.
class MusicCollection {
  final String id;
  final String name;
  final String artist;
  final String artwork;
  final int trackCount;
  final String kind; // playlist | album
  const MusicCollection({
    required this.id,
    required this.name,
    required this.artist,
    required this.artwork,
    required this.trackCount,
    required this.kind,
  });
}

String _art(Map? art) {
  if (art == null) return '';
  return (art['1000x1000'] as String?) ??
      (art['480x480'] as String?) ??
      (art['150x150'] as String?) ??
      '';
}

MusicCollection _playlist(Map<String, dynamic> j) {
  final user = (j['user'] as Map?) ?? {};
  return MusicCollection(
    id: '${j['id'] ?? ''}',
    name: '${j['playlist_name'] ?? 'Untitled'}',
    artist: '${user['name'] ?? user['handle'] ?? ''}',
    artwork: _art(j['artwork'] as Map?),
    trackCount: (j['track_count'] as num?)?.toInt() ?? 0,
    kind: 'playlist',
  );
}

MusicCollection _artistAlbum(Map u, int count) {
  final art = (u['profile_picture'] as Map?) ?? {};
  return MusicCollection(
    id: '${u['id'] ?? ''}',
    name: '${u['name'] ?? 'Unknown artist'}',
    artist: 'Top tracks',
    artwork: _art(art),
    trackCount: count,
    kind: 'album',
  );
}

Future<List<MusicCollection>> fetchPlaylists(String query) async {
  final path = query.trim().isEmpty
      ? '/v1/playlists/trending'
      : '/v1/playlists/search';
  final params = <String, String>{'limit': '25', 'app_name': _app};
  if (query.trim().isNotEmpty) params['query'] = query.trim();
  final uri = Uri.https(_host, path, params);
  final res =
      await http.get(uri).timeout(const Duration(seconds: 12));
  if (res.statusCode != 200) throw Exception('Playlists ${res.statusCode}');
  final data = json.decode(res.body) as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  final out = list
      .whereType<Map<String, dynamic>>()
      .where((e) =>
          e['is_delete'] != true &&
          e['is_private'] != true &&
          '${e['id'] ?? ''}'.isNotEmpty)
      .map(_playlist)
      .toList();
  if (out.isEmpty) throw Exception('No playlists');
  return out;
}

/// Albums = artists + their top tracks (Audius has no album entities).
Future<List<MusicCollection>> fetchAlbums(String query) async {
  if (query.trim().isEmpty) {
    // Dynamic default: artists behind this week's trending tracks.
    final uri = Uri.https(_host, '/v1/tracks/trending',
        {'genre': 'Electronic', 'limit': '30', 'app_name': _app});
    final res =
        await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('Albums ${res.statusCode}');
    final data = json.decode(res.body) as Map<String, dynamic>;
    final seen = <String>{};
    final out = <MusicCollection>[];
    for (final e in (data['data'] as List? ?? [])) {
      if (e is! Map<String, dynamic>) continue;
      final u = (e['user'] as Map?) ?? {};
      final id = '${u['id'] ?? ''}';
      if (id.isEmpty || !seen.add(id)) continue;
      out.add(_artistAlbum(u, 0));
      if (out.length >= 12) break;
    }
    if (out.isEmpty) throw Exception('No artists');
    return out;
  }
  final uri = Uri.https(_host, '/v1/users/search', {
    'query': query.trim(),
    'limit': '25',
    'app_name': _app,
  });
  final res =
      await http.get(uri).timeout(const Duration(seconds: 12));
  if (res.statusCode != 200) throw Exception('Artists ${res.statusCode}');
  final data = json.decode(res.body) as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  final out = list
      .whereType<Map<String, dynamic>>()
      .where((e) => '${e['id'] ?? ''}'.isNotEmpty)
      .map((u) => _artistAlbum(
          u, (u['track_count'] as num?)?.toInt() ?? 0))
      .toList();
  if (out.isEmpty) throw Exception('No artists');
  return out;
}

/// Full playable tracks inside a collection.
Future<List<Track>> fetchCollectionTracks(MusicCollection c) async {
  final Uri uri;
  if (c.kind == 'album') {
    uri = Uri.https(_host, '/v1/users/${c.id}/tracks',
        {'limit': '30', 'sort': 'plays', 'app_name': _app});
  } else {
    uri = Uri.https(_host, '/v1/playlists/${c.id}/tracks',
        {'limit': '50', 'app_name': _app});
  }
  final res =
      await http.get(uri).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) throw Exception('Tracks ${res.statusCode}');
  final data = json.decode(res.body) as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  final out = list
      .whereType<Map<String, dynamic>>()
      .where((e) =>
          e['is_stream_gated'] != true &&
          e['is_delete'] != true &&
          '${e['id'] ?? ''}'.isNotEmpty)
      .map(_audiusTrack)
      .toList();
  if (out.isEmpty) throw Exception('Empty collection');
  return out;
}

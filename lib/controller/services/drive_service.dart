import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:drivenotes/models/notes_model.dart';

class DriveService {
  static const _folderName = 'DriveNotes';
  static const _folderMimeType = 'application/vnd.google-apps.folder';
  static const _textMimeType = 'text/plain';
  void reset() {
    _folderId = null;
  }
  final auth.AccessCredentials? _credentials;
  String? _folderId;
  DriveService(this._credentials);

  Future<drive.DriveApi> get _driveApi async {
    if (_credentials == null) {
      throw Exception('Not authenticated');
    }
    final authenticatedClient = auth.authenticatedClient(
      http.Client(),
      _credentials,
    );
    return drive.DriveApi(authenticatedClient);
  }

  Future<String> get folderId async {
    if (_folderId != null) return _folderId!;
    final api = await _driveApi;
    final fileList = await api.files.list(
      q: "name='$_folderName' and mimeType='$_folderMimeType' and trashed=false",
      spaces: 'drive',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      _folderId = fileList.files!.first.id;
      return _folderId!;
    }
    final folderMetadata =
        drive.File()
          ..name = _folderName
          ..mimeType = _folderMimeType;

    final folder = await api.files.create(folderMetadata);
    _folderId = folder.id!;
    return _folderId!;
  }

  Future<List<Note>> getNotes() async {
    final api = await _driveApi;
    final parentId = await folderId;
    final fileList = await api.files.list(
      q: "'$parentId' in parents and mimeType='$_textMimeType' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id, name, modifiedTime, createdTime)',
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      return [];
    }
    final notes = <Note>[];
    for (final file in fileList.files!) {
      try {
        final media =
            await api.files.get(
                  file.id!,
                  downloadOptions: drive.DownloadOptions.fullMedia,
                )
                as drive.Media;
        final content = await _readMediaContent(media);
        notes.add(
          Note(
            id: file.id!,
            title: file.name ?? 'Untitled',
            content: content,
            createdAt: file.createdTime ?? DateTime.now(),
            updatedAt: file.modifiedTime ?? DateTime.now(),
          ),
        );
      } catch (e) {
        print('Error loading note ${file.id}: $e');
        continue;
      }
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<Note> createNote(String title, String content) async {
    final api = await _driveApi;
    final parentId = await folderId;
    final fileMetadata =
        drive.File()
          ..name = title
          ..mimeType = _textMimeType
          ..parents = [parentId];
    final file = await api.files.create(
      fileMetadata,
      uploadMedia: drive.Media(
        Stream.fromIterable([utf8.encode(content)]),
        content.length,
      ),
    );
    return Note(
      id: file.id!,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<Note> updateNote(String id, String title, String content) async {
    final api = await _driveApi;
    final fileMetadata = drive.File()..name = title;
    await api.files.update(fileMetadata, id);
    await api.files.update(
      drive.File(),
      id,
      uploadMedia: drive.Media(
        Stream.fromIterable([utf8.encode(content)]),
        content.length,
      ),
    );
    final file = await api.files.get(id);
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: (file as drive.File).createdTime ?? DateTime.now(),
      updatedAt: file.modifiedTime ?? DateTime.now(),
    );
  }

  Future<void> deleteNote(String id) async {
    final api = await _driveApi;
    await api.files.delete(id);
  }
  Future<String> _readMediaContent(drive.Media media) async {
    final bytes = <int>[];
    await for (final byte in media.stream) {
      bytes.addAll(byte);
    }
    return utf8.decode(bytes);
  }

  Future<Note> getNoteById(String id) async {
    final api = await _driveApi;
    final file = await api.files.get(id) as drive.File;
    final media =
        await api.files.get(
              id,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final content = await _readMediaContent(media);
    return Note(
      id: id,
      title: file.name ?? 'Untitled',
      content: content,
      createdAt: file.createdTime ?? DateTime.now(),
      updatedAt: file.modifiedTime ?? DateTime.now(),
    );
  }

  Future<bool> checkConnection() async {
    try {
      final api = await _driveApi;
      await api.about.get($fields: 'user');
      return true;
    } catch (e) {
      return false;
    }
  }
}

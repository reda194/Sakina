import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class AppwriteRepository {
  AppwriteRepository._internal() {
    _client
      ..setEndpoint(AppConfig.APPWRITE_ENDPOINT)
      ..setProject(AppConfig.APPWRITE_PROJECT_ID);

    account = Account(_client);
    databases = Databases(_client);
    storage = Storage(_client);
  }

  static final AppwriteRepository _instance = AppwriteRepository._internal();
  factory AppwriteRepository() => _instance;

  static AppwriteRepository get instance => _instance;

  final Client _client = Client();
  late final Account account;
  late final Databases databases;
  late final Storage storage;

  models.Session? _currentSession;
  bool _isInitialized = false;

  Client get client => _client;
  bool get isInitialized => _isInitialized;
  models.Session? get currentSession => _currentSession;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (AppConfig.DEBUG_MODE) {
      _client.setSelfSigned(status: true);
    }

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('AppwriteRepository initialized');
    }
  }

  Future<models.User?> createAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return user;
  }

  Future<models.User?> register({
    required String email,
    required String password,
    String? name,
  }) {
    return createAccount(email: email, password: password, name: name);
  }

  Future<models.Session?> login({
    required String email,
    required String password,
  }) async {
    _currentSession = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return _currentSession;
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
    _currentSession = null;
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } on AppwriteException {
      return null;
    }
  }

  Future<models.Document?> createDocument({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) async {
    final doc = await databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId ?? ID.unique(),
      data: data,
      permissions: permissions,
    );
    return doc;
  }

  Future<models.Document?> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    Map<String, dynamic>? data,
    List<String>? permissions,
  }) async {
    final doc = await databases.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
      permissions: permissions,
    );
    return doc;
  }

  Future<models.Document?> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    List<String>? queries,
  }) async {
    final doc = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      queries: queries,
    );
    return doc;
  }

  Future<models.DocumentList?> listDocuments({
    required String databaseId,
    required String collectionId,
    List<String>? queries,
  }) async {
    final docs = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: queries,
    );
    return docs;
  }

  Future<bool> deleteDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
    return true;
  }

  Future<models.File> uploadFile({
    required String bucketId,
    required String fileId,
    required InputFile file,
    List<String>? permissions,
    Function(UploadProgress)? onProgress,
  }) {
    return storage.createFile(
      bucketId: bucketId,
      fileId: fileId,
      file: file,
      permissions: permissions,
      onProgress: onProgress,
    );
  }

  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    await storage.deleteFile(bucketId: bucketId, fileId: fileId);
  }

  Future<models.FileList> listFiles({
    required String bucketId,
    List<String>? queries,
    String? search,
  }) {
    return storage.listFiles(
      bucketId: bucketId,
      queries: queries,
      search: search,
    );
  }

  String getFilePreview({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
    int? quality,
  }) {
    final params = <String, String>{
      'project': _client.config['project'] ?? '',
      if (width != null) 'width': width.toString(),
      if (height != null) 'height': height.toString(),
      if (quality != null) 'quality': quality.toString(),
    }..removeWhere((_, value) => value.isEmpty);

    final uri = Uri.parse(
      '${_client.endPoint}/storage/buckets/$bucketId/files/$fileId/preview',
    ).replace(queryParameters: params);
    return uri.toString();
  }

  String getFileDownload({
    required String bucketId,
    required String fileId,
  }) {
    final params = <String, String>{
      'project': _client.config['project'] ?? '',
    }..removeWhere((_, value) => value.isEmpty);

    final uri = Uri.parse(
      '${_client.endPoint}/storage/buckets/$bucketId/files/$fileId/download',
    ).replace(queryParameters: params);
    return uri.toString();
  }

  String getFileView({
    required String bucketId,
    required String fileId,
  }) {
    final params = <String, String>{
      'project': _client.config['project'] ?? '',
    }..removeWhere((_, value) => value.isEmpty);

    final uri = Uri.parse(
      '${_client.endPoint}/storage/buckets/$bucketId/files/$fileId/view',
    ).replace(queryParameters: params);
    return uri.toString();
  }
}

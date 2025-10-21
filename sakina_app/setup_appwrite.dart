// ملف إعداد Appwrite تلقائياً
// يمكن تشغيله باستخدام: dart run setup_appwrite.dart

import 'dart:io';
import 'package:appwrite/appwrite.dart';

// إعدادات المشروع
const String projectId = '676a0b8e000a9b6c9279';
const String endpoint = 'https://cloud.appwrite.io/v1';
const String databaseId = 'sakina_db';

// معرفات المجموعات
const String usersCollectionId = 'users';
const String moodEntriesCollectionId = 'mood_entries';
const String meditationSessionsCollectionId = 'meditation_sessions';
const String journalEntriesCollectionId = 'journal_entries';
const String userPreferencesCollectionId = 'user_preferences';

// معرف حاوية التخزين
const String userFilesBucketId = 'user_files';

void main() async {
  print('🚀 بدء إعداد Appwrite...');
  
  try {
    // تهيئة العميل
    final client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setKey('YOUR_API_KEY_HERE'); // يجب إضافة مفتاح API هنا
    
    final databases = Databases(client);
    final storage = Storage(client);
    
    // إنشاء قاعدة البيانات
    await createDatabase(databases);
    
    // إنشاء المجموعات
    await createCollections(databases);
    
    // إنشاء حاوية التخزين
    await createStorageBucket(storage);
    
    print('✅ تم إعداد Appwrite بنجاح!');
    
  } catch (e) {
    print('❌ خطأ في إعداد Appwrite: $e');
    exit(1);
  }
}

// إنشاء قاعدة البيانات
Future<void> createDatabase(Databases databases) async {
  try {
    await databases.create(
      databaseId: databaseId,
      name: 'Sakina Database',
    );
    print('✅ تم إنشاء قاعدة البيانات');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ قاعدة البيانات موجودة بالفعل');
    } else {
      rethrow;
    }
  }
}

// إنشاء المجموعات
Future<void> createCollections(Databases databases) async {
  // إنشاء مجموعة المستخدمين
  await createUsersCollection(databases);
  
  // إنشاء مجموعة مدخلات المزاج
  await createMoodEntriesCollection(databases);
  
  // إنشاء مجموعة جلسات التأمل
  await createMeditationSessionsCollection(databases);
  
  // إنشاء مجموعة مدخلات المفكرة
  await createJournalEntriesCollection(databases);
  
  // إنشاء مجموعة تفضيلات المستخدم
  await createUserPreferencesCollection(databases);
}

// إنشاء مجموعة المستخدمين
Future<void> createUsersCollection(Databases databases) async {
  try {
    // إنشاء المجموعة
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      name: 'Users',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    
    // إضافة الحقول
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'userId',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'name',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'email',
      size: 255,
      required: true,
    );
    
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'age',
      required: false,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'gender',
      size: 50,
      required: false,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'profilePicture',
      size: 500,
      required: false,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'createdAt',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'updatedAt',
      required: true,
    );
    
    // إنشاء الفهارس
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'userId_index',
      type: 'unique',
      attributes: ['userId'],
    );
    
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      key: 'email_index',
      type: 'unique',
      attributes: ['email'],
    );
    
    print('✅ تم إنشاء مجموعة المستخدمين');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ مجموعة المستخدمين موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء مجموعة المستخدمين: $e');
    }
  }
}

// إنشاء مجموعة مدخلات المزاج
Future<void> createMoodEntriesCollection(Databases databases) async {
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      name: 'Mood Entries',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    
    // إضافة الحقول
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'userId',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'mood',
      size: 100,
      required: true,
    );
    
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'intensity',
      required: true,
      min: 1,
      max: 10,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'notes',
      size: 1000,
      required: false,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'date',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'createdAt',
      required: true,
    );
    
    // إنشاء الفهارس
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: moodEntriesCollectionId,
      key: 'userId_date_index',
      type: 'key',
      attributes: ['userId', 'date'],
    );
    
    print('✅ تم إنشاء مجموعة مدخلات المزاج');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ مجموعة مدخلات المزاج موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء مجموعة مدخلات المزاج: $e');
    }
  }
}

// إنشاء مجموعة جلسات التأمل
Future<void> createMeditationSessionsCollection(Databases databases) async {
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      name: 'Meditation Sessions',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    
    // إضافة الحقول
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'userId',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'type',
      size: 100,
      required: true,
    );
    
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'duration',
      required: true,
    );
    
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'completed',
      required: true,
    );
    
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'rating',
      required: false,
      min: 1,
      max: 5,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'date',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: meditationSessionsCollectionId,
      key: 'createdAt',
      required: true,
    );
    
    print('✅ تم إنشاء مجموعة جلسات التأمل');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ مجموعة جلسات التأمل موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء مجموعة جلسات التأمل: $e');
    }
  }
}

// إنشاء مجموعة مدخلات المفكرة
Future<void> createJournalEntriesCollection(Databases databases) async {
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      name: 'Journal Entries',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    
    // إضافة الحقول
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'userId',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'title',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'content',
      size: 5000,
      required: true,
    );
    
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'isPrivate',
      required: true,
      xdefault: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'date',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'createdAt',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: journalEntriesCollectionId,
      key: 'updatedAt',
      required: true,
    );
    
    print('✅ تم إنشاء مجموعة مدخلات المفكرة');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ مجموعة مدخلات المفكرة موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء مجموعة مدخلات المفكرة: $e');
    }
  }
}

// إنشاء مجموعة تفضيلات المستخدم
Future<void> createUserPreferencesCollection(Databases databases) async {
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      name: 'User Preferences',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    
    // إضافة الحقول
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'userId',
      size: 255,
      required: true,
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'theme',
      size: 50,
      required: false,
      xdefault: 'light',
    );
    
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'language',
      size: 10,
      required: false,
      xdefault: 'ar',
    );
    
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'notificationsEnabled',
      required: false,
      xdefault: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'createdAt',
      required: true,
    );
    
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'updatedAt',
      required: true,
    );
    
    // إنشاء فهرس فريد على userId
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: userPreferencesCollectionId,
      key: 'userId_index',
      type: 'unique',
      attributes: ['userId'],
    );
    
    print('✅ تم إنشاء مجموعة تفضيلات المستخدم');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ مجموعة تفضيلات المستخدم موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء مجموعة تفضيلات المستخدم: $e');
    }
  }
}

// إنشاء حاوية التخزين
Future<void> createStorageBucket(Storage storage) async {
  try {
    await storage.createBucket(
      bucketId: userFilesBucketId,
      name: 'User Files',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
      fileSecurity: true,
      enabled: true,
      maximumFileSize: 10485760, // 10MB
      allowedFileExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'mp3', 'mp4'],
      compression: 'gzip',
      encryption: true,
      antivirus: true,
    );
    
    print('✅ تم إنشاء حاوية التخزين');
  } catch (e) {
    if (e.toString().contains('already exists')) {
      print('ℹ️ حاوية التخزين موجودة بالفعل');
    } else {
      print('❌ خطأ في إنشاء حاوية التخزين: $e');
    }
  }
}
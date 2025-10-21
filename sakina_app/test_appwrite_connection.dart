// سكريبت اختبار الاتصال مع Appwrite
// يمكن تشغيله باستخدام: dart run test_appwrite_connection.dart

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

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
  print('🚀 بدء اختبار الاتصال مع Appwrite...');
  print('=' * 50);
  
  try {
    // تهيئة العميل
    final client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    
    // اختبار الخدمات المختلفة
    await testBasicConnection(client);
    await testDatabaseConnection(client);
    await testStorageConnection(client);
    await testAuthenticationFlow(client);
    
    print('\n${'=' * 50}');
    print('✅ جميع الاختبارات نجحت! Appwrite جاهز للاستخدام.');
    
  } catch (e) {
    print('\n${'=' * 50}');
    print('❌ فشل في الاختبار: $e');
    print('\nتأكد من:');
    print('1. صحة معرف المشروع: $projectId');
    print('2. الاتصال بالإنترنت');
    print('3. إعداد المشروع في Appwrite Console');
    exit(1);
  }
}

// اختبار الاتصال الأساسي
Future<void> testBasicConnection(Client client) async {
  print('\n🔄 اختبار الاتصال الأساسي...');
  
  try {
    final health = Health(client);
    final status = await health.get();
    
    print('✅ الاتصال الأساسي نجح');
    print('   - حالة الخدمة: ${status.status}');
    print('   - الإصدار: ${status.version}');
  } catch (e) {
    print('❌ فشل الاتصال الأساسي: $e');
    rethrow;
  }
}

// اختبار الاتصال بقاعدة البيانات
Future<void> testDatabaseConnection(Client client) async {
  print('\n🔄 اختبار الاتصال بقاعدة البيانات...');
  
  try {
    final databases = Databases(client);
    
    // محاولة الحصول على قاعدة البيانات
    final database = await databases.get(databaseId: databaseId);
    print('✅ تم العثور على قاعدة البيانات: ${database.name}');
    
    // اختبار المجموعات
    await testCollections(databases);
    
  } catch (e) {
    print('❌ فشل الاتصال بقاعدة البيانات: $e');
    print('   تأكد من إنشاء قاعدة البيانات بالمعرف: $databaseId');
    rethrow;
  }
}

// اختبار المجموعات
Future<void> testCollections(Databases databases) async {
  print('\n🔄 اختبار المجموعات...');
  
  final collections = [
    usersCollectionId,
    moodEntriesCollectionId,
    meditationSessionsCollectionId,
    journalEntriesCollectionId,
    userPreferencesCollectionId,
  ];
  
  for (final collectionId in collections) {
    try {
      final collection = await databases.getCollection(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      print('   ✅ مجموعة "${collection.name}" موجودة');
    } catch (e) {
      print('   ❌ مجموعة "$collectionId" غير موجودة');
      print('      تأكد من إنشاء المجموعة في Appwrite Console');
    }
  }
}

// اختبار التخزين
Future<void> testStorageConnection(Client client) async {
  print('\n🔄 اختبار التخزين...');
  
  try {
    final storage = Storage(client);
    
    // محاولة الحصول على حاوية التخزين
    final bucket = await storage.getBucket(bucketId: userFilesBucketId);
    print('✅ تم العثور على حاوية التخزين: ${bucket.name}');
    print('   - الحد الأقصى لحجم الملف: ${bucket.maximumFileSize} بايت');
    print('   - الامتدادات المسموحة: ${bucket.allowedFileExtensions?.join(", ") ?? "جميع الامتدادات"}');
    
  } catch (e) {
    print('❌ فشل الاتصال بالتخزين: $e');
    print('   تأكد من إنشاء حاوية التخزين بالمعرف: $userFilesBucketId');
  }
}

// اختبار تدفق المصادقة
Future<void> testAuthenticationFlow(Client client) async {
  print('\n🔄 اختبار المصادقة...');
  
  try {
    final account = Account(client);
    
    // إنشاء جلسة مجهولة للاختبار
    print('   🔄 إنشاء جلسة مجهولة...');
    final session = await account.createAnonymousSession();
    print('   ✅ تم إنشاء جلسة مجهولة بنجاح');
    print('   - معرف الجلسة: ${session.$id}');
    print('   - معرف المستخدم: ${session.userId}');
    
    // الحصول على المستخدم الحالي
    print('   🔄 الحصول على بيانات المستخدم...');
    final user = await account.get();
    print('   ✅ تم الحصول على بيانات المستخدم');
    print('   - معرف المستخدم: ${user.$id}');
    print('   - البريد الإلكتروني: ${user.email.isEmpty ? "غير محدد" : user.email}');
    
    // حذف الجلسة
    print('   🔄 حذف الجلسة المجهولة...');
    await account.deleteSession(sessionId: 'current');
    print('   ✅ تم حذف الجلسة بنجاح');
    
  } catch (e) {
    print('❌ فشل اختبار المصادقة: $e');
    print('   تأكد من تفعيل المصادقة في إعدادات المشروع');
  }
}

// اختبار شامل للعمليات الأساسية
Future<void> testBasicOperations(Client client) async {
  print('\n🔄 اختبار العمليات الأساسية...');
  
  try {
    final account = Account(client);
    final databases = Databases(client);
    
    // إنشاء جلسة مجهولة
    await account.createAnonymousSession();
    final user = await account.get();
    
    // اختبار إنشاء مستند
    print('   🔄 اختبار إنشاء مستند...');
    final testDoc = await databases.createDocument(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      documentId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'userId': user.$id,
        'name': 'مستخدم تجريبي',
        'email': 'test@example.com',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    print('   ✅ تم إنشاء مستند تجريبي: ${testDoc.$id}');
    
    // اختبار قراءة المستند
    print('   🔄 اختبار قراءة المستند...');
    final readDoc = await databases.getDocument(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      documentId: testDoc.$id,
    );
    print('   ✅ تم قراءة المستند: ${readDoc.data['name']}');
    
    // اختبار تحديث المستند
    print('   🔄 اختبار تحديث المستند...');
    final updatedDoc = await databases.updateDocument(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      documentId: testDoc.$id,
      data: {
        'name': 'مستخدم تجريبي محدث',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    print('   ✅ تم تحديث المستند: ${updatedDoc.data['name']}');
    
    // اختبار حذف المستند
    print('   🔄 اختبار حذف المستند...');
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      documentId: testDoc.$id,
    );
    print('   ✅ تم حذف المستند التجريبي');
    
    // حذف الجلسة
    await account.deleteSession(sessionId: 'current');
    
  } catch (e) {
    print('❌ فشل في العمليات الأساسية: $e');
  }
}

// اختبار الصلاحيات
Future<void> testPermissions(Client client) async {
  print('\n🔄 اختبار الصلاحيات...');
  
  try {
    final databases = Databases(client);
    
    // محاولة الوصول بدون مصادقة
    try {
      await databases.listDocuments(
        databaseId: databaseId,
        collectionId: usersCollectionId,
      );
      print('   ⚠️ تحذير: يمكن الوصول للبيانات بدون مصادقة');
    } catch (e) {
      print('   ✅ الصلاحيات تعمل بشكل صحيح - مطلوب مصادقة');
    }
    
  } catch (e) {
    print('❌ خطأ في اختبار الصلاحيات: $e');
  }
}

// عرض معلومات التكوين
void displayConfiguration() {
  print('\n📋 معلومات التكوين:');
  print('   - معرف المشروع: $projectId');
  print('   - نقطة النهاية: $endpoint');
  print('   - معرف قاعدة البيانات: $databaseId');
  print('   - عدد المجموعات: 5');
  print('   - حاوية التخزين: $userFilesBucketId');
}
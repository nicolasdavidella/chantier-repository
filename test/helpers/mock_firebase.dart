import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference<T extends Object?> extends Mock implements CollectionReference<T> {}
class MockDocumentReference<T extends Object?> extends Mock implements DocumentReference<T> {}
class MockDocumentSnapshot<T extends Object?> extends Mock implements DocumentSnapshot<T> {}
class MockQuerySnapshot<T extends Object?> extends Mock implements QuerySnapshot<T> {}
class MockQueryDocumentSnapshot<T extends Object?> extends Mock implements QueryDocumentSnapshot<T> {}
class MockQuery<T extends Object?> extends Mock implements Query<T> {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void setupFirebaseAuthMocks() {
  registerFallbackValue(MockUser());
  registerFallbackValue(MockUserCredential());
}

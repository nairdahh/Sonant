// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UserEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastLoginAtMeta =
      const VerificationMeta('lastLoginAt');
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
      'last_login_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _firebaseUidMeta =
      const VerificationMeta('firebaseUid');
  @override
  late final GeneratedColumn<String> firebaseUid = GeneratedColumn<String>(
      'firebase_uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        displayName,
        createdAt,
        lastLoginAt,
        firebaseUid,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
          _lastLoginAtMeta,
          lastLoginAt.isAcceptableOrUnknown(
              data['last_login_at']!, _lastLoginAtMeta));
    }
    if (data.containsKey('firebase_uid')) {
      context.handle(
          _firebaseUidMeta,
          firebaseUid.isAcceptableOrUnknown(
              data['firebase_uid']!, _firebaseUidMeta));
    } else if (isInserting) {
      context.missing(_firebaseUidMeta);
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastLoginAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login_at']),
      firebaseUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firebase_uid'])!,
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UserEntry extends DataClass implements Insertable<UserEntry> {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String firebaseUid;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const UserEntry(
      {required this.id,
      required this.email,
      this.displayName,
      required this.createdAt,
      this.lastLoginAt,
      required this.firebaseUid,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['firebase_uid'] = Variable<String>(firebaseUid);
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      createdAt: Value(createdAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      firebaseUid: Value(firebaseUid),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntry(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      firebaseUid: serializer.fromJson<String>(json['firebaseUid']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'firebaseUid': serializer.toJson<String>(firebaseUid),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  UserEntry copyWith(
          {String? id,
          String? email,
          Value<String?> displayName = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastLoginAt = const Value.absent(),
          String? firebaseUid,
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      UserEntry(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName.present ? displayName.value : this.displayName,
        createdAt: createdAt ?? this.createdAt,
        lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
        firebaseUid: firebaseUid ?? this.firebaseUid,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  UserEntry copyWithCompanion(UsersTableCompanion data) {
    return UserEntry(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLoginAt:
          data.lastLoginAt.present ? data.lastLoginAt.value : this.lastLoginAt,
      firebaseUid:
          data.firebaseUid.present ? data.firebaseUid.value : this.firebaseUid,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntry(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, createdAt,
      lastLoginAt, firebaseUid, syncedWithFirestore, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntry &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.firebaseUid == this.firebaseUid &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UsersTableCompanion extends UpdateCompanion<UserEntry> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastLoginAt;
  final Value<String> firebaseUid;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.firebaseUid = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    required DateTime createdAt,
    this.lastLoginAt = const Value.absent(),
    required String firebaseUid,
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        createdAt = Value(createdAt),
        firebaseUid = Value(firebaseUid);
  static Insertable<UserEntry> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLoginAt,
    Expression<String>? firebaseUid,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (firebaseUid != null) 'firebase_uid': firebaseUid,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String?>? displayName,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastLoginAt,
      Value<String>? firebaseUid,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return UsersTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (firebaseUid.present) {
      map['firebase_uid'] = Variable<String>(firebaseUid.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedBooksTableTable extends SavedBooksTable
    with TableInfo<$SavedBooksTableTable, SavedBookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedBooksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileUrlMeta =
      const VerificationMeta('fileUrl');
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
      'file_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPageIndexMeta =
      const VerificationMeta('lastPageIndex');
  @override
  late final GeneratedColumn<int> lastPageIndex = GeneratedColumn<int>(
      'last_page_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
      'last_read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _contentHashMeta =
      const VerificationMeta('contentHash');
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
      'content_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        author,
        format,
        coverImageUrl,
        fileUrl,
        lastPageIndex,
        totalPages,
        lastReadAt,
        addedAt,
        contentHash,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_books_table';
  @override
  VerificationContext validateIntegrity(Insertable<SavedBookEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('file_url')) {
      context.handle(_fileUrlMeta,
          fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta));
    }
    if (data.containsKey('last_page_index')) {
      context.handle(
          _lastPageIndexMeta,
          lastPageIndex.isAcceptableOrUnknown(
              data['last_page_index']!, _lastPageIndexMeta));
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
          _contentHashMeta,
          contentHash.isAcceptableOrUnknown(
              data['content_hash']!, _contentHashMeta));
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedBookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedBookEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      fileUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_url']),
      lastPageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_page_index'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_read_at']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      contentHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_hash']),
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SavedBooksTableTable createAlias(String alias) {
    return $SavedBooksTableTable(attachedDatabase, alias);
  }
}

class SavedBookEntry extends DataClass implements Insertable<SavedBookEntry> {
  final String id;
  final String userId;
  final String title;
  final String? author;
  final String format;
  final String? coverImageUrl;
  final String? fileUrl;
  final int lastPageIndex;
  final int totalPages;
  final DateTime? lastReadAt;
  final DateTime addedAt;
  final String? contentHash;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const SavedBookEntry(
      {required this.id,
      required this.userId,
      required this.title,
      this.author,
      required this.format,
      this.coverImageUrl,
      this.fileUrl,
      required this.lastPageIndex,
      required this.totalPages,
      this.lastReadAt,
      required this.addedAt,
      this.contentHash,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    map['last_page_index'] = Variable<int>(lastPageIndex);
    map['total_pages'] = Variable<int>(totalPages);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SavedBooksTableCompanion toCompanion(bool nullToAbsent) {
    return SavedBooksTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      format: Value(format),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      fileUrl: fileUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fileUrl),
      lastPageIndex: Value(lastPageIndex),
      totalPages: Value(totalPages),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      addedAt: Value(addedAt),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SavedBookEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedBookEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      format: serializer.fromJson<String>(json['format']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      lastPageIndex: serializer.fromJson<int>(json['lastPageIndex']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'format': serializer.toJson<String>(format),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'lastPageIndex': serializer.toJson<int>(lastPageIndex),
      'totalPages': serializer.toJson<int>(totalPages),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'contentHash': serializer.toJson<String?>(contentHash),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SavedBookEntry copyWith(
          {String? id,
          String? userId,
          String? title,
          Value<String?> author = const Value.absent(),
          String? format,
          Value<String?> coverImageUrl = const Value.absent(),
          Value<String?> fileUrl = const Value.absent(),
          int? lastPageIndex,
          int? totalPages,
          Value<DateTime?> lastReadAt = const Value.absent(),
          DateTime? addedAt,
          Value<String?> contentHash = const Value.absent(),
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      SavedBookEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        format: format ?? this.format,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
        lastPageIndex: lastPageIndex ?? this.lastPageIndex,
        totalPages: totalPages ?? this.totalPages,
        lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
        addedAt: addedAt ?? this.addedAt,
        contentHash: contentHash.present ? contentHash.value : this.contentHash,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SavedBookEntry copyWithCompanion(SavedBooksTableCompanion data) {
    return SavedBookEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      format: data.format.present ? data.format.value : this.format,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      lastPageIndex: data.lastPageIndex.present
          ? data.lastPageIndex.value
          : this.lastPageIndex,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      contentHash:
          data.contentHash.present ? data.contentHash.value : this.contentHash,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedBookEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('lastPageIndex: $lastPageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('addedAt: $addedAt, ')
          ..write('contentHash: $contentHash, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      title,
      author,
      format,
      coverImageUrl,
      fileUrl,
      lastPageIndex,
      totalPages,
      lastReadAt,
      addedAt,
      contentHash,
      syncedWithFirestore,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedBookEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.author == this.author &&
          other.format == this.format &&
          other.coverImageUrl == this.coverImageUrl &&
          other.fileUrl == this.fileUrl &&
          other.lastPageIndex == this.lastPageIndex &&
          other.totalPages == this.totalPages &&
          other.lastReadAt == this.lastReadAt &&
          other.addedAt == this.addedAt &&
          other.contentHash == this.contentHash &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SavedBooksTableCompanion extends UpdateCompanion<SavedBookEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> format;
  final Value<String?> coverImageUrl;
  final Value<String?> fileUrl;
  final Value<int> lastPageIndex;
  final Value<int> totalPages;
  final Value<DateTime?> lastReadAt;
  final Value<DateTime> addedAt;
  final Value<String?> contentHash;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SavedBooksTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.format = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.lastPageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedBooksTableCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.author = const Value.absent(),
    required String format,
    this.coverImageUrl = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.lastPageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    required DateTime addedAt,
    this.contentHash = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        format = Value(format),
        addedAt = Value(addedAt);
  static Insertable<SavedBookEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? format,
    Expression<String>? coverImageUrl,
    Expression<String>? fileUrl,
    Expression<int>? lastPageIndex,
    Expression<int>? totalPages,
    Expression<DateTime>? lastReadAt,
    Expression<DateTime>? addedAt,
    Expression<String>? contentHash,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (format != null) 'format': format,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (fileUrl != null) 'file_url': fileUrl,
      if (lastPageIndex != null) 'last_page_index': lastPageIndex,
      if (totalPages != null) 'total_pages': totalPages,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (addedAt != null) 'added_at': addedAt,
      if (contentHash != null) 'content_hash': contentHash,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedBooksTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String?>? author,
      Value<String>? format,
      Value<String?>? coverImageUrl,
      Value<String?>? fileUrl,
      Value<int>? lastPageIndex,
      Value<int>? totalPages,
      Value<DateTime?>? lastReadAt,
      Value<DateTime>? addedAt,
      Value<String?>? contentHash,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return SavedBooksTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      totalPages: totalPages ?? this.totalPages,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      addedAt: addedAt ?? this.addedAt,
      contentHash: contentHash ?? this.contentHash,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (lastPageIndex.present) {
      map['last_page_index'] = Variable<int>(lastPageIndex.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedBooksTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('lastPageIndex: $lastPageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('addedAt: $addedAt, ')
          ..write('contentHash: $contentHash, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTableTable extends ReadingProgressTable
    with TableInfo<$ReadingProgressTableTable, ReadingProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _currentPageIndexMeta =
      const VerificationMeta('currentPageIndex');
  @override
  late final GeneratedColumn<int> currentPageIndex = GeneratedColumn<int>(
      'current_page_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAudioPositionMsMeta =
      const VerificationMeta('lastAudioPositionMs');
  @override
  late final GeneratedColumn<int> lastAudioPositionMs = GeneratedColumn<int>(
      'last_audio_position_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastWordIndexMeta =
      const VerificationMeta('lastWordIndex');
  @override
  late final GeneratedColumn<int> lastWordIndex = GeneratedColumn<int>(
      'last_word_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _readingTimeMinutesMeta =
      const VerificationMeta('readingTimeMinutes');
  @override
  late final GeneratedColumn<int> readingTimeMinutes = GeneratedColumn<int>(
      'reading_time_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReadTimestampMeta =
      const VerificationMeta('lastReadTimestamp');
  @override
  late final GeneratedColumn<DateTime> lastReadTimestamp =
      GeneratedColumn<DateTime>('last_read_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        currentPageIndex,
        lastAudioPositionMs,
        lastWordIndex,
        readingTimeMinutes,
        lastReadTimestamp,
        createdAt,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingProgressEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('current_page_index')) {
      context.handle(
          _currentPageIndexMeta,
          currentPageIndex.isAcceptableOrUnknown(
              data['current_page_index']!, _currentPageIndexMeta));
    }
    if (data.containsKey('last_audio_position_ms')) {
      context.handle(
          _lastAudioPositionMsMeta,
          lastAudioPositionMs.isAcceptableOrUnknown(
              data['last_audio_position_ms']!, _lastAudioPositionMsMeta));
    }
    if (data.containsKey('last_word_index')) {
      context.handle(
          _lastWordIndexMeta,
          lastWordIndex.isAcceptableOrUnknown(
              data['last_word_index']!, _lastWordIndexMeta));
    }
    if (data.containsKey('reading_time_minutes')) {
      context.handle(
          _readingTimeMinutesMeta,
          readingTimeMinutes.isAcceptableOrUnknown(
              data['reading_time_minutes']!, _readingTimeMinutesMeta));
    }
    if (data.containsKey('last_read_timestamp')) {
      context.handle(
          _lastReadTimestampMeta,
          lastReadTimestamp.isAcceptableOrUnknown(
              data['last_read_timestamp']!, _lastReadTimestampMeta));
    } else if (isInserting) {
      context.missing(_lastReadTimestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      currentPageIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_page_index'])!,
      lastAudioPositionMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_audio_position_ms'])!,
      lastWordIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_word_index'])!,
      readingTimeMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reading_time_minutes'])!,
      lastReadTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_read_timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ReadingProgressTableTable createAlias(String alias) {
    return $ReadingProgressTableTable(attachedDatabase, alias);
  }
}

class ReadingProgressEntry extends DataClass
    implements Insertable<ReadingProgressEntry> {
  final String id;
  final String bookId;
  final int currentPageIndex;
  final int lastAudioPositionMs;
  final int lastWordIndex;
  final int readingTimeMinutes;
  final DateTime lastReadTimestamp;
  final DateTime createdAt;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const ReadingProgressEntry(
      {required this.id,
      required this.bookId,
      required this.currentPageIndex,
      required this.lastAudioPositionMs,
      required this.lastWordIndex,
      required this.readingTimeMinutes,
      required this.lastReadTimestamp,
      required this.createdAt,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['current_page_index'] = Variable<int>(currentPageIndex);
    map['last_audio_position_ms'] = Variable<int>(lastAudioPositionMs);
    map['last_word_index'] = Variable<int>(lastWordIndex);
    map['reading_time_minutes'] = Variable<int>(readingTimeMinutes);
    map['last_read_timestamp'] = Variable<DateTime>(lastReadTimestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ReadingProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressTableCompanion(
      id: Value(id),
      bookId: Value(bookId),
      currentPageIndex: Value(currentPageIndex),
      lastAudioPositionMs: Value(lastAudioPositionMs),
      lastWordIndex: Value(lastWordIndex),
      readingTimeMinutes: Value(readingTimeMinutes),
      lastReadTimestamp: Value(lastReadTimestamp),
      createdAt: Value(createdAt),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ReadingProgressEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressEntry(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      currentPageIndex: serializer.fromJson<int>(json['currentPageIndex']),
      lastAudioPositionMs:
          serializer.fromJson<int>(json['lastAudioPositionMs']),
      lastWordIndex: serializer.fromJson<int>(json['lastWordIndex']),
      readingTimeMinutes: serializer.fromJson<int>(json['readingTimeMinutes']),
      lastReadTimestamp:
          serializer.fromJson<DateTime>(json['lastReadTimestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'currentPageIndex': serializer.toJson<int>(currentPageIndex),
      'lastAudioPositionMs': serializer.toJson<int>(lastAudioPositionMs),
      'lastWordIndex': serializer.toJson<int>(lastWordIndex),
      'readingTimeMinutes': serializer.toJson<int>(readingTimeMinutes),
      'lastReadTimestamp': serializer.toJson<DateTime>(lastReadTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ReadingProgressEntry copyWith(
          {String? id,
          String? bookId,
          int? currentPageIndex,
          int? lastAudioPositionMs,
          int? lastWordIndex,
          int? readingTimeMinutes,
          DateTime? lastReadTimestamp,
          DateTime? createdAt,
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ReadingProgressEntry(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        currentPageIndex: currentPageIndex ?? this.currentPageIndex,
        lastAudioPositionMs: lastAudioPositionMs ?? this.lastAudioPositionMs,
        lastWordIndex: lastWordIndex ?? this.lastWordIndex,
        readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
        lastReadTimestamp: lastReadTimestamp ?? this.lastReadTimestamp,
        createdAt: createdAt ?? this.createdAt,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ReadingProgressEntry copyWithCompanion(ReadingProgressTableCompanion data) {
    return ReadingProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      currentPageIndex: data.currentPageIndex.present
          ? data.currentPageIndex.value
          : this.currentPageIndex,
      lastAudioPositionMs: data.lastAudioPositionMs.present
          ? data.lastAudioPositionMs.value
          : this.lastAudioPositionMs,
      lastWordIndex: data.lastWordIndex.present
          ? data.lastWordIndex.value
          : this.lastWordIndex,
      readingTimeMinutes: data.readingTimeMinutes.present
          ? data.readingTimeMinutes.value
          : this.readingTimeMinutes,
      lastReadTimestamp: data.lastReadTimestamp.present
          ? data.lastReadTimestamp.value
          : this.lastReadTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('currentPageIndex: $currentPageIndex, ')
          ..write('lastAudioPositionMs: $lastAudioPositionMs, ')
          ..write('lastWordIndex: $lastWordIndex, ')
          ..write('readingTimeMinutes: $readingTimeMinutes, ')
          ..write('lastReadTimestamp: $lastReadTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookId,
      currentPageIndex,
      lastAudioPositionMs,
      lastWordIndex,
      readingTimeMinutes,
      lastReadTimestamp,
      createdAt,
      syncedWithFirestore,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.currentPageIndex == this.currentPageIndex &&
          other.lastAudioPositionMs == this.lastAudioPositionMs &&
          other.lastWordIndex == this.lastWordIndex &&
          other.readingTimeMinutes == this.readingTimeMinutes &&
          other.lastReadTimestamp == this.lastReadTimestamp &&
          other.createdAt == this.createdAt &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ReadingProgressTableCompanion
    extends UpdateCompanion<ReadingProgressEntry> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> currentPageIndex;
  final Value<int> lastAudioPositionMs;
  final Value<int> lastWordIndex;
  final Value<int> readingTimeMinutes;
  final Value<DateTime> lastReadTimestamp;
  final Value<DateTime> createdAt;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ReadingProgressTableCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.currentPageIndex = const Value.absent(),
    this.lastAudioPositionMs = const Value.absent(),
    this.lastWordIndex = const Value.absent(),
    this.readingTimeMinutes = const Value.absent(),
    this.lastReadTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressTableCompanion.insert({
    required String id,
    required String bookId,
    this.currentPageIndex = const Value.absent(),
    this.lastAudioPositionMs = const Value.absent(),
    this.lastWordIndex = const Value.absent(),
    this.readingTimeMinutes = const Value.absent(),
    required DateTime lastReadTimestamp,
    required DateTime createdAt,
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        lastReadTimestamp = Value(lastReadTimestamp),
        createdAt = Value(createdAt);
  static Insertable<ReadingProgressEntry> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? currentPageIndex,
    Expression<int>? lastAudioPositionMs,
    Expression<int>? lastWordIndex,
    Expression<int>? readingTimeMinutes,
    Expression<DateTime>? lastReadTimestamp,
    Expression<DateTime>? createdAt,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (currentPageIndex != null) 'current_page_index': currentPageIndex,
      if (lastAudioPositionMs != null)
        'last_audio_position_ms': lastAudioPositionMs,
      if (lastWordIndex != null) 'last_word_index': lastWordIndex,
      if (readingTimeMinutes != null)
        'reading_time_minutes': readingTimeMinutes,
      if (lastReadTimestamp != null) 'last_read_timestamp': lastReadTimestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? currentPageIndex,
      Value<int>? lastAudioPositionMs,
      Value<int>? lastWordIndex,
      Value<int>? readingTimeMinutes,
      Value<DateTime>? lastReadTimestamp,
      Value<DateTime>? createdAt,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ReadingProgressTableCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      lastAudioPositionMs: lastAudioPositionMs ?? this.lastAudioPositionMs,
      lastWordIndex: lastWordIndex ?? this.lastWordIndex,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      lastReadTimestamp: lastReadTimestamp ?? this.lastReadTimestamp,
      createdAt: createdAt ?? this.createdAt,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (currentPageIndex.present) {
      map['current_page_index'] = Variable<int>(currentPageIndex.value);
    }
    if (lastAudioPositionMs.present) {
      map['last_audio_position_ms'] = Variable<int>(lastAudioPositionMs.value);
    }
    if (lastWordIndex.present) {
      map['last_word_index'] = Variable<int>(lastWordIndex.value);
    }
    if (readingTimeMinutes.present) {
      map['reading_time_minutes'] = Variable<int>(readingTimeMinutes.value);
    }
    if (lastReadTimestamp.present) {
      map['last_read_timestamp'] = Variable<DateTime>(lastReadTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('currentPageIndex: $currentPageIndex, ')
          ..write('lastAudioPositionMs: $lastAudioPositionMs, ')
          ..write('lastWordIndex: $lastWordIndex, ')
          ..write('readingTimeMinutes: $readingTimeMinutes, ')
          ..write('lastReadTimestamp: $lastReadTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderSettingsTableTable extends ReaderSettingsTable
    with TableInfo<$ReaderSettingsTableTable, ReaderSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typefaceMeta =
      const VerificationMeta('typeface');
  @override
  late final GeneratedColumn<String> typeface = GeneratedColumn<String>(
      'typeface', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('serif'));
  static const VerificationMeta _fontScaleMeta =
      const VerificationMeta('fontScale');
  @override
  late final GeneratedColumn<double> fontScale = GeneratedColumn<double>(
      'font_scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _lineHeightScaleMeta =
      const VerificationMeta('lineHeightScale');
  @override
  late final GeneratedColumn<double> lineHeightScale = GeneratedColumn<double>(
      'line_height_scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _useJustifyAlignmentMeta =
      const VerificationMeta('useJustifyAlignment');
  @override
  late final GeneratedColumn<bool> useJustifyAlignment = GeneratedColumn<bool>(
      'use_justify_alignment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("use_justify_alignment" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _immersiveModeMeta =
      const VerificationMeta('immersiveMode');
  @override
  late final GeneratedColumn<bool> immersiveMode = GeneratedColumn<bool>(
      'immersive_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("immersive_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        typeface,
        fontScale,
        lineHeightScale,
        useJustifyAlignment,
        immersiveMode,
        themeMode,
        updatedAt,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReaderSettingsEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('typeface')) {
      context.handle(_typefaceMeta,
          typeface.isAcceptableOrUnknown(data['typeface']!, _typefaceMeta));
    }
    if (data.containsKey('font_scale')) {
      context.handle(_fontScaleMeta,
          fontScale.isAcceptableOrUnknown(data['font_scale']!, _fontScaleMeta));
    }
    if (data.containsKey('line_height_scale')) {
      context.handle(
          _lineHeightScaleMeta,
          lineHeightScale.isAcceptableOrUnknown(
              data['line_height_scale']!, _lineHeightScaleMeta));
    }
    if (data.containsKey('use_justify_alignment')) {
      context.handle(
          _useJustifyAlignmentMeta,
          useJustifyAlignment.isAcceptableOrUnknown(
              data['use_justify_alignment']!, _useJustifyAlignmentMeta));
    }
    if (data.containsKey('immersive_mode')) {
      context.handle(
          _immersiveModeMeta,
          immersiveMode.isAcceptableOrUnknown(
              data['immersive_mode']!, _immersiveModeMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderSettingsEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      typeface: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeface'])!,
      fontScale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_scale'])!,
      lineHeightScale: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}line_height_scale'])!,
      useJustifyAlignment: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}use_justify_alignment'])!,
      immersiveMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}immersive_mode'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ReaderSettingsTableTable createAlias(String alias) {
    return $ReaderSettingsTableTable(attachedDatabase, alias);
  }
}

class ReaderSettingsEntry extends DataClass
    implements Insertable<ReaderSettingsEntry> {
  final String id;
  final String userId;
  final String typeface;
  final double fontScale;
  final double lineHeightScale;
  final bool useJustifyAlignment;
  final bool immersiveMode;
  final String themeMode;
  final DateTime updatedAt;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const ReaderSettingsEntry(
      {required this.id,
      required this.userId,
      required this.typeface,
      required this.fontScale,
      required this.lineHeightScale,
      required this.useJustifyAlignment,
      required this.immersiveMode,
      required this.themeMode,
      required this.updatedAt,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['typeface'] = Variable<String>(typeface);
    map['font_scale'] = Variable<double>(fontScale);
    map['line_height_scale'] = Variable<double>(lineHeightScale);
    map['use_justify_alignment'] = Variable<bool>(useJustifyAlignment);
    map['immersive_mode'] = Variable<bool>(immersiveMode);
    map['theme_mode'] = Variable<String>(themeMode);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ReaderSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return ReaderSettingsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      typeface: Value(typeface),
      fontScale: Value(fontScale),
      lineHeightScale: Value(lineHeightScale),
      useJustifyAlignment: Value(useJustifyAlignment),
      immersiveMode: Value(immersiveMode),
      themeMode: Value(themeMode),
      updatedAt: Value(updatedAt),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ReaderSettingsEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderSettingsEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      typeface: serializer.fromJson<String>(json['typeface']),
      fontScale: serializer.fromJson<double>(json['fontScale']),
      lineHeightScale: serializer.fromJson<double>(json['lineHeightScale']),
      useJustifyAlignment:
          serializer.fromJson<bool>(json['useJustifyAlignment']),
      immersiveMode: serializer.fromJson<bool>(json['immersiveMode']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'typeface': serializer.toJson<String>(typeface),
      'fontScale': serializer.toJson<double>(fontScale),
      'lineHeightScale': serializer.toJson<double>(lineHeightScale),
      'useJustifyAlignment': serializer.toJson<bool>(useJustifyAlignment),
      'immersiveMode': serializer.toJson<bool>(immersiveMode),
      'themeMode': serializer.toJson<String>(themeMode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ReaderSettingsEntry copyWith(
          {String? id,
          String? userId,
          String? typeface,
          double? fontScale,
          double? lineHeightScale,
          bool? useJustifyAlignment,
          bool? immersiveMode,
          String? themeMode,
          DateTime? updatedAt,
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ReaderSettingsEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        typeface: typeface ?? this.typeface,
        fontScale: fontScale ?? this.fontScale,
        lineHeightScale: lineHeightScale ?? this.lineHeightScale,
        useJustifyAlignment: useJustifyAlignment ?? this.useJustifyAlignment,
        immersiveMode: immersiveMode ?? this.immersiveMode,
        themeMode: themeMode ?? this.themeMode,
        updatedAt: updatedAt ?? this.updatedAt,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ReaderSettingsEntry copyWithCompanion(ReaderSettingsTableCompanion data) {
    return ReaderSettingsEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      typeface: data.typeface.present ? data.typeface.value : this.typeface,
      fontScale: data.fontScale.present ? data.fontScale.value : this.fontScale,
      lineHeightScale: data.lineHeightScale.present
          ? data.lineHeightScale.value
          : this.lineHeightScale,
      useJustifyAlignment: data.useJustifyAlignment.present
          ? data.useJustifyAlignment.value
          : this.useJustifyAlignment,
      immersiveMode: data.immersiveMode.present
          ? data.immersiveMode.value
          : this.immersiveMode,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('typeface: $typeface, ')
          ..write('fontScale: $fontScale, ')
          ..write('lineHeightScale: $lineHeightScale, ')
          ..write('useJustifyAlignment: $useJustifyAlignment, ')
          ..write('immersiveMode: $immersiveMode, ')
          ..write('themeMode: $themeMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      typeface,
      fontScale,
      lineHeightScale,
      useJustifyAlignment,
      immersiveMode,
      themeMode,
      updatedAt,
      syncedWithFirestore,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderSettingsEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.typeface == this.typeface &&
          other.fontScale == this.fontScale &&
          other.lineHeightScale == this.lineHeightScale &&
          other.useJustifyAlignment == this.useJustifyAlignment &&
          other.immersiveMode == this.immersiveMode &&
          other.themeMode == this.themeMode &&
          other.updatedAt == this.updatedAt &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ReaderSettingsTableCompanion
    extends UpdateCompanion<ReaderSettingsEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> typeface;
  final Value<double> fontScale;
  final Value<double> lineHeightScale;
  final Value<bool> useJustifyAlignment;
  final Value<bool> immersiveMode;
  final Value<String> themeMode;
  final Value<DateTime> updatedAt;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ReaderSettingsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.typeface = const Value.absent(),
    this.fontScale = const Value.absent(),
    this.lineHeightScale = const Value.absent(),
    this.useJustifyAlignment = const Value.absent(),
    this.immersiveMode = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderSettingsTableCompanion.insert({
    required String id,
    required String userId,
    this.typeface = const Value.absent(),
    this.fontScale = const Value.absent(),
    this.lineHeightScale = const Value.absent(),
    this.useJustifyAlignment = const Value.absent(),
    this.immersiveMode = const Value.absent(),
    this.themeMode = const Value.absent(),
    required DateTime updatedAt,
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        updatedAt = Value(updatedAt);
  static Insertable<ReaderSettingsEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? typeface,
    Expression<double>? fontScale,
    Expression<double>? lineHeightScale,
    Expression<bool>? useJustifyAlignment,
    Expression<bool>? immersiveMode,
    Expression<String>? themeMode,
    Expression<DateTime>? updatedAt,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (typeface != null) 'typeface': typeface,
      if (fontScale != null) 'font_scale': fontScale,
      if (lineHeightScale != null) 'line_height_scale': lineHeightScale,
      if (useJustifyAlignment != null)
        'use_justify_alignment': useJustifyAlignment,
      if (immersiveMode != null) 'immersive_mode': immersiveMode,
      if (themeMode != null) 'theme_mode': themeMode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderSettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? typeface,
      Value<double>? fontScale,
      Value<double>? lineHeightScale,
      Value<bool>? useJustifyAlignment,
      Value<bool>? immersiveMode,
      Value<String>? themeMode,
      Value<DateTime>? updatedAt,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ReaderSettingsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      typeface: typeface ?? this.typeface,
      fontScale: fontScale ?? this.fontScale,
      lineHeightScale: lineHeightScale ?? this.lineHeightScale,
      useJustifyAlignment: useJustifyAlignment ?? this.useJustifyAlignment,
      immersiveMode: immersiveMode ?? this.immersiveMode,
      themeMode: themeMode ?? this.themeMode,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (typeface.present) {
      map['typeface'] = Variable<String>(typeface.value);
    }
    if (fontScale.present) {
      map['font_scale'] = Variable<double>(fontScale.value);
    }
    if (lineHeightScale.present) {
      map['line_height_scale'] = Variable<double>(lineHeightScale.value);
    }
    if (useJustifyAlignment.present) {
      map['use_justify_alignment'] = Variable<bool>(useJustifyAlignment.value);
    }
    if (immersiveMode.present) {
      map['immersive_mode'] = Variable<bool>(immersiveMode.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('typeface: $typeface, ')
          ..write('fontScale: $fontScale, ')
          ..write('lineHeightScale: $lineHeightScale, ')
          ..write('useJustifyAlignment: $useJustifyAlignment, ')
          ..write('immersiveMode: $immersiveMode, ')
          ..write('themeMode: $themeMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTableTable extends BookmarksTable
    with TableInfo<$BookmarksTableTable, BookmarkEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _charIndexMeta =
      const VerificationMeta('charIndex');
  @override
  late final GeneratedColumn<int> charIndex = GeneratedColumn<int>(
      'char_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        pageIndex,
        charIndex,
        label,
        createdAt,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks_table';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('char_index')) {
      context.handle(_charIndexMeta,
          charIndex.isAcceptableOrUnknown(data['char_index']!, _charIndexMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      charIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_index'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $BookmarksTableTable createAlias(String alias) {
    return $BookmarksTableTable(attachedDatabase, alias);
  }
}

class BookmarkEntry extends DataClass implements Insertable<BookmarkEntry> {
  final String id;
  final String bookId;
  final int pageIndex;
  final int charIndex;
  final String? label;
  final DateTime createdAt;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const BookmarkEntry(
      {required this.id,
      required this.bookId,
      required this.pageIndex,
      required this.charIndex,
      this.label,
      required this.createdAt,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['page_index'] = Variable<int>(pageIndex);
    map['char_index'] = Variable<int>(charIndex);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  BookmarksTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarksTableCompanion(
      id: Value(id),
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      charIndex: Value(charIndex),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      createdAt: Value(createdAt),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory BookmarkEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkEntry(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      charIndex: serializer.fromJson<int>(json['charIndex']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'charIndex': serializer.toJson<int>(charIndex),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  BookmarkEntry copyWith(
          {String? id,
          String? bookId,
          int? pageIndex,
          int? charIndex,
          Value<String?> label = const Value.absent(),
          DateTime? createdAt,
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      BookmarkEntry(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        pageIndex: pageIndex ?? this.pageIndex,
        charIndex: charIndex ?? this.charIndex,
        label: label.present ? label.value : this.label,
        createdAt: createdAt ?? this.createdAt,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  BookmarkEntry copyWithCompanion(BookmarksTableCompanion data) {
    return BookmarkEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      charIndex: data.charIndex.present ? data.charIndex.value : this.charIndex,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('charIndex: $charIndex, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, pageIndex, charIndex, label,
      createdAt, syncedWithFirestore, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.pageIndex == this.pageIndex &&
          other.charIndex == this.charIndex &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class BookmarksTableCompanion extends UpdateCompanion<BookmarkEntry> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> pageIndex;
  final Value<int> charIndex;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const BookmarksTableCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.charIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksTableCompanion.insert({
    required String id,
    required String bookId,
    required int pageIndex,
    this.charIndex = const Value.absent(),
    this.label = const Value.absent(),
    required DateTime createdAt,
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        pageIndex = Value(pageIndex),
        createdAt = Value(createdAt);
  static Insertable<BookmarkEntry> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? pageIndex,
    Expression<int>? charIndex,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (charIndex != null) 'char_index': charIndex,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? pageIndex,
      Value<int>? charIndex,
      Value<String?>? label,
      Value<DateTime>? createdAt,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return BookmarksTableCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageIndex: pageIndex ?? this.pageIndex,
      charIndex: charIndex ?? this.charIndex,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (charIndex.present) {
      map['char_index'] = Variable<int>(charIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('charIndex: $charIndex, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTableTable extends HighlightsTable
    with TableInfo<$HighlightsTableTable, HighlightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startCharIndexMeta =
      const VerificationMeta('startCharIndex');
  @override
  late final GeneratedColumn<int> startCharIndex = GeneratedColumn<int>(
      'start_char_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endCharIndexMeta =
      const VerificationMeta('endCharIndex');
  @override
  late final GeneratedColumn<int> endCharIndex = GeneratedColumn<int>(
      'end_char_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _selectedTextMeta =
      const VerificationMeta('selectedText');
  @override
  late final GeneratedColumn<String> selectedText = GeneratedColumn<String>(
      'selected_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#FFFF00'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedWithFirestoreMeta =
      const VerificationMeta('syncedWithFirestore');
  @override
  late final GeneratedColumn<bool> syncedWithFirestore = GeneratedColumn<bool>(
      'synced_with_firestore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_with_firestore" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        pageIndex,
        startCharIndex,
        endCharIndex,
        selectedText,
        note,
        color,
        createdAt,
        syncedWithFirestore,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights_table';
  @override
  VerificationContext validateIntegrity(Insertable<HighlightEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('start_char_index')) {
      context.handle(
          _startCharIndexMeta,
          startCharIndex.isAcceptableOrUnknown(
              data['start_char_index']!, _startCharIndexMeta));
    } else if (isInserting) {
      context.missing(_startCharIndexMeta);
    }
    if (data.containsKey('end_char_index')) {
      context.handle(
          _endCharIndexMeta,
          endCharIndex.isAcceptableOrUnknown(
              data['end_char_index']!, _endCharIndexMeta));
    } else if (isInserting) {
      context.missing(_endCharIndexMeta);
    }
    if (data.containsKey('selected_text')) {
      context.handle(
          _selectedTextMeta,
          selectedText.isAcceptableOrUnknown(
              data['selected_text']!, _selectedTextMeta));
    } else if (isInserting) {
      context.missing(_selectedTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_with_firestore')) {
      context.handle(
          _syncedWithFirestoreMeta,
          syncedWithFirestore.isAcceptableOrUnknown(
              data['synced_with_firestore']!, _syncedWithFirestoreMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HighlightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HighlightEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      startCharIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_char_index'])!,
      endCharIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_char_index'])!,
      selectedText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_text'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedWithFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_with_firestore'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $HighlightsTableTable createAlias(String alias) {
    return $HighlightsTableTable(attachedDatabase, alias);
  }
}

class HighlightEntry extends DataClass implements Insertable<HighlightEntry> {
  final String id;
  final String bookId;
  final int pageIndex;
  final int startCharIndex;
  final int endCharIndex;
  final String selectedText;
  final String? note;
  final String color;
  final DateTime createdAt;
  final bool syncedWithFirestore;
  final DateTime? lastSyncedAt;
  const HighlightEntry(
      {required this.id,
      required this.bookId,
      required this.pageIndex,
      required this.startCharIndex,
      required this.endCharIndex,
      required this.selectedText,
      this.note,
      required this.color,
      required this.createdAt,
      required this.syncedWithFirestore,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['page_index'] = Variable<int>(pageIndex);
    map['start_char_index'] = Variable<int>(startCharIndex);
    map['end_char_index'] = Variable<int>(endCharIndex);
    map['selected_text'] = Variable<String>(selectedText);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  HighlightsTableCompanion toCompanion(bool nullToAbsent) {
    return HighlightsTableCompanion(
      id: Value(id),
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      startCharIndex: Value(startCharIndex),
      endCharIndex: Value(endCharIndex),
      selectedText: Value(selectedText),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      color: Value(color),
      createdAt: Value(createdAt),
      syncedWithFirestore: Value(syncedWithFirestore),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory HighlightEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HighlightEntry(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      startCharIndex: serializer.fromJson<int>(json['startCharIndex']),
      endCharIndex: serializer.fromJson<int>(json['endCharIndex']),
      selectedText: serializer.fromJson<String>(json['selectedText']),
      note: serializer.fromJson<String?>(json['note']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedWithFirestore:
          serializer.fromJson<bool>(json['syncedWithFirestore']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'startCharIndex': serializer.toJson<int>(startCharIndex),
      'endCharIndex': serializer.toJson<int>(endCharIndex),
      'selectedText': serializer.toJson<String>(selectedText),
      'note': serializer.toJson<String?>(note),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedWithFirestore': serializer.toJson<bool>(syncedWithFirestore),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  HighlightEntry copyWith(
          {String? id,
          String? bookId,
          int? pageIndex,
          int? startCharIndex,
          int? endCharIndex,
          String? selectedText,
          Value<String?> note = const Value.absent(),
          String? color,
          DateTime? createdAt,
          bool? syncedWithFirestore,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      HighlightEntry(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        pageIndex: pageIndex ?? this.pageIndex,
        startCharIndex: startCharIndex ?? this.startCharIndex,
        endCharIndex: endCharIndex ?? this.endCharIndex,
        selectedText: selectedText ?? this.selectedText,
        note: note.present ? note.value : this.note,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  HighlightEntry copyWithCompanion(HighlightsTableCompanion data) {
    return HighlightEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      startCharIndex: data.startCharIndex.present
          ? data.startCharIndex.value
          : this.startCharIndex,
      endCharIndex: data.endCharIndex.present
          ? data.endCharIndex.value
          : this.endCharIndex,
      selectedText: data.selectedText.present
          ? data.selectedText.value
          : this.selectedText,
      note: data.note.present ? data.note.value : this.note,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedWithFirestore: data.syncedWithFirestore.present
          ? data.syncedWithFirestore.value
          : this.syncedWithFirestore,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HighlightEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('startCharIndex: $startCharIndex, ')
          ..write('endCharIndex: $endCharIndex, ')
          ..write('selectedText: $selectedText, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookId,
      pageIndex,
      startCharIndex,
      endCharIndex,
      selectedText,
      note,
      color,
      createdAt,
      syncedWithFirestore,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HighlightEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.pageIndex == this.pageIndex &&
          other.startCharIndex == this.startCharIndex &&
          other.endCharIndex == this.endCharIndex &&
          other.selectedText == this.selectedText &&
          other.note == this.note &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.syncedWithFirestore == this.syncedWithFirestore &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class HighlightsTableCompanion extends UpdateCompanion<HighlightEntry> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> pageIndex;
  final Value<int> startCharIndex;
  final Value<int> endCharIndex;
  final Value<String> selectedText;
  final Value<String?> note;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<bool> syncedWithFirestore;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const HighlightsTableCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.startCharIndex = const Value.absent(),
    this.endCharIndex = const Value.absent(),
    this.selectedText = const Value.absent(),
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HighlightsTableCompanion.insert({
    required String id,
    required String bookId,
    required int pageIndex,
    required int startCharIndex,
    required int endCharIndex,
    required String selectedText,
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    required DateTime createdAt,
    this.syncedWithFirestore = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        pageIndex = Value(pageIndex),
        startCharIndex = Value(startCharIndex),
        endCharIndex = Value(endCharIndex),
        selectedText = Value(selectedText),
        createdAt = Value(createdAt);
  static Insertable<HighlightEntry> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? pageIndex,
    Expression<int>? startCharIndex,
    Expression<int>? endCharIndex,
    Expression<String>? selectedText,
    Expression<String>? note,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<bool>? syncedWithFirestore,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (startCharIndex != null) 'start_char_index': startCharIndex,
      if (endCharIndex != null) 'end_char_index': endCharIndex,
      if (selectedText != null) 'selected_text': selectedText,
      if (note != null) 'note': note,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedWithFirestore != null)
        'synced_with_firestore': syncedWithFirestore,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HighlightsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? pageIndex,
      Value<int>? startCharIndex,
      Value<int>? endCharIndex,
      Value<String>? selectedText,
      Value<String?>? note,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<bool>? syncedWithFirestore,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return HighlightsTableCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageIndex: pageIndex ?? this.pageIndex,
      startCharIndex: startCharIndex ?? this.startCharIndex,
      endCharIndex: endCharIndex ?? this.endCharIndex,
      selectedText: selectedText ?? this.selectedText,
      note: note ?? this.note,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      syncedWithFirestore: syncedWithFirestore ?? this.syncedWithFirestore,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (startCharIndex.present) {
      map['start_char_index'] = Variable<int>(startCharIndex.value);
    }
    if (endCharIndex.present) {
      map['end_char_index'] = Variable<int>(endCharIndex.value);
    }
    if (selectedText.present) {
      map['selected_text'] = Variable<String>(selectedText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedWithFirestore.present) {
      map['synced_with_firestore'] = Variable<bool>(syncedWithFirestore.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsTableCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('startCharIndex: $startCharIndex, ')
          ..write('endCharIndex: $endCharIndex, ')
          ..write('selectedText: $selectedText, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedWithFirestore: $syncedWithFirestore, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsCacheMetadataTableTable extends TtsCacheMetadataTable
    with TableInfo<$TtsCacheMetadataTableTable, TtsCacheMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsCacheMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _voiceIdMeta =
      const VerificationMeta('voiceId');
  @override
  late final GeneratedColumn<String> voiceId = GeneratedColumn<String>(
      'voice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>('last_accessed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        pageIndex,
        voiceId,
        cachedAt,
        sizeBytes,
        durationMs,
        lastAccessedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_cache_metadata_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsCacheMetadataEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('voice_id')) {
      context.handle(_voiceIdMeta,
          voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta));
    } else if (isInserting) {
      context.missing(_voiceIdMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsCacheMetadataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsCacheMetadataEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      voiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_id'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed_at'])!,
    );
  }

  @override
  $TtsCacheMetadataTableTable createAlias(String alias) {
    return $TtsCacheMetadataTableTable(attachedDatabase, alias);
  }
}

class TtsCacheMetadataEntry extends DataClass
    implements Insertable<TtsCacheMetadataEntry> {
  final String id;
  final String bookId;
  final int pageIndex;
  final String voiceId;
  final DateTime cachedAt;
  final int sizeBytes;
  final int durationMs;
  final DateTime lastAccessedAt;
  const TtsCacheMetadataEntry(
      {required this.id,
      required this.bookId,
      required this.pageIndex,
      required this.voiceId,
      required this.cachedAt,
      required this.sizeBytes,
      required this.durationMs,
      required this.lastAccessedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['page_index'] = Variable<int>(pageIndex);
    map['voice_id'] = Variable<String>(voiceId);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['duration_ms'] = Variable<int>(durationMs);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  TtsCacheMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return TtsCacheMetadataTableCompanion(
      id: Value(id),
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      voiceId: Value(voiceId),
      cachedAt: Value(cachedAt),
      sizeBytes: Value(sizeBytes),
      durationMs: Value(durationMs),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory TtsCacheMetadataEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsCacheMetadataEntry(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      voiceId: serializer.fromJson<String>(json['voiceId']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'voiceId': serializer.toJson<String>(voiceId),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'durationMs': serializer.toJson<int>(durationMs),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  TtsCacheMetadataEntry copyWith(
          {String? id,
          String? bookId,
          int? pageIndex,
          String? voiceId,
          DateTime? cachedAt,
          int? sizeBytes,
          int? durationMs,
          DateTime? lastAccessedAt}) =>
      TtsCacheMetadataEntry(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        pageIndex: pageIndex ?? this.pageIndex,
        voiceId: voiceId ?? this.voiceId,
        cachedAt: cachedAt ?? this.cachedAt,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        durationMs: durationMs ?? this.durationMs,
        lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      );
  TtsCacheMetadataEntry copyWithCompanion(TtsCacheMetadataTableCompanion data) {
    return TtsCacheMetadataEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsCacheMetadataEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('voiceId: $voiceId, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, pageIndex, voiceId, cachedAt,
      sizeBytes, durationMs, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsCacheMetadataEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.pageIndex == this.pageIndex &&
          other.voiceId == this.voiceId &&
          other.cachedAt == this.cachedAt &&
          other.sizeBytes == this.sizeBytes &&
          other.durationMs == this.durationMs &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class TtsCacheMetadataTableCompanion
    extends UpdateCompanion<TtsCacheMetadataEntry> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> pageIndex;
  final Value<String> voiceId;
  final Value<DateTime> cachedAt;
  final Value<int> sizeBytes;
  final Value<int> durationMs;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const TtsCacheMetadataTableCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsCacheMetadataTableCompanion.insert({
    required String id,
    required String bookId,
    required int pageIndex,
    required String voiceId,
    required DateTime cachedAt,
    required int sizeBytes,
    required int durationMs,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        pageIndex = Value(pageIndex),
        voiceId = Value(voiceId),
        cachedAt = Value(cachedAt),
        sizeBytes = Value(sizeBytes),
        durationMs = Value(durationMs),
        lastAccessedAt = Value(lastAccessedAt);
  static Insertable<TtsCacheMetadataEntry> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? pageIndex,
    Expression<String>? voiceId,
    Expression<DateTime>? cachedAt,
    Expression<int>? sizeBytes,
    Expression<int>? durationMs,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (voiceId != null) 'voice_id': voiceId,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsCacheMetadataTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? pageIndex,
      Value<String>? voiceId,
      Value<DateTime>? cachedAt,
      Value<int>? sizeBytes,
      Value<int>? durationMs,
      Value<DateTime>? lastAccessedAt,
      Value<int>? rowid}) {
    return TtsCacheMetadataTableCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageIndex: pageIndex ?? this.pageIndex,
      voiceId: voiceId ?? this.voiceId,
      cachedAt: cachedAt ?? this.cachedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationMs: durationMs ?? this.durationMs,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<String>(voiceId.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsCacheMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('voiceId: $voiceId, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTableMeta =
      const VerificationMeta('targetTable');
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
      'target_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
      'row_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastRetryAtMeta =
      const VerificationMeta('lastRetryAt');
  @override
  late final GeneratedColumn<DateTime> lastRetryAt = GeneratedColumn<DateTime>(
      'last_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operation,
        targetTable,
        rowId,
        payload,
        createdAt,
        lastRetryAt,
        retryCount,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
          _targetTableMeta,
          targetTable.isAcceptableOrUnknown(
              data['target_table']!, _targetTableMeta));
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
          _rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_retry_at')) {
      context.handle(
          _lastRetryAtMeta,
          lastRetryAt.isAcceptableOrUnknown(
              data['last_retry_at']!, _lastRetryAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      targetTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_table'])!,
      rowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}row_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_retry_at']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String id;
  final String operation;
  final String targetTable;
  final String rowId;
  final String payload;
  final DateTime createdAt;
  final DateTime? lastRetryAt;
  final int retryCount;
  final String status;
  const SyncQueueEntry(
      {required this.id,
      required this.operation,
      required this.targetTable,
      required this.rowId,
      required this.payload,
      required this.createdAt,
      this.lastRetryAt,
      required this.retryCount,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation'] = Variable<String>(operation);
    map['target_table'] = Variable<String>(targetTable);
    map['row_id'] = Variable<String>(rowId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastRetryAt != null) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      operation: Value(operation),
      targetTable: Value(targetTable),
      rowId: Value(rowId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      lastRetryAt: lastRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRetryAt),
      retryCount: Value(retryCount),
      status: Value(status),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastRetryAt: serializer.fromJson<DateTime?>(json['lastRetryAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operation': serializer.toJson<String>(operation),
      'targetTable': serializer.toJson<String>(targetTable),
      'rowId': serializer.toJson<String>(rowId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastRetryAt': serializer.toJson<DateTime?>(lastRetryAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueEntry copyWith(
          {String? id,
          String? operation,
          String? targetTable,
          String? rowId,
          String? payload,
          DateTime? createdAt,
          Value<DateTime?> lastRetryAt = const Value.absent(),
          int? retryCount,
          String? status}) =>
      SyncQueueEntry(
        id: id ?? this.id,
        operation: operation ?? this.operation,
        targetTable: targetTable ?? this.targetTable,
        rowId: rowId ?? this.rowId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        lastRetryAt: lastRetryAt.present ? lastRetryAt.value : this.lastRetryAt,
        retryCount: retryCount ?? this.retryCount,
        status: status ?? this.status,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      targetTable:
          data.targetTable.present ? data.targetTable.value : this.targetTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastRetryAt:
          data.lastRetryAt.present ? data.lastRetryAt.value : this.lastRetryAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operation, targetTable, rowId, payload,
      createdAt, lastRetryAt, retryCount, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.targetTable == this.targetTable &&
          other.rowId == this.rowId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.lastRetryAt == this.lastRetryAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> id;
  final Value<String> operation;
  final Value<String> targetTable;
  final Value<String> rowId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastRetryAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String operation,
    required String targetTable,
    required String rowId,
    required String payload,
    required DateTime createdAt,
    this.lastRetryAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        operation = Value(operation),
        targetTable = Value(targetTable),
        rowId = Value(rowId),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? operation,
    Expression<String>? targetTable,
    Expression<String>? rowId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastRetryAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (targetTable != null) 'target_table': targetTable,
      if (rowId != null) 'row_id': rowId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (lastRetryAt != null) 'last_retry_at': lastRetryAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? operation,
      Value<String>? targetTable,
      Value<String>? rowId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastRetryAt,
      Value<int>? retryCount,
      Value<String>? status,
      Value<int>? rowid}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      targetTable: targetTable ?? this.targetTable,
      rowId: rowId ?? this.rowId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastRetryAt.present) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $SavedBooksTableTable savedBooksTable =
      $SavedBooksTableTable(this);
  late final $ReadingProgressTableTable readingProgressTable =
      $ReadingProgressTableTable(this);
  late final $ReaderSettingsTableTable readerSettingsTable =
      $ReaderSettingsTableTable(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  late final $HighlightsTableTable highlightsTable =
      $HighlightsTableTable(this);
  late final $TtsCacheMetadataTableTable ttsCacheMetadataTable =
      $TtsCacheMetadataTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        usersTable,
        savedBooksTable,
        readingProgressTable,
        readerSettingsTable,
        bookmarksTable,
        highlightsTable,
        ttsCacheMetadataTable,
        syncQueueTable
      ];
}

typedef $$UsersTableTableCreateCompanionBuilder = UsersTableCompanion Function({
  required String id,
  required String email,
  Value<String?> displayName,
  required DateTime createdAt,
  Value<DateTime?> lastLoginAt,
  required String firebaseUid,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String?> displayName,
  Value<DateTime> createdAt,
  Value<DateTime?> lastLoginAt,
  Value<String> firebaseUid,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => column);

  GeneratedColumn<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$UsersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UserEntry,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (UserEntry, BaseReferences<_$AppDatabase, $UsersTableTable, UserEntry>),
    UserEntry,
    PrefetchHooks Function()> {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<String> firebaseUid = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersTableCompanion(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            firebaseUid: firebaseUid,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            Value<String?> displayName = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastLoginAt = const Value.absent(),
            required String firebaseUid,
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersTableCompanion.insert(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            firebaseUid: firebaseUid,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UserEntry,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (UserEntry, BaseReferences<_$AppDatabase, $UsersTableTable, UserEntry>),
    UserEntry,
    PrefetchHooks Function()>;
typedef $$SavedBooksTableTableCreateCompanionBuilder = SavedBooksTableCompanion
    Function({
  required String id,
  required String userId,
  required String title,
  Value<String?> author,
  required String format,
  Value<String?> coverImageUrl,
  Value<String?> fileUrl,
  Value<int> lastPageIndex,
  Value<int> totalPages,
  Value<DateTime?> lastReadAt,
  required DateTime addedAt,
  Value<String?> contentHash,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SavedBooksTableTableUpdateCompanionBuilder = SavedBooksTableCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String?> author,
  Value<String> format,
  Value<String?> coverImageUrl,
  Value<String?> fileUrl,
  Value<int> lastPageIndex,
  Value<int> totalPages,
  Value<DateTime?> lastReadAt,
  Value<DateTime> addedAt,
  Value<String?> contentHash,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SavedBooksTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavedBooksTableTable> {
  $$SavedBooksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPageIndex => $composableBuilder(
      column: $table.lastPageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SavedBooksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedBooksTableTable> {
  $$SavedBooksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPageIndex => $composableBuilder(
      column: $table.lastPageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SavedBooksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedBooksTableTable> {
  $$SavedBooksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<int> get lastPageIndex => $composableBuilder(
      column: $table.lastPageIndex, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SavedBooksTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedBooksTableTable,
    SavedBookEntry,
    $$SavedBooksTableTableFilterComposer,
    $$SavedBooksTableTableOrderingComposer,
    $$SavedBooksTableTableAnnotationComposer,
    $$SavedBooksTableTableCreateCompanionBuilder,
    $$SavedBooksTableTableUpdateCompanionBuilder,
    (
      SavedBookEntry,
      BaseReferences<_$AppDatabase, $SavedBooksTableTable, SavedBookEntry>
    ),
    SavedBookEntry,
    PrefetchHooks Function()> {
  $$SavedBooksTableTableTableManager(
      _$AppDatabase db, $SavedBooksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedBooksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedBooksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedBooksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> fileUrl = const Value.absent(),
            Value<int> lastPageIndex = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<String?> contentHash = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedBooksTableCompanion(
            id: id,
            userId: userId,
            title: title,
            author: author,
            format: format,
            coverImageUrl: coverImageUrl,
            fileUrl: fileUrl,
            lastPageIndex: lastPageIndex,
            totalPages: totalPages,
            lastReadAt: lastReadAt,
            addedAt: addedAt,
            contentHash: contentHash,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            Value<String?> author = const Value.absent(),
            required String format,
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> fileUrl = const Value.absent(),
            Value<int> lastPageIndex = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
            required DateTime addedAt,
            Value<String?> contentHash = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedBooksTableCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            author: author,
            format: format,
            coverImageUrl: coverImageUrl,
            fileUrl: fileUrl,
            lastPageIndex: lastPageIndex,
            totalPages: totalPages,
            lastReadAt: lastReadAt,
            addedAt: addedAt,
            contentHash: contentHash,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedBooksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedBooksTableTable,
    SavedBookEntry,
    $$SavedBooksTableTableFilterComposer,
    $$SavedBooksTableTableOrderingComposer,
    $$SavedBooksTableTableAnnotationComposer,
    $$SavedBooksTableTableCreateCompanionBuilder,
    $$SavedBooksTableTableUpdateCompanionBuilder,
    (
      SavedBookEntry,
      BaseReferences<_$AppDatabase, $SavedBooksTableTable, SavedBookEntry>
    ),
    SavedBookEntry,
    PrefetchHooks Function()>;
typedef $$ReadingProgressTableTableCreateCompanionBuilder
    = ReadingProgressTableCompanion Function({
  required String id,
  required String bookId,
  Value<int> currentPageIndex,
  Value<int> lastAudioPositionMs,
  Value<int> lastWordIndex,
  Value<int> readingTimeMinutes,
  required DateTime lastReadTimestamp,
  required DateTime createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ReadingProgressTableTableUpdateCompanionBuilder
    = ReadingProgressTableCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> currentPageIndex,
  Value<int> lastAudioPositionMs,
  Value<int> lastWordIndex,
  Value<int> readingTimeMinutes,
  Value<DateTime> lastReadTimestamp,
  Value<DateTime> createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ReadingProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentPageIndex => $composableBuilder(
      column: $table.currentPageIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAudioPositionMs => $composableBuilder(
      column: $table.lastAudioPositionMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastWordIndex => $composableBuilder(
      column: $table.lastWordIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadTimestamp => $composableBuilder(
      column: $table.lastReadTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentPageIndex => $composableBuilder(
      column: $table.currentPageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAudioPositionMs => $composableBuilder(
      column: $table.lastAudioPositionMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastWordIndex => $composableBuilder(
      column: $table.lastWordIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadTimestamp => $composableBuilder(
      column: $table.lastReadTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ReadingProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get currentPageIndex => $composableBuilder(
      column: $table.currentPageIndex, builder: (column) => column);

  GeneratedColumn<int> get lastAudioPositionMs => $composableBuilder(
      column: $table.lastAudioPositionMs, builder: (column) => column);

  GeneratedColumn<int> get lastWordIndex => $composableBuilder(
      column: $table.lastWordIndex, builder: (column) => column);

  GeneratedColumn<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadTimestamp => $composableBuilder(
      column: $table.lastReadTimestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ReadingProgressTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingProgressTableTable,
    ReadingProgressEntry,
    $$ReadingProgressTableTableFilterComposer,
    $$ReadingProgressTableTableOrderingComposer,
    $$ReadingProgressTableTableAnnotationComposer,
    $$ReadingProgressTableTableCreateCompanionBuilder,
    $$ReadingProgressTableTableUpdateCompanionBuilder,
    (
      ReadingProgressEntry,
      BaseReferences<_$AppDatabase, $ReadingProgressTableTable,
          ReadingProgressEntry>
    ),
    ReadingProgressEntry,
    PrefetchHooks Function()> {
  $$ReadingProgressTableTableTableManager(
      _$AppDatabase db, $ReadingProgressTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> currentPageIndex = const Value.absent(),
            Value<int> lastAudioPositionMs = const Value.absent(),
            Value<int> lastWordIndex = const Value.absent(),
            Value<int> readingTimeMinutes = const Value.absent(),
            Value<DateTime> lastReadTimestamp = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressTableCompanion(
            id: id,
            bookId: bookId,
            currentPageIndex: currentPageIndex,
            lastAudioPositionMs: lastAudioPositionMs,
            lastWordIndex: lastWordIndex,
            readingTimeMinutes: readingTimeMinutes,
            lastReadTimestamp: lastReadTimestamp,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            Value<int> currentPageIndex = const Value.absent(),
            Value<int> lastAudioPositionMs = const Value.absent(),
            Value<int> lastWordIndex = const Value.absent(),
            Value<int> readingTimeMinutes = const Value.absent(),
            required DateTime lastReadTimestamp,
            required DateTime createdAt,
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressTableCompanion.insert(
            id: id,
            bookId: bookId,
            currentPageIndex: currentPageIndex,
            lastAudioPositionMs: lastAudioPositionMs,
            lastWordIndex: lastWordIndex,
            readingTimeMinutes: readingTimeMinutes,
            lastReadTimestamp: lastReadTimestamp,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingProgressTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReadingProgressTableTable,
        ReadingProgressEntry,
        $$ReadingProgressTableTableFilterComposer,
        $$ReadingProgressTableTableOrderingComposer,
        $$ReadingProgressTableTableAnnotationComposer,
        $$ReadingProgressTableTableCreateCompanionBuilder,
        $$ReadingProgressTableTableUpdateCompanionBuilder,
        (
          ReadingProgressEntry,
          BaseReferences<_$AppDatabase, $ReadingProgressTableTable,
              ReadingProgressEntry>
        ),
        ReadingProgressEntry,
        PrefetchHooks Function()>;
typedef $$ReaderSettingsTableTableCreateCompanionBuilder
    = ReaderSettingsTableCompanion Function({
  required String id,
  required String userId,
  Value<String> typeface,
  Value<double> fontScale,
  Value<double> lineHeightScale,
  Value<bool> useJustifyAlignment,
  Value<bool> immersiveMode,
  Value<String> themeMode,
  required DateTime updatedAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ReaderSettingsTableTableUpdateCompanionBuilder
    = ReaderSettingsTableCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> typeface,
  Value<double> fontScale,
  Value<double> lineHeightScale,
  Value<bool> useJustifyAlignment,
  Value<bool> immersiveMode,
  Value<String> themeMode,
  Value<DateTime> updatedAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ReaderSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTableTable> {
  $$ReaderSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeface => $composableBuilder(
      column: $table.typeface, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontScale => $composableBuilder(
      column: $table.fontScale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lineHeightScale => $composableBuilder(
      column: $table.lineHeightScale,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get useJustifyAlignment => $composableBuilder(
      column: $table.useJustifyAlignment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get immersiveMode => $composableBuilder(
      column: $table.immersiveMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ReaderSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTableTable> {
  $$ReaderSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeface => $composableBuilder(
      column: $table.typeface, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontScale => $composableBuilder(
      column: $table.fontScale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lineHeightScale => $composableBuilder(
      column: $table.lineHeightScale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get useJustifyAlignment => $composableBuilder(
      column: $table.useJustifyAlignment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get immersiveMode => $composableBuilder(
      column: $table.immersiveMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ReaderSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTableTable> {
  $$ReaderSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get typeface =>
      $composableBuilder(column: $table.typeface, builder: (column) => column);

  GeneratedColumn<double> get fontScale =>
      $composableBuilder(column: $table.fontScale, builder: (column) => column);

  GeneratedColumn<double> get lineHeightScale => $composableBuilder(
      column: $table.lineHeightScale, builder: (column) => column);

  GeneratedColumn<bool> get useJustifyAlignment => $composableBuilder(
      column: $table.useJustifyAlignment, builder: (column) => column);

  GeneratedColumn<bool> get immersiveMode => $composableBuilder(
      column: $table.immersiveMode, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ReaderSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReaderSettingsTableTable,
    ReaderSettingsEntry,
    $$ReaderSettingsTableTableFilterComposer,
    $$ReaderSettingsTableTableOrderingComposer,
    $$ReaderSettingsTableTableAnnotationComposer,
    $$ReaderSettingsTableTableCreateCompanionBuilder,
    $$ReaderSettingsTableTableUpdateCompanionBuilder,
    (
      ReaderSettingsEntry,
      BaseReferences<_$AppDatabase, $ReaderSettingsTableTable,
          ReaderSettingsEntry>
    ),
    ReaderSettingsEntry,
    PrefetchHooks Function()> {
  $$ReaderSettingsTableTableTableManager(
      _$AppDatabase db, $ReaderSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderSettingsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> typeface = const Value.absent(),
            Value<double> fontScale = const Value.absent(),
            Value<double> lineHeightScale = const Value.absent(),
            Value<bool> useJustifyAlignment = const Value.absent(),
            Value<bool> immersiveMode = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReaderSettingsTableCompanion(
            id: id,
            userId: userId,
            typeface: typeface,
            fontScale: fontScale,
            lineHeightScale: lineHeightScale,
            useJustifyAlignment: useJustifyAlignment,
            immersiveMode: immersiveMode,
            themeMode: themeMode,
            updatedAt: updatedAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String> typeface = const Value.absent(),
            Value<double> fontScale = const Value.absent(),
            Value<double> lineHeightScale = const Value.absent(),
            Value<bool> useJustifyAlignment = const Value.absent(),
            Value<bool> immersiveMode = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReaderSettingsTableCompanion.insert(
            id: id,
            userId: userId,
            typeface: typeface,
            fontScale: fontScale,
            lineHeightScale: lineHeightScale,
            useJustifyAlignment: useJustifyAlignment,
            immersiveMode: immersiveMode,
            themeMode: themeMode,
            updatedAt: updatedAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReaderSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReaderSettingsTableTable,
    ReaderSettingsEntry,
    $$ReaderSettingsTableTableFilterComposer,
    $$ReaderSettingsTableTableOrderingComposer,
    $$ReaderSettingsTableTableAnnotationComposer,
    $$ReaderSettingsTableTableCreateCompanionBuilder,
    $$ReaderSettingsTableTableUpdateCompanionBuilder,
    (
      ReaderSettingsEntry,
      BaseReferences<_$AppDatabase, $ReaderSettingsTableTable,
          ReaderSettingsEntry>
    ),
    ReaderSettingsEntry,
    PrefetchHooks Function()>;
typedef $$BookmarksTableTableCreateCompanionBuilder = BookmarksTableCompanion
    Function({
  required String id,
  required String bookId,
  required int pageIndex,
  Value<int> charIndex,
  Value<String?> label,
  required DateTime createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$BookmarksTableTableUpdateCompanionBuilder = BookmarksTableCompanion
    Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> pageIndex,
  Value<int> charIndex,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$BookmarksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get charIndex => $composableBuilder(
      column: $table.charIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get charIndex => $composableBuilder(
      column: $table.charIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get charIndex =>
      $composableBuilder(column: $table.charIndex, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$BookmarksTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTableTable,
    BookmarkEntry,
    $$BookmarksTableTableFilterComposer,
    $$BookmarksTableTableOrderingComposer,
    $$BookmarksTableTableAnnotationComposer,
    $$BookmarksTableTableCreateCompanionBuilder,
    $$BookmarksTableTableUpdateCompanionBuilder,
    (
      BookmarkEntry,
      BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarkEntry>
    ),
    BookmarkEntry,
    PrefetchHooks Function()> {
  $$BookmarksTableTableTableManager(
      _$AppDatabase db, $BookmarksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> charIndex = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksTableCompanion(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            charIndex: charIndex,
            label: label,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int pageIndex,
            Value<int> charIndex = const Value.absent(),
            Value<String?> label = const Value.absent(),
            required DateTime createdAt,
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksTableCompanion.insert(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            charIndex: charIndex,
            label: label,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTableTable,
    BookmarkEntry,
    $$BookmarksTableTableFilterComposer,
    $$BookmarksTableTableOrderingComposer,
    $$BookmarksTableTableAnnotationComposer,
    $$BookmarksTableTableCreateCompanionBuilder,
    $$BookmarksTableTableUpdateCompanionBuilder,
    (
      BookmarkEntry,
      BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarkEntry>
    ),
    BookmarkEntry,
    PrefetchHooks Function()>;
typedef $$HighlightsTableTableCreateCompanionBuilder = HighlightsTableCompanion
    Function({
  required String id,
  required String bookId,
  required int pageIndex,
  required int startCharIndex,
  required int endCharIndex,
  required String selectedText,
  Value<String?> note,
  Value<String> color,
  required DateTime createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$HighlightsTableTableUpdateCompanionBuilder = HighlightsTableCompanion
    Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> pageIndex,
  Value<int> startCharIndex,
  Value<int> endCharIndex,
  Value<String> selectedText,
  Value<String?> note,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<bool> syncedWithFirestore,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$HighlightsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startCharIndex => $composableBuilder(
      column: $table.startCharIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endCharIndex => $composableBuilder(
      column: $table.endCharIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$HighlightsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startCharIndex => $composableBuilder(
      column: $table.startCharIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endCharIndex => $composableBuilder(
      column: $table.endCharIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedText => $composableBuilder(
      column: $table.selectedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$HighlightsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get startCharIndex => $composableBuilder(
      column: $table.startCharIndex, builder: (column) => column);

  GeneratedColumn<int> get endCharIndex => $composableBuilder(
      column: $table.endCharIndex, builder: (column) => column);

  GeneratedColumn<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get syncedWithFirestore => $composableBuilder(
      column: $table.syncedWithFirestore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$HighlightsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HighlightsTableTable,
    HighlightEntry,
    $$HighlightsTableTableFilterComposer,
    $$HighlightsTableTableOrderingComposer,
    $$HighlightsTableTableAnnotationComposer,
    $$HighlightsTableTableCreateCompanionBuilder,
    $$HighlightsTableTableUpdateCompanionBuilder,
    (
      HighlightEntry,
      BaseReferences<_$AppDatabase, $HighlightsTableTable, HighlightEntry>
    ),
    HighlightEntry,
    PrefetchHooks Function()> {
  $$HighlightsTableTableTableManager(
      _$AppDatabase db, $HighlightsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HighlightsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HighlightsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HighlightsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> startCharIndex = const Value.absent(),
            Value<int> endCharIndex = const Value.absent(),
            Value<String> selectedText = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HighlightsTableCompanion(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            startCharIndex: startCharIndex,
            endCharIndex: endCharIndex,
            selectedText: selectedText,
            note: note,
            color: color,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int pageIndex,
            required int startCharIndex,
            required int endCharIndex,
            required String selectedText,
            Value<String?> note = const Value.absent(),
            Value<String> color = const Value.absent(),
            required DateTime createdAt,
            Value<bool> syncedWithFirestore = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HighlightsTableCompanion.insert(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            startCharIndex: startCharIndex,
            endCharIndex: endCharIndex,
            selectedText: selectedText,
            note: note,
            color: color,
            createdAt: createdAt,
            syncedWithFirestore: syncedWithFirestore,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HighlightsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HighlightsTableTable,
    HighlightEntry,
    $$HighlightsTableTableFilterComposer,
    $$HighlightsTableTableOrderingComposer,
    $$HighlightsTableTableAnnotationComposer,
    $$HighlightsTableTableCreateCompanionBuilder,
    $$HighlightsTableTableUpdateCompanionBuilder,
    (
      HighlightEntry,
      BaseReferences<_$AppDatabase, $HighlightsTableTable, HighlightEntry>
    ),
    HighlightEntry,
    PrefetchHooks Function()>;
typedef $$TtsCacheMetadataTableTableCreateCompanionBuilder
    = TtsCacheMetadataTableCompanion Function({
  required String id,
  required String bookId,
  required int pageIndex,
  required String voiceId,
  required DateTime cachedAt,
  required int sizeBytes,
  required int durationMs,
  required DateTime lastAccessedAt,
  Value<int> rowid,
});
typedef $$TtsCacheMetadataTableTableUpdateCompanionBuilder
    = TtsCacheMetadataTableCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> pageIndex,
  Value<String> voiceId,
  Value<DateTime> cachedAt,
  Value<int> sizeBytes,
  Value<int> durationMs,
  Value<DateTime> lastAccessedAt,
  Value<int> rowid,
});

class $$TtsCacheMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsCacheMetadataTableTable> {
  $$TtsCacheMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceId => $composableBuilder(
      column: $table.voiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));
}

class $$TtsCacheMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsCacheMetadataTableTable> {
  $$TtsCacheMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceId => $composableBuilder(
      column: $table.voiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TtsCacheMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsCacheMetadataTableTable> {
  $$TtsCacheMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);
}

class $$TtsCacheMetadataTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TtsCacheMetadataTableTable,
    TtsCacheMetadataEntry,
    $$TtsCacheMetadataTableTableFilterComposer,
    $$TtsCacheMetadataTableTableOrderingComposer,
    $$TtsCacheMetadataTableTableAnnotationComposer,
    $$TtsCacheMetadataTableTableCreateCompanionBuilder,
    $$TtsCacheMetadataTableTableUpdateCompanionBuilder,
    (
      TtsCacheMetadataEntry,
      BaseReferences<_$AppDatabase, $TtsCacheMetadataTableTable,
          TtsCacheMetadataEntry>
    ),
    TtsCacheMetadataEntry,
    PrefetchHooks Function()> {
  $$TtsCacheMetadataTableTableTableManager(
      _$AppDatabase db, $TtsCacheMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsCacheMetadataTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsCacheMetadataTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsCacheMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<String> voiceId = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<DateTime> lastAccessedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsCacheMetadataTableCompanion(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            voiceId: voiceId,
            cachedAt: cachedAt,
            sizeBytes: sizeBytes,
            durationMs: durationMs,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int pageIndex,
            required String voiceId,
            required DateTime cachedAt,
            required int sizeBytes,
            required int durationMs,
            required DateTime lastAccessedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsCacheMetadataTableCompanion.insert(
            id: id,
            bookId: bookId,
            pageIndex: pageIndex,
            voiceId: voiceId,
            cachedAt: cachedAt,
            sizeBytes: sizeBytes,
            durationMs: durationMs,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TtsCacheMetadataTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TtsCacheMetadataTableTable,
        TtsCacheMetadataEntry,
        $$TtsCacheMetadataTableTableFilterComposer,
        $$TtsCacheMetadataTableTableOrderingComposer,
        $$TtsCacheMetadataTableTableAnnotationComposer,
        $$TtsCacheMetadataTableTableCreateCompanionBuilder,
        $$TtsCacheMetadataTableTableUpdateCompanionBuilder,
        (
          TtsCacheMetadataEntry,
          BaseReferences<_$AppDatabase, $TtsCacheMetadataTableTable,
              TtsCacheMetadataEntry>
        ),
        TtsCacheMetadataEntry,
        PrefetchHooks Function()>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  required String id,
  required String operation,
  required String targetTable,
  required String rowId,
  required String payload,
  required DateTime createdAt,
  Value<DateTime?> lastRetryAt,
  Value<int> retryCount,
  Value<String> status,
  Value<int> rowid,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<String> id,
  Value<String> operation,
  Value<String> targetTable,
  Value<String> rowId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime?> lastRetryAt,
  Value<int> retryCount,
  Value<String> status,
  Value<int> rowid,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueEntry,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> targetTable = const Value.absent(),
            Value<String> rowId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastRetryAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            operation: operation,
            targetTable: targetTable,
            rowId: rowId,
            payload: payload,
            createdAt: createdAt,
            lastRetryAt: lastRetryAt,
            retryCount: retryCount,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String operation,
            required String targetTable,
            required String rowId,
            required String payload,
            required DateTime createdAt,
            Value<DateTime?> lastRetryAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            operation: operation,
            targetTable: targetTable,
            rowId: rowId,
            payload: payload,
            createdAt: createdAt,
            lastRetryAt: lastRetryAt,
            retryCount: retryCount,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueEntry,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$SavedBooksTableTableTableManager get savedBooksTable =>
      $$SavedBooksTableTableTableManager(_db, _db.savedBooksTable);
  $$ReadingProgressTableTableTableManager get readingProgressTable =>
      $$ReadingProgressTableTableTableManager(_db, _db.readingProgressTable);
  $$ReaderSettingsTableTableTableManager get readerSettingsTable =>
      $$ReaderSettingsTableTableTableManager(_db, _db.readerSettingsTable);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
  $$HighlightsTableTableTableManager get highlightsTable =>
      $$HighlightsTableTableTableManager(_db, _db.highlightsTable);
  $$TtsCacheMetadataTableTableTableManager get ttsCacheMetadataTable =>
      $$TtsCacheMetadataTableTableTableManager(_db, _db.ttsCacheMetadataTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Users table - stores user profile data locally
@DataClassName('UserEntry')
class UsersTable extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  TextColumn get firebaseUid => text().unique()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// SavedBooks table - stores user's book library
@DataClassName('SavedBookEntry')
class SavedBooksTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get format => text()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get fileUrl => text().nullable()();
  IntColumn get lastPageIndex => integer().withDefault(const Constant(0))();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReadAt => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  TextColumn get contentHash => text().nullable()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ReadingProgress table - tracks reading position per book
@DataClassName('ReadingProgressEntry')
class ReadingProgressTable extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().unique()();
  IntColumn get currentPageIndex => integer().withDefault(const Constant(0))();
  IntColumn get lastAudioPositionMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get lastWordIndex => integer().withDefault(const Constant(0))();
  IntColumn get readingTimeMinutes =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReadTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ReaderSettings table - user's reading preferences
@DataClassName('ReaderSettingsEntry')
class ReaderSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().unique()();
  TextColumn get typeface => text().withDefault(const Constant('serif'))();
  RealColumn get fontScale => real().withDefault(const Constant(1.0))();
  RealColumn get lineHeightScale => real().withDefault(const Constant(1.0))();
  BoolColumn get useJustifyAlignment =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get immersiveMode =>
      boolean().withDefault(const Constant(false))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bookmarks table - user's saved positions in books
@DataClassName('BookmarkEntry')
class BookmarksTable extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get pageIndex => integer()();
  IntColumn get charIndex => integer().withDefault(const Constant(0))();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Highlights table - user's highlighted text in books
@DataClassName('HighlightEntry')
class HighlightsTable extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get pageIndex => integer()();
  IntColumn get startCharIndex => integer()();
  IntColumn get endCharIndex => integer()();
  TextColumn get selectedText => text()();
  TextColumn get note => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#FFFF00'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get syncedWithFirestore =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// TTS Cache Metadata table - tracks cached audio for optimization
@DataClassName('TtsCacheMetadataEntry')
class TtsCacheMetadataTable extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get pageIndex => integer()();
  TextColumn get voiceId => text()();
  DateTimeColumn get cachedAt => dateTime()();
  IntColumn get sizeBytes => integer()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync Queue table - tracks pending Firestore sync operations
@DataClassName('SyncQueueEntry')
class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get operation => text()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastRetryAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DATABASE CLASS
// ============================================================================

/// Main Drift database class for Sonant app
@DriftDatabase(
  tables: [
    UsersTable,
    SavedBooksTable,
    ReadingProgressTable,
    ReaderSettingsTable,
    BookmarksTable,
    HighlightsTable,
    TtsCacheMetadataTable,
    SyncQueueTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Database schema version - increment when making schema changes
  @override
  int get schemaVersion => 1;

  // Migration strategy for schema updates
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future schema migrations here
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    await close();
  }

  /// Clear all data (useful for logout)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueueTable).go();
      await delete(ttsCacheMetadataTable).go();
      await delete(highlightsTable).go();
      await delete(bookmarksTable).go();
      await delete(readingProgressTable).go();
      await delete(readerSettingsTable).go();
      await delete(savedBooksTable).go();
      await delete(usersTable).go();
    });
  }

  // ===========================================================================
  // USERS DAO METHODS
  // ===========================================================================

  Future<void> insertUser(UserEntry user) async {
    await into(usersTable).insert(user);
  }

  Future<UserEntry?> getUserById(String id) async {
    return (select(usersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<UserEntry?> getUserByFirebaseUid(String firebaseUid) async {
    return (select(usersTable)..where((t) => t.firebaseUid.equals(firebaseUid)))
        .getSingleOrNull();
  }

  Future<void> updateLastLogin(String usersId) async {
    await (update(usersTable)..where((t) => t.id.equals(usersId))).write(
      UsersTableCompanion(
        lastLoginAt: Value(DateTime.now()),
        syncedWithFirestore: const Value(false),
      ),
    );
  }

  // ===========================================================================
  // SAVED BOOKS DAO METHODS
  // ===========================================================================

  Future<void> insertBook(SavedBookEntry book) async {
    await into(savedBooksTable).insert(book);
  }

  Future<void> upsertBook(SavedBookEntry book) async {
    await into(savedBooksTable).insertOnConflictUpdate(book);
  }

  Future<SavedBookEntry?> getBookById(String id) async {
    return (select(savedBooksTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<SavedBookEntry>> getUserBooks(String usersId) async {
    return (select(savedBooksTable)
          ..where((t) => t.userId.equals(usersId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastReadAt)]))
        .get();
  }

  Stream<List<SavedBookEntry>> watchUserBooks(String usersId) {
    return (select(savedBooksTable)
          ..where((t) => t.userId.equals(usersId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastReadAt)]))
        .watch();
  }

  Future<void> updateBookLastPage(String bookId, int pageIndex) async {
    await (update(savedBooksTable)..where((t) => t.id.equals(bookId))).write(
      SavedBooksTableCompanion(
        lastPageIndex: Value(pageIndex),
        lastReadAt: Value(DateTime.now()),
        syncedWithFirestore: const Value(false),
      ),
    );
  }

  Future<void> deleteBook(String id) async {
    await (delete(savedBooksTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<SavedBookEntry>> getUnsyncedBooks(String usersId) async {
    return (select(savedBooksTable)
          ..where((t) =>
              t.userId.equals(usersId) & t.syncedWithFirestore.equals(false)))
        .get();
  }

  Future<void> markBookSynced(String bookId) async {
    await (update(savedBooksTable)..where((t) => t.id.equals(bookId))).write(
      SavedBooksTableCompanion(
        syncedWithFirestore: const Value(true),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ===========================================================================
  // READING PROGRESS DAO METHODS
  // ===========================================================================

  Future<void> initializeProgress(String id, String bookId) async {
    final now = DateTime.now();
    await into(readingProgressTable).insert(
      ReadingProgressTableCompanion.insert(
        id: id,
        bookId: bookId,
        lastReadTimestamp: now,
        createdAt: now,
      ),
    );
  }

  Future<ReadingProgressEntry?> getProgress(String bookId) async {
    return (select(readingProgressTable)..where((t) => t.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Stream<ReadingProgressEntry?> watchProgress(String bookId) {
    return (select(readingProgressTable)..where((t) => t.bookId.equals(bookId)))
        .watchSingleOrNull();
  }

  Future<void> updatePageIndex(String bookId, int pageIndex) async {
    await (update(readingProgressTable)..where((t) => t.bookId.equals(bookId)))
        .write(
      ReadingProgressTableCompanion(
        currentPageIndex: Value(pageIndex),
        lastReadTimestamp: Value(DateTime.now()),
        syncedWithFirestore: const Value(false),
      ),
    );
  }

  Future<void> updateAudioState(
      String bookId, int positionMs, int wordIndex) async {
    await (update(readingProgressTable)..where((t) => t.bookId.equals(bookId)))
        .write(
      ReadingProgressTableCompanion(
        lastAudioPositionMs: Value(positionMs),
        lastWordIndex: Value(wordIndex),
        lastReadTimestamp: Value(DateTime.now()),
        syncedWithFirestore: const Value(false),
      ),
    );
  }

  // ===========================================================================
  // READER SETTINGS DAO METHODS
  // ===========================================================================

  Future<void> initializeSettings(String id, String usersId) async {
    await into(readerSettingsTable).insert(
      ReaderSettingsTableCompanion.insert(
        id: id,
        userId: usersId,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<ReaderSettingsEntry?> getSettings(String usersId) async {
    return (select(readerSettingsTable)..where((t) => t.userId.equals(usersId)))
        .getSingleOrNull();
  }

  Stream<ReaderSettingsEntry?> watchSettings(String usersId) {
    return (select(readerSettingsTable)..where((t) => t.userId.equals(usersId)))
        .watchSingleOrNull();
  }

  Future<void> updateReaderSettings(ReaderSettingsEntry settings) async {
    await update(readerSettingsTable).replace(settings);
  }

  // ===========================================================================
  // BOOKMARKS DAO METHODS
  // ===========================================================================

  Future<void> createBookmark(BookmarkEntry bookmark) async {
    await into(bookmarksTable).insert(bookmark);
  }

  Future<List<BookmarkEntry>> getBookBookmarks(String bookId) async {
    return (select(bookmarksTable)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .get();
  }

  Stream<List<BookmarkEntry>> watchBookBookmarks(String bookId) {
    return (select(bookmarksTable)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .watch();
  }

  Future<void> deleteBookmark(String id) async {
    await (delete(bookmarksTable)..where((t) => t.id.equals(id))).go();
  }

  // ===========================================================================
  // HIGHLIGHTS DAO METHODS
  // ===========================================================================

  Future<void> createHighlight(HighlightEntry highlight) async {
    await into(highlightsTable).insert(highlight);
  }

  Future<List<HighlightEntry>> getBookHighlights(String bookId) async {
    return (select(highlightsTable)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.pageIndex),
            (t) => OrderingTerm.asc(t.startCharIndex),
          ]))
        .get();
  }

  Future<List<HighlightEntry>> getPageHighlights(
      String bookId, int pageIndex) async {
    return (select(highlightsTable)
          ..where(
              (t) => t.bookId.equals(bookId) & t.pageIndex.equals(pageIndex))
          ..orderBy([(t) => OrderingTerm.asc(t.startCharIndex)]))
        .get();
  }

  Stream<List<HighlightEntry>> watchBookHighlights(String bookId) {
    return (select(highlightsTable)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.pageIndex),
            (t) => OrderingTerm.asc(t.startCharIndex),
          ]))
        .watch();
  }

  Future<void> deleteHighlight(String id) async {
    await (delete(highlightsTable)..where((t) => t.id.equals(id))).go();
  }

  // ===========================================================================
  // TTS CACHE METADATA DAO METHODS
  // ===========================================================================

  Future<void> insertCacheMetadata(TtsCacheMetadataEntry metadata) async {
    await into(ttsCacheMetadataTable).insert(metadata);
  }

  Future<bool> isAudioCached(
      String bookId, int pageIndex, String voiceId) async {
    final result = await (select(ttsCacheMetadataTable)
          ..where((t) =>
              t.bookId.equals(bookId) &
              t.pageIndex.equals(pageIndex) &
              t.voiceId.equals(voiceId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<int> getTotalCacheSize() async {
    final sum = ttsCacheMetadataTable.sizeBytes.sum();
    final query = selectOnly(ttsCacheMetadataTable)..addColumns([sum]);
    final result = await query.getSingle();
    return result.read(sum) ?? 0;
  }

  Future<List<TtsCacheMetadataEntry>> getOldestCacheEntries(int limit) async {
    return (select(ttsCacheMetadataTable)
          ..orderBy([(t) => OrderingTerm.asc(t.lastAccessedAt)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteCacheMetadata(String id) async {
    await (delete(ttsCacheMetadataTable)..where((t) => t.id.equals(id))).go();
  }

  // ===========================================================================
  // SYNC QUEUE DAO METHODS
  // ===========================================================================

  Future<void> enqueueSyncOperation(SyncQueueEntry entry) async {
    await into(syncQueueTable).insert(entry);
  }

  Future<List<SyncQueueEntry>> getPendingSyncOperations() async {
    return (select(syncQueueTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markSyncOperationSynced(String id) async {
    await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      const SyncQueueTableCompanion(
        status: Value('synced'),
      ),
    );
  }

  Future<void> markSyncOperationFailed(String id) async {
    await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      const SyncQueueTableCompanion(
        status: Value('failed'),
      ),
    );
  }

  Future<void> clearSyncedOperations() async {
    await (delete(syncQueueTable)..where((t) => t.status.equals('synced')))
        .go();
  }

  Future<int> getPendingSyncCount() async {
    final count = countAll();
    final query = selectOnly(syncQueueTable)
      ..where(syncQueueTable.status.equals('pending'))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}

/// Opens a connection to the SQLite database.
/// Uses drift_flutter which automatically handles:
/// - Native platforms: SQLite via FFI
/// - Web: SQLite compiled to WASM (IndexedDB storage)
QueryExecutor _openConnection() {
  // drift_flutter handles platform detection automatically
  // On web, it will use sqlite3_web with WASM
  return driftDatabase(
    name: 'sonant_database',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

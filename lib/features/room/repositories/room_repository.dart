import '../models/room_model.dart';

/// Oda repository arayüzü.
///
/// Developer 2 (Room Management) bu arayüzü implemente eder.
/// Test için mock implementasyon kolayca yazılabilir.
abstract interface class IRoomRepository {
  /// Yeni oda oluşturur.
  /// Döner: Oluşturulan [RoomModel]
  Future<RoomModel> createRoom({
    required String name,
    required List<String> memberNames,
  });

  /// Oda koduna göre odayı getirir.
  /// Throws: [NotFoundException] eğer oda bulunamazsa
  Future<RoomModel> getRoomByCode(String code);

  /// Oda ID'sine göre odayı getirir.
  Future<RoomModel> getRoomById(String id);

  /// Odaya yeni üye ekler.
  Future<MemberModel> addMember({
    required String roomId,
    required String name,
  });

  /// Oda kodunun mevcut olup olmadığını kontrol eder.
  Future<bool> roomExists(String code);
}

/// Oda repository implementasyonu.
///
/// TODO [Developer 2]: Supabase sorgularını implement edin.
///   - rooms tablosuna INSERT (createRoom)
///   - rooms tablosundan SELECT WHERE code = ? (getRoomByCode)
///   - room_members tablosuna INSERT (addMember)
///   - rooms tablosundan COUNT WHERE code = ? (roomExists)
///
/// Supabase client erişimi için SupabaseService.client kullanın.
/// Hata yönetimi için try/catch ve RepositoryException kullanın.
class RoomRepository implements IRoomRepository {
  const RoomRepository();

  @override
  Future<RoomModel> createRoom({
    required String name,
    required List<String> memberNames,
  }) async {
    // TODO [Developer 2]: Uygulama adımları:
    //   1. RoomCodeGenerator.generate() ile benzersiz kod üret
    //   2. roomExists() ile kodun benzersizliğini doğrula
    //   3. rooms tablosuna INSERT yap
    //   4. Her memberName için room_members tablosuna INSERT yap
    //   5. İlişkili üyelerle birlikte RoomModel döndür
    throw UnimplementedError('createRoom henüz implementasyonu yapılmadı.');
  }

  @override
  Future<RoomModel> getRoomByCode(String code) async {
    // TODO [Developer 2]: Uygulama adımları:
    //   1. rooms tablosundan SELECT WHERE code = ? yap
    //   2. room_members JOIN ile üyeleri de getir
    //   3. RoomModel.fromJson() ile dönüştür
    //   4. Bulunamazsa NotFoundException fırlat
    throw UnimplementedError('getRoomByCode henüz implementasyonu yapılmadı.');
  }

  @override
  Future<RoomModel> getRoomById(String id) async {
    // TODO [Developer 2]: Uygulama adımları:
    //   1. rooms tablosundan SELECT WHERE id = ? yap
    //   2. room_members JOIN ile üyeleri de getir
    //   3. RoomModel.fromJson() ile dönüştür
    throw UnimplementedError('getRoomById henüz implementasyonu yapılmadı.');
  }

  @override
  Future<MemberModel> addMember({
    required String roomId,
    required String name,
  }) async {
    // TODO [Developer 2]: Uygulama adımları:
    //   1. room_members tablosuna INSERT yap (uuid ile yeni ID)
    //   2. MemberModel.fromJson() ile dönüştür
    throw UnimplementedError('addMember henüz implementasyonu yapılmadı.');
  }

  @override
  Future<bool> roomExists(String code) async {
    // TODO [Developer 2]: rooms tablosundan COUNT WHERE code = ? yap
    throw UnimplementedError('roomExists henüz implementasyonu yapılmadı.');
  }
}

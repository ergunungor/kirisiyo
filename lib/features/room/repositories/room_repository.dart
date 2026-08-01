import 'package:kirisiyo/core/constants/app_constants.dart';

import '../../../core/services/base_repository.dart';
import '../../../core/utils/room_code_generator.dart';
import '../models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase nesnesi için

/// Oda repository arayüzü.
///
/// Developer 2 (Room Management) bu arayüzü implemente eder.
/// Test için mock implementasyon kolayca yazılabilir.
abstract interface class IRoomRepository {
  Future<RoomModel> createRoom({
    required String name,
    required List<String> memberNames,
  });

  Future<RoomModel> getRoomByCode(String code);

  Future<RoomModel> getRoomById(String id);

  Future<MemberModel> addMember({
    required String roomId,
    required String name,
  });

  Future<bool> roomExists(String code);
}

/// Oda repository implementasyonu.
///
/// Supabase client erişimi [BaseRepository.client] üzerinden yapılır.
base class RoomRepository extends BaseRepository implements IRoomRepository {
  const RoomRepository();

  static const _roomsTable = 'rooms';
  static const _membersTable = 'room_members';

  @override
  Future<RoomModel> createRoom({
    required String name,
    required List<String> memberNames,
  }) async {
    try {
      // Benzersiz kod üretme metodumuzu çağırıyoruz
      final code = await _generateUniqueCode();

      final roomResponse = await client
          .from(_roomsTable)
          .insert({'room_code': code, 'room_name': name})
          .select()
          .single();

      final room = RoomModel.fromJson(roomResponse);

      final memberRows = memberNames
          .map((memberName) => {'room_id': room.id, 'name': memberName})
          .toList();

      final membersResponse =
          await client.from(_membersTable).insert(memberRows).select();

      final members = (membersResponse as List)
          .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
          .toList();

      return room.copyWith(members: members);
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw BackendException('Oda oluşturulurken bir hata oluştu: $e');
    }
  }

  @override
  Future<RoomModel> getRoomByCode(String code) async {
    try {
      final response = await client
          .from(_roomsTable)
          .select('*, room_members(*)')
          .eq('room_code', code)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException('Bu kod ile bir oda bulunamadı.');
      }

      return RoomModel.fromJson(response);
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw BackendException('Oda getirilirken bir hata oluştu: $e');
    }
  }

  @override
  Future<RoomModel> getRoomById(String id) async {
    try {
      final response = await client
          .from(_roomsTable)
          .select('*, room_members(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException('Oda bulunamadı.');
      }

      return RoomModel.fromJson(response);
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw BackendException('Oda getirilirken bir hata oluştu: $e');
    }
  }

  @override
  Future<MemberModel> addMember({
    required String roomId,
    required String name,
  }) async {
    try {
      final response = await client
          .from(_membersTable)
          .insert({'room_id': roomId, 'name': name})
          .select()
          .single();

      return MemberModel.fromJson(response);
    } catch (e) {
      throw BackendException('Katılımcı eklenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<bool> roomExists(String code) async {
    try {
      final response =
          await client.from(_roomsTable).select('id').eq('room_code', code);
      return (response as List).isNotEmpty;
    } catch (e) {
      throw BackendException('Oda kontrol edilirken bir hata oluştu: $e');
    }
  }

  /// Supabase'de benzersiz olan bir oda kodu üretir.
  /// Sonsuz döngüyü engellemek için maksimum 5 deneme yapar.
  Future<String> _generateUniqueCode() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = RoomCodeGenerator.generate();
      final exists = await roomExists(code);
      if (!exists) return code;
    }
    throw const BackendException(
      'Benzersiz oda kodu üretilemedi, lütfen tekrar deneyin.',
    );
  }
}
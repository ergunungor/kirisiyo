import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/validators.dart';

/// Oda yönetimi state enum'u.
enum RoomStatus { idle, loading, success, error }

/// Oda yönetimi provider'ı.
///
/// Developer 2 (Room Management) bu provider'ı yönetir.
///
/// Sorumluluklar:
///   - Oda oluşturma flow'u
///   - Odaya katılma flow'u
///   - Aktif oda/üye state'ini tutmak
///   - Local storage ile session yönetimi
class RoomProvider extends ChangeNotifier {
  RoomProvider({
    IRoomRepository? roomRepository,
  }) : _roomRepository = roomRepository ?? const RoomRepository();

  final IRoomRepository _roomRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  RoomStatus _status = RoomStatus.idle;
  RoomStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == RoomStatus.loading;
  bool get hasError => _status == RoomStatus.error;

  /// Mevcut aktif oda
  RoomModel? _currentRoom;
  RoomModel? get currentRoom => _currentRoom;

  /// Mevcut aktif üye (giriş yapılan kimlik)
  MemberModel? _currentMember;
  MemberModel? get currentMember => _currentMember;

  /// Oda oluşturma flow'unda kullanılacak üye isim listesi
  List<String> _pendingMemberNames = [];
  List<String> get pendingMemberNames => List.unmodifiable(_pendingMemberNames);

  /// Üretilen oda kodu (paylaşım için)
  String? _generatedRoomCode;
  String? get generatedRoomCode => _generatedRoomCode;

  // ── Aksiyon Metodları ────────────────────────────────────────────────────

/// Oda oluşturma flow'unda üye ismi ekler.
  void addMemberName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    if (_pendingMemberNames.length >= AppConstants.maxParticipants) return;

    // Aynı ismin eklenmesini engelleme (Büyük/küçük harf duyarsız)
    final isDuplicate = _pendingMemberNames.any(
      (existing) => existing.toLowerCase() == trimmedName.toLowerCase(),
    );
    
    if (isDuplicate) {
      _setError('Bu isim zaten listeye eklenmiş.');
      return;
    }

    _pendingMemberNames = [..._pendingMemberNames, trimmedName];
    notifyListeners();
  }

  /// Oda oluşturma flow'unda üye ismini kaldırır.
  void removeMemberName(int index) {
    if (index < 0 || index >= _pendingMemberNames.length) return;
    final updated = [..._pendingMemberNames];
    updated.removeAt(index);
    _pendingMemberNames = updated;
    notifyListeners();
  }

  /// Pending üye listesini temizler.
  void clearPendingMembers() {
    _pendingMemberNames = [];
    notifyListeners();
  }

  /// Yeni oda oluşturur.
  Future<void> createRoom({
    required String name,
    required List<String> memberNames,
  }) async {
    _setLoading();

    try {
      final room = await _roomRepository.createRoom(
        name: name,
        memberNames: memberNames,
      );
      _currentRoom = room;
      _generatedRoomCode = room.code;
      await LocalStorageService.setString(
        AppConstants.prefCurrentRoomCode,
        room.code,
      );
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Oda koduna göre odayı yükler.
  Future<void> loadRoomByCode(String code) async {
    _setLoading();

    try {
      final room = await _roomRepository.getRoomByCode(code);
      _currentRoom = room;
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Aktif üyeyi seçer.
Future<void> selectMember(MemberModel member) async {
    _currentMember = member;

    await LocalStorageService.setString(AppConstants.prefCurrentMemberId, member.id);
    notifyListeners();
  }

  /// Provider state'ini sıfırlar.
  void reset() {
    _status = RoomStatus.idle;
    _errorMessage = null;
    _currentRoom = null;
    _currentMember = null;
    _pendingMemberNames = [];
    _generatedRoomCode = null;
    notifyListeners();
  }

  // ── Private Yardımcı Metodlar ─────────────────────────────────────────────

  void _setLoading() {
    _status = RoomStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = RoomStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = RoomStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}

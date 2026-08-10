import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

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
  RoomProvider({IRoomRepository? roomRepository})
    : _roomRepository = roomRepository ?? const RoomRepository();

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

  /// Oda koduna göre odayı yükler ve varsa önceden seçilmiş üyeyi eşleştirir.
  Future<void> loadRoomByCode(String code) async {
    _setLoading();

    try {
      final room = await _roomRepository.getRoomByCode(code);
      _currentRoom = room;

      // ── KRİTİK DÜZELTME: Hafızadaki üye seçimini otomatik yükle ──────
      final savedMemberId = LocalStorageService.getString(
        AppConstants.prefCurrentMemberId,
      );

      if (savedMemberId != null && room.members.isNotEmpty) {
        try {
          _currentMember = room.members.firstWhere(
            (m) => m.id == savedMemberId,
          );
        } catch (_) {
          // Eğer kaydedilen üye o odada yoksa resetle
          _currentMember = null;
        }
      }
      // ─────────────────────────────────────────────────────────────────

      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Aktif üyeyi seçer.
  Future<void> selectMember(MemberModel member) async {
    _currentMember = member;

    await LocalStorageService.setString(
      AppConstants.prefCurrentMemberId,
      member.id,
    );
    notifyListeners();
  }

  Future<void> updateMyPaymentInfo({String? fullName, String? iban}) async {
    if (_currentMember == null) return;

    // _setLoading kullanmıyoruz çünkü ekranın yeniden yüklenmesini (loading spinner) istemiyoruz
    // Sadece veri güncellensin, UI'da reaktif olarak değişsin.
    try {
      await _roomRepository.updateMemberPaymentInfo(
        memberId: _currentMember!.id,
        fullName: fullName,
        iban: iban,
      );

      // 1. Güncel veriyi modelden kopya alarak güncelle
      _currentMember = _currentMember!.copyWith(fullName: fullName, iban: iban);

      // 2. Odanın içindeki üyeyi de bul ve güncelle (Önemli!)
      if (_currentRoom != null) {
        final updatedMembers =
            _currentRoom!.members.map((m) {
              if (m.id == _currentMember!.id) {
                return m.copyWith(fullName: fullName, iban: iban);
              }
              return m;
            }).toList();

        _currentRoom = _currentRoom!.copyWith(members: updatedMembers);
      }

      notifyListeners(); // Arayüzün güncellenmesini tetikleyelim
    } catch (e) {
      // Hata durumunda sessiz kalabiliriz veya log atabiliriz
      debugPrint('Ödeme bilgisi güncellenemedi: $e');
    }
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

  /// Odadan çıkar: local session bilgisini temizler ve state'i sıfırlar.
  Future<void> leaveRoom() async {
    await LocalStorageService.remove(AppConstants.prefCurrentRoomCode);
    await LocalStorageService.remove(AppConstants.prefCurrentMemberId);
    reset();
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

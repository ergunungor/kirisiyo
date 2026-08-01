import 'package:equatable/equatable.dart';

/// Oda modeli.
///
/// Supabase [rooms] tablosuyla eşleşir.
/// Developer 2 (Room Management) bu modeli yönetir.
class RoomModel extends Equatable {
  const RoomModel({
    required this.id,
    required this.code,
    required this.name,
    required this.createdAt,
    this.members = const [],
  });

  final String id;

  /// 6 karakterli benzersiz oda kodu.
  final String code;

  final String name;
  final DateTime createdAt;
  final List<MemberModel> members;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      code: json['room_code'] as String,
      name: json['room_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      members: (json['room_members'] as List<dynamic>?)
              ?.map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_code': code,
      'room_name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  RoomModel copyWith({
    String? id,
    String? code,
    String? name,
    DateTime? createdAt,
    List<MemberModel>? members,
  }) {
    return RoomModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [id, code, name, createdAt, members];

  @override
  String toString() => 'RoomModel(code: $code, name: $name)';
}

/// Oda üyesi modeli.
///
/// Supabase [room_members] tablosuyla eşleşir.
/// Developer 2 (Room Management) bu modeli yönetir.
class MemberModel extends Equatable {
  const MemberModel({
    required this.id,
    required this.roomId,
    required this.name,
    required this.joinedAt,
  });

  final String id;
  final String roomId;
  final String name;
  final DateTime joinedAt;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      name: json['name'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'name': name,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  MemberModel copyWith({
    String? id,
    String? roomId,
    String? name,
    DateTime? joinedAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [id, roomId, name, joinedAt];

  @override
  String toString() => 'MemberModel(name: $name)';
}

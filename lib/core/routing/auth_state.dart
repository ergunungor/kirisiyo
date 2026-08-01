import 'package:flutter/foundation.dart';

/// Geçici iskelet — Supabase entegrasyonu tamamlanınca
/// buradaki değerler gerçek oturum/üyelik bilgisinden dolacak.
/// ŞU AN İÇİN sadece route guard'ın nasıl çalışacağını
/// test edebilmek amacıyla var.
class AuthState extends ChangeNotifier {
  bool _isMemberOfCurrentRoom = false;

  bool get isMemberOfCurrentRoom => _isMemberOfCurrentRoom;

  void setMembership(bool value) {
    _isMemberOfCurrentRoom = value;
    notifyListeners();
  }
}
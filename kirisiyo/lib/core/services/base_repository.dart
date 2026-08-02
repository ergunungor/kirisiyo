import '../../core/services/supabase_service.dart';

/// Repository base exception.
sealed class RepositoryException implements Exception {
  const RepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Ağ hatası
class NetworkException extends RepositoryException {
  const NetworkException([
    super.message = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.',
  ]);
}

/// Bulunamadı hatası
class NotFoundException extends RepositoryException {
  const NotFoundException([super.message = 'Kayıt bulunamadı.']);
}

/// Genel backend hatası
class BackendException extends RepositoryException {
  const BackendException([super.message = 'Sunucu hatası oluştu.']);
}

/// Repository interface için temel sınıf.
///
/// Tüm repository'ler bu sınıftan türetilir.
/// Supabase client erişimi için [client] kullanın.
abstract base class BaseRepository {
  const BaseRepository();

  /// Supabase istemcisi.
  get client => SupabaseService.client;
}

# Kırışıyo — Geliştirici Kılavuzu

> Tricount/Splitwise tarzı harcama paylaşım uygulaması  
> Flutter Web + PWA | Supabase | Firebase Hosting

---

## 🏗️ Proje Mimarisi

```
lib/
├── main.dart                   # Uygulama giriş noktası
├── app/
│   ├── app.dart                # KirisiyoApp (MultiProvider + MaterialApp.router)
│   ├── router.dart             # GoRouter — tüm rotalar
│   ├── app_colors.dart         # Renk paleti
│   ├── app_spacing.dart        # Boşluk ve boyut sistemi
│   ├── app_text_styles.dart    # Tipografi sistemi
│   └── app_theme.dart          # Material 3 dark tema
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── local_storage_service.dart
│   │   └── base_repository.dart
│   ├── utils/
│   │   ├── formatters.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_text_field.dart
│       ├── loading_widget.dart
│       └── state_widgets.dart
├── shared/
│   └── widgets/
│       └── shared_widgets.dart  # MemberAvatar, AmountDisplay, AppScaffold
└── features/
    ├── splash/                 # Developer 1
    ├── home/                   # Developer 1
    ├── room/                   # Developer 2
    ├── expense/                # Developer 3
    ├── receipt_scanner/        # Developer 4
    └── balance/                # Developer 5
```

---

## 👥 Takım Görev Dağılımı

| Developer | Alan | Dosyalar |
|---|---|---|
| Dev 1 | Frontend Lead & Mimari | `app/`, `core/`, `shared/` |
| Dev 2 | Oda Yönetimi | `features/room/` |
| Dev 3 | Harcama Yönetimi | `features/expense/` |
| Dev 4 | AI Fiş Tarayıcı | `features/receipt_scanner/` |
| Dev 5 | Backend & Bakiye Motoru | `features/balance/`, `database/` |

---

## 🚀 Başlarken

### Kurulum

```bash
cd kirisiyo_app
flutter pub get
flutter run -d chrome
```

### Supabase Kurulumu (Developer 5)

1. [supabase.com](https://supabase.com) üzerinde yeni proje oluşturun
2. `database/database_schema.sql` dosyasını SQL Editor'da çalıştırın
3. `lib/core/services/supabase_service.dart` dosyasına URL ve Anon Key ekleyin
4. `lib/main.dart` içinde `SupabaseService.initialize()` satırını uncomment edin

### Firebase Hosting Deploy (Developer 1)

```bash
flutter build web --release
npx -y firebase-tools@latest deploy --only hosting
```

---

## 📡 Routing Tablosu

| Rota | Ekran |
|---|---|
| `/` | SplashScreen |
| `/home` | HomeScreen |
| `/room/create` | CreateRoomScreen |
| `/room/join` | JoinRoomScreen |
| `/room/:code/select-member` | SelectMemberScreen |
| `/room/:code` | RoomDetailScreen |
| `/room/:code/expenses` | ExpensesScreen |
| `/room/:code/expenses/add` | AddExpenseScreen |
| `/room/:code/expenses/scan` | ReceiptScannerScreen |
| `/room/:code/expenses/:id` | ExpenseDetailsScreen |
| `/room/:code/balances` | BalancesScreen |

---

## 🎨 Tasarım Sistemi

```dart
// Renkler
AppColors.primary        // #6C63FF — Mor
AppColors.secondary      // #00D4AA — Turkuaz
AppColors.backgroundDark // #0F0E1A — Arka plan
AppColors.debtRed        // #FF5A7E — Borç
AppColors.creditGreen    // #2ECC71 — Alacak

// Boşluklar
AppSpacing.xs / sm / md / lg / xl / xxl

// Ortak Widget'lar
AppButton | AppTextField | AppCard
LoadingWidget | ErrorStateWidget | EmptyStateWidget
MemberAvatar | AmountDisplay | AppScaffold
```

---

## ✅ TODO Özeti

> `grep -r "TODO" lib/` komutu ile tüm TODO'ları bulabilirsiniz.

**Developer 2:** `RoomRepository` tüm metodları  
**Developer 3:** `ExpenseRepository` tüm metodları + AddExpense split UI  
**Developer 4:** `OcrService` + `ReceiptParser` + `ImagePickerService`  
**Developer 5:** `BalanceRepository` + Simplify Debts algoritması + Supabase setup

---

*Kırışıyo — Harcamaları paylaşmak hiç bu kadar kolay olmamıştı.*

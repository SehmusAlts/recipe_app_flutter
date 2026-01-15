# Recipe App Flutter

Flutter ile geliştirilmiş mobil yemek tarifi uygulaması. MySQL veritabanı kullanarak kullanıcı kayıt/giriş, tarif yönetimi, favoriler ve puanlama özelliklerini içerir.

## Özellikler

- ✅ Kullanıcı kayıt ve giriş sistemi
- ✅ Tarif görüntüleme ve detay sayfası
- ✅ Kategori bazlı filtreleme
- ✅ Favorilere ekleme/çıkarma
- ✅ Tarif puanlama sistemi
- ✅ Kendi tariflerini ekleme/düzenleme/silme
- ✅ Modern ve kullanıcı dostu arayüz
- ✅ MySQL veritabanı entegrasyonu

## Teknolojiler

- **Flutter** - Mobil uygulama framework'ü
- **MySQL** - Veritabanı
- **Provider** - State management
- **mysql_client** - MySQL bağlantı kütüphanesi

## Kurulum

1. Projeyi klonlayın:
```bash
git clone https://github.com/SehmusAlts/recipe_app_flutter.git
cd recipe_app_flutter
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. MySQL veritabanını kurun:
   - MySQL Workbench'te `database_schema.sql` dosyasını çalıştırın
   - `lib/config/database_config.dart` dosyasındaki veritabanı bağlantı bilgilerini güncelleyin

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Veritabanı Yapılandırması

`lib/config/database_config.dart` dosyasında veritabanı bağlantı bilgilerini güncelleyin:

```dart
static const host = '10.0.2.2'; // Android emülatör için
static const port = 3306;
static const user = 'recipe_user';
static const password = 'GüçlüBirŞifre';
static const database = 'flutter_app';
```

**Not:** Android emülatör kullanıyorsanız, host olarak `10.0.2.2` kullanın. Fiziksel cihaz için bilgisayarınızın IP adresini kullanın.

## Proje Yapısı

```
lib/
├── config/          # Veritabanı yapılandırması
├── models/          # Veri modelleri
├── providers/       # State management
├── screens/         # Ekranlar
├── services/        # Veritabanı servisleri
└── widgets/         # Yeniden kullanılabilir widget'lar
```

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

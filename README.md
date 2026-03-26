# BookEase

Bu repo, BookEase case study'si için hazırlanmış bir randevu / rezervasyon sistemi projesi.

Teknolojiler:

- Backend: `ASP.NET Core 8 Web API`
- Veritabanı: `PostgreSQL`
- Cache: `Redis`
- Frontend: `Flutter Web`
- Auth: `JWT Access + Refresh Token`

Kısaca sistem şu işi yapıyor:

- İşletme sahibi işletme açıyor
- İşletmesine hizmet ekliyor
- Hizmet için slot oluşturuyor
- Müşteri aktif işletmeleri ve uygun slotları görüyor
- Müşteri rezervasyon oluşturuyor veya iptal ediyor
- İşletme sahibi gelen rezervasyonları onaylıyor / iptal ediyor

Projede case dokümanındaki 2 ana rol (`customer`, `business_owner`) var. Buna ek olarak pratik kullanım için `admin` rolü de eklendi.

## Proje Yapısı

Repo iki ana parçadan oluşuyor:

- `backend/BookEase.API`
- `frontend/bookease_app`

### Backend tarafında

- JWT auth var
- refresh token desteği var
- Entity Framework Core kullanılıyor
- PostgreSQL'e yazıyor
- Redis ile bazı veriler cache'leniyor
- Swagger açık
- hata yönetimi middleware ile merkezi şekilde yapılıyor

### Frontend tarafında

- Flutter Web kullanıldı
- state yönetimi için `Riverpod`
- routing için `GoRouter`
- HTTP istekleri için `Dio`
- token saklama için `flutter_secure_storage`
- rol bazlı ekran ve navigation yapısı var

## Veri Modeli

Projede temel olarak şu entity'ler var:

- `User`
- `Business`
- `Service`
- `Slot`
- `Booking`

Kısaca ilişkiler:

- Bir `User`, birden fazla `Business` sahibi olabilir
- Bir `Business`, birden fazla `Service` içerebilir
- Bir `Service`, birden fazla `Slot` içerebilir
- Bir `Slot`, birden fazla `Booking` alabilir

## Roller

### Customer

Customer tarafında şu akışlar var:

- giriş / kayıt
- işletme listesi
- işletme detayı
- hizmete göre slot listeleme
- rezervasyon oluşturma
- rezervasyonlarımı filtreleyerek görme
- rezervasyon iptal etme
- profil ekranı

### BusinessOwner

Business owner tarafında:

- kendi işletmelerini görme
- işletme oluşturma
- hizmet ekleme
- hizmet silme
- slot oluşturma
- kendi işletmesine gelen rezervasyonları görme
- rezervasyon onaylama / iptal etme
- profil ekranı

### Admin

Admin tarafı case dokümanında zorunlu değildi ama projeye eklendi.

Şu işlemler yapılabiliyor:

- `Customer` oluşturma
- `BusinessOwner` oluşturma
- `Admin` oluşturma
- işletme oluşturma
- tüm işletmeleri listeleme
- işletme yönetim ekranına girme
- hizmet ekleme / silme
- slot oluşturma
- seçili işletmenin rezervasyonlarını görme

Not:

Backend'de admin için kullanıcı listeleyen ayrı bir endpoint olmadığı için admin işletme oluştururken `BusinessOwner ID` bilgisini manuel giriyor. Admin paneli yeni owner oluşturunca ID bilgisini ekranda gösteriyor.

## Ekranlar

Frontend tarafında şu ekranlar mevcut:

- `LoginScreen`
- `RegisterScreen`
- `BusinessListScreen`
- `BusinessDetailScreen`
- `SlotListScreen`
- `CreateBookingScreen`
- `MyBookingsScreen`
- `ProfileScreen`
- `MyBusinessesScreen`
- `ManageBusinessScreen`
- `BusinessBookingsScreen`
- `OwnerBookingsScreen`
- `AdminHomeScreen`
- `AdminBusinessesScreen`

## API Özeti

Ana endpoint grupları şunlar:

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/create-admin`

### Business

- `GET /api/businesses`
- `GET /api/businesses/{id}`
- `POST /api/businesses`
- `PUT /api/businesses/{id}`
- `DELETE /api/businesses/{id}`

### Service

- `GET /api/businesses/{businessId}/services`
- `POST /api/businesses/{businessId}/services`
- `PUT /api/businesses/{businessId}/services/{id}`
- `DELETE /api/businesses/{businessId}/services/{id}`

### Slot

- `GET /api/services/{serviceId}/slots`
- `POST /api/services/{serviceId}/slots`
- `POST /api/services/{serviceId}/slots/bulk`
- `DELETE /api/services/{serviceId}/slots/{id}`

### Booking

- `POST /api/bookings`
- `PUT /api/bookings/{id}/confirm`
- `PUT /api/bookings/{id}/cancel`
- `GET /api/bookings/my`
- `GET /api/businesses/{businessId}/bookings`

## Case Gereksinimleri Karşılandı mı?

Case dosyasına göre hızlı durum özeti:

### Zorunlu maddeler

`1. Auth — Kayıt, Giriş, Token Yenileme`

- tamamlandı
- register / login / refresh var
- şifre hashleme `BCrypt` ile yapılıyor

`2. İşletme & Hizmet Yönetimi (CRUD)`

- büyük ölçüde tamamlandı
- işletme oluşturma / güncelleme / silme backend'de var
- hizmet oluşturma / güncelleme / silme backend'de var
- frontend'de oluşturma ve silme akışı aktif
- hizmet güncelleme ekranı ayrı olarak yapılmadı

`3. Slot Yönetimi`

- tamamlandı
- slot oluşturma var
- slot listeleme var
- slot silme backend'de var
- dolu slotlar frontend'de görünüyor ama tıklanamıyor

`4. Rezervasyon — Oluşturma & İptal`

- tamamlandı
- müşteri rezervasyon oluşturabiliyor
- kapasite doluysa hata dönüyor
- müşteri kendi rezervasyonunu iptal edebiliyor
- işletme sahibi rezervasyonu onaylayabiliyor / iptal edebiliyor
- iptal soft durum güncellemesi olarak tutuluyor

`5. Rezervasyon Listeleme (filtreli, sayfalı)`

- büyük ölçüde tamamlandı
- müşteri kendi rezervasyonlarını durum filtresiyle görebiliyor
- müşteri tarafında pagination var
- işletme sahibi işletmeye gelen rezervasyonları görebiliyor
- backend tarafında business bookings endpoint'i page/pageSize destekli
- tarih aralığı filtresi backend'de var ama frontend'de ayrı tarih aralığı UI'ı yapılmadı

`6. Flutter — Temel Ekranlar & State Yönetimi`

- tamamlandı
- login/register ekranları var
- işletme listesi / detay ekranı var
- slot listesi ve tarih seçici var
- rezervasyon oluşturma ekranı var
- rezervasyonlarım ekranı filtreli çalışıyor
- state yönetimi `Riverpod`
- token yönetimi var, oturum korunuyor

### Bonus maddeler

`7. SignalR`

- yapılmadı

`8. Redis Cache`

- yapıldı
- işletme listesi ve slot listesi cache kullanıyor
- rezervasyon / slot değişimlerinde cache temizleniyor

`9. Raporlama & Grafik`

- yapılmadı

## Kendi Gözümden Eksik Kalanlar

Dürüst liste:

- hizmet güncelleme ekranı ayrı olarak yok
- slot silme frontend'de ayrı butonla açılmadı
- business owner için tarih aralıklı rezervasyon filtre UI'ı eklenmedi
- SignalR yapılmadı
- raporlama / grafik yapılmadı
- automated test sayısı çok az, özellikle backend testleri yok
- admin için kullanıcı listeleme endpoint'i olmadığı için bazı admin akışları biraz manuel kaldı

## Neden Bu Yapıyı Tercih Ettim?

Bu yapıyı seçme nedenlerim:

- Backend ve frontend'i ayırmak daha temiz oldu
- `Service` katmanı ile controller'ları kalabalık yapmamış oldum
- `Riverpod` ile auth ve veri akışını daha rahat yönettim
- `GoRouter` ile rol bazlı yönlendirme kolaylaştı
- `Dio` interceptor ile token yenileme akışını tek yere topladım
- Redis'i özellikle işletme listesi ve slot listesi gibi sık okunan yerlerde kullanmak mantıklıydı

Çok büyük bir enterprise mimari kurmaya çalışmadım. Case için anlaşılır ve geliştirmesi rahat bir yapı hedefledim.

## Kurulum

### Gerekenler

Makinede şunlar olmalı:

- `.NET 8 SDK`
- `Flutter SDK`
- `Chrome`
- `PostgreSQL`
- `Redis`

İsteğe bağlı:

- `dotnet-ef`

## Backend'i Ayağa Kaldırma

Önce örnek config'ten kendi config'ini oluştur:

```bash
cp backend/BookEase.API/appsettings.Example.json backend/BookEase.API/appsettings.json
```

Sonra şu alanları doldur:

- `ConnectionStrings:DefaultConnection`
- `ConnectionStrings:Redis`
- `Jwt:SecretKey`
- `SeedAdmin`

Migration'ı çalıştır:

```bash
dotnet ef database update --project backend/BookEase.API/BookEase.API.csproj
```

API'yi başlat:

```bash
dotnet run --project backend/BookEase.API/BookEase.API.csproj --launch-profile http
```

Beklenen adres:

```text
http://localhost:5154
```

Swagger development ortamında açık.

## Frontend'i Ayağa Kaldırma

```bash
cd frontend/bookease_app
flutter pub get
flutter run -d chrome
```

Frontend şu API adresine bağlı:

```text
http://localhost:5154/api
```

## Auth ve Session Notu

- access token ve refresh token kullanılıyor
- frontend token'ı secure storage'a yazıyor
- uygulama tekrar açıldığında oturum korunuyor
- `401` gelirse refresh deneniyor
- refresh başarısızsa kullanıcı login ekranına dönüyor

## Cache Notu

Redis şu alanlarda kullanılıyor:

- aktif işletme listesi
- servis bazlı slot listesi

Şu durumlarda cache temizleniyor:

- işletme değişirse
- slot oluşursa / silinirse
- rezervasyon oluşursa / iptal olursa

## Hata Yönetimi

Backend'de merkezi exception middleware var.

Dönen hata yapısı şu şekilde:

```json
{
  "status": 409,
  "error": "Slot is fully booked."
}
```

## Proje Ağacı

```text
.
├── backend/
│   └── BookEase.API/
│       ├── Controllers/
│       ├── DTOs/
│       ├── Data/
│       ├── Middleware/
│       ├── Migrations/
│       ├── Models/
│       ├── Services/
│       ├── appsettings.Example.json
│       └── Program.cs
├── frontend/
│   └── bookease_app/
│       ├── lib/
│       │   ├── core/
│       │   ├── models/
│       │   ├── providers/
│       │   ├── screens/
│       │   └── widgets/
│       ├── test/
│       ├── web/
│       └── pubspec.yaml
└── book_ease_test_case.sln
```

## Doğrulama

Frontend tarafında şu komutlar çalıştırıldı:

```bash
flutter analyze
flutter test
flutter test --platform chrome
```

## Daha Fazla Zaman Olsaydı

Şunları eklerdim:

- SignalR ile slot güncellemelerini canlı yapmak
- dashboard / raporlama ekranı eklemek
- backend için unit/integration test yazmak
- admin için kullanıcı listeleme ve owner seçme ekranı yapmak
- daha iyi form validation ve toast / error UX
- Docker Compose ile tek komutluk local setup

## Son Not

Bence bu proje case study için ana akışı karşılıyor:

- auth var
- refresh token var
- işletme / hizmet / slot / rezervasyon akışı var
- customer ve business owner senaryoları çalışıyor
- Redis bonusu var

Eksikler var ama nerelerde eksik olduğu da net. Bu haliyle okunabilir, geliştirilebilir ve demo verilebilir bir proje oldu.

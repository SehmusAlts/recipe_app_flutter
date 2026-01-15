ANKARA ÜNİVERSİTESİ 
MÜHENDİSLİK FAKÜLTESİ 
BİLGİSAYAR MÜHENDİSLİĞİ BÖLÜMÜ 
(BLM4537-A) IOS ile Mobil Uygulama Geliştirme I Dersi  
Uygulama Dökümanı 
Şehmus Altaş 
20291316 
14/01/2026 
GitHub: GitHub - SehmusAlts/recipe_app_flutter 
Video Link: 
https://drive.google.com/drive/folders/11x3VzP5bWkbFR9eQI6u-SQr4chSl5PnP?usp=shari
ng 
1. GİRİŞ VE PROJE ÖZETİ 
Bu proje kapsamında Flutter kullanılarak geliştirilen Recipe App, kullanıcıların yemek 
tariflerini görüntüleyebildiği, yeni tarifler ekleyebildiği, tarifleri favorilerine alıp 
puanlayabildiği bir mobil uygulamadır. Uygulama hem Android hem de iOS platformlarını 
destekleyecek şekilde cross-platform olarak tasarlanmıştır. 
Uygulamada kullanıcılar kayıt olup giriş yapabilmekte, kendi tariflerini oluşturabilmekte ve 
diğer kullanıcılar tarafından paylaşılan tarifleri inceleyebilmektedir. Tarifler kategori bazlı 
olarak listelenebilmekte, kullanıcılar beğendikleri tarifleri favorilerine ekleyebilmekte ve 1–5 
arası puan vererek değerlendirme yapabilmektedir. Favoriye eklenen tarifler için ayrı bir 
ekran üzerinden erişim sağlanmaktadır. 
Uygulamanın veri yönetimi MySQL tabanlı ilişkisel bir veritabanı üzerinden 
gerçekleştirilmektedir. Kullanıcı bilgileri, tarifler, kategoriler, favoriler ve puanlama verileri 
ilişkisel tablolar halinde tutulmaktadır. Kullanıcı parolaları güvenlik amacıyla SHA-256 hash 
algoritması kullanılarak saklanmaktadır. Oturum yönetimi ise istemci tarafında 
SharedPreferences ile sağlanmaktadır. 
Recipe App, modern mobil uygulama geliştirme yaklaşımlarına uygun olarak katmanlı bir 
mimari ile geliştirilmiş olup, state yönetimi için Provider pattern kullanılmıştır. Bu 
dokümantasyon, uygulamanın mimari yapısını, kullanılan teknolojileri ve temel 
fonksiyonlarını teknik bir bakış açısıyla açıklamayı amaçlamaktadır. 
2. TEKNOLOJİLER VE FRAMEWORK’LER 
Bu projede modern mobil uygulama geliştirme süreçlerine uygun teknolojiler ve 
kütüphaneler kullanılmıştır. Uygulama, performans, sürdürülebilirlik ve platform 
bağımsızlığı göz önünde bulundurularak tasarlanmıştır. 
Flutter ve Dart 
Uygulama, Flutter SDK 3.5.4 kullanılarak geliştirilmiştir. Flutter, tek bir kod tabanı ile Android 
ve iOS platformları için uygulama geliştirmeye olanak sağlamaktadır. Programlama dili 
olarak Dart kullanılmış olup, null-safety özelliklerinden faydalanılmıştır. 
Kullanıcı arayüzü, Material Design 3 tasarım prensiplerine uygun olarak oluşturulmuş ve 
modern bir görünüm hedeflenmiştir. 
State Management 
Uygulamada state yönetimi için Provider pattern kullanılmıştır. 
ChangeNotifier yapısı ile uygulama durumu yönetilmiş, Consumer ve MultiProvider 
kullanılarak sadece gerekli widget’ların yeniden çizilmesi sağlanmıştır. Bu yaklaşım, kodun 
okunabilirliğini artırmış ve performans açısından avantaj sağlamıştır. 
Veritabanı ve Veri Yönetimi 
Uygulamanın veri kalıcılığı MySQL tabanlı ilişkisel veritabanı ile sağlanmıştır. 
Veritabanı bağlantıları mysql_client paketi kullanılarak doğrudan MySQL sunucusuna 
yapılmıştır. Veritabanı işlemleri asenkron olarak async/await yapısı ile gerçekleştirilmiştir. 
SQL sorgularında prepared statements kullanılarak güvenli veri erişimi sağlanmıştır. 
Güvenlik ve Oturum Yönetimi 
Kullanıcı parolaları, SHA-256 hash algoritması kullanılarak şifrelenmiş şekilde 
veritabanında saklanmaktadır. Bu işlem için crypto paketi kullanılmıştır. 
Kullanıcı oturum bilgileri, uygulama kapatılsa dahi korunabilmesi amacıyla 
SharedPreferences kullanılarak cihaz üzerinde saklanmıştır. 
3. MİMARİ TASARIM 
Recipe App, katmanlı ve modüler bir mimari yapı ile geliştirilmiştir. Bu mimari yaklaşım, 
uygulamanın okunabilirliğini artırmak, bakımını kolaylaştırmak ve ileride yapılabilecek 
geliştirmelere uygun bir yapı oluşturmak amacıyla tercih edilmiştir. 
Uygulamada kullanıcı arayüzü, iş mantığı ve veri erişim katmanları birbirinden ayrılmıştır. Bu 
sayede kod tekrarının önüne geçilmiş ve sorumluluklar net bir şekilde ayrıştırılmıştır. 
Proje Klasör Yapısı 
Proje, Flutter için önerilen dosya organizasyonuna uygun olarak aşağıdaki şekilde 
yapılandırılmıştır: 
• config/: Veritabanı ve uygulama yapılandırma dosyaları 
• models/: Uygulamada kullanılan veri modelleri 
• providers/: State yönetimi ve iş mantığı 
• screens/: Kullanıcı arayüzü ekranları 
• services/: Veritabanı ve veri işlemleri 
• widgets/: Yeniden kullanılabilir arayüz bileşenleri 
Bu yapı sayesinde her katman kendi sorumluluğu kapsamında çalışmakta ve uygulama 
genelinde tutarlı bir mimari sağlanmaktadır. 
Provider Pattern 
Uygulamada state yönetimi için Provider pattern kullanılmıştır. 
ChangeNotifier sınıfları aracılığıyla uygulama durumu yönetilmiş ve durum değişiklikleri 
notifyListeners() metodu ile arayüze yansıtılmıştır. Bu yapı, UI ile iş mantığının birbirinden 
ayrılmasını sağlamıştır. 
Repository Pattern 
Veritabanı işlemleri, servis katmanında toplanarak Repository pattern yaklaşımı 
benimsenmiştir. 
MySQL ile ilgili tüm CRUD işlemleri merkezi servis sınıfları üzerinden gerçekleştirilmiştir. Bu 
sayede veri erişimi tek bir noktadan kontrol edilmiştir. 
Model–View–Provider Yapısı 
Uygulamada Model–View–Provider yaklaşımı uygulanmıştır: 
• Model: Veri yapıları (User, Recipe, Category, Rating) 
• View: Kullanıcı arayüzü ekranları 
• Provider: Uygulama durumu ve iş mantığı 
Bu yapı, kodun daha anlaşılır ve yönetilebilir olmasını sağlamıştır. 
Service Layer Pattern 
Veritabanı bağlantıları ve veri işlemleri service layer içerisinde soyutlanmıştır. 
Bu yaklaşım, arayüz ve veri kaynakları arasındaki bağı azaltarak test edilebilirliği artırmıştır. 
Veri Akışı 
Uygulama içerisindeki veri akışı şu şekilde ilerlemektedir: 
UI (Screens) → Provider → Service → MySQL Veritabanı 
Bu akış sayesinde kullanıcı etkileşimleri kontrollü bir şekilde işlenmekte ve veriler güvenli 
biçimde yönetilmektedir. 
4. VERİTABANI TASARIMI 
Uygulamanın veri kalıcılığı için MySQL tabanlı ilişkisel veritabanı kullanılmıştır. Veritabanı 
adı flutter_app olup kullanıcılar, tarifler, kategoriler, favoriler ve puanlamalar ilişkisel 
tablolar üzerinden yönetilmektedir. Tasarımda veri bütünlüğü için foreign key kısıtları ve 
performans için index yapıları kullanılmıştır. 
Tablolar 
users 
Kullanıcı bilgilerini ve giriş verilerini tutar. 
• id (PK, AUTO_INCREMENT) 
• username (UNIQUE) 
• email (UNIQUE) 
• password_hash (SHA-256 çıktısı) 
• full_name (opsiyonel) 
• created_at, updated_at 
categories 
Tarif kategorilerini tutar. 
• id (PK, AUTO_INCREMENT) 
• name (UNIQUE) 
• icon (emoji/ikon) 
• created_at 
Varsayılan kategoriler örnekleri: Kahvaltı, Ana Yemek, Tatlı, İçecek, Salata vb. 
recipes 
Tariflerin ana tablosudur. 
• id (PK, AUTO_INCREMENT) 
• user_id (FK → users.id, ON DELETE CASCADE) 
• category_id (FK → categories.id, ON DELETE SET NULL) 
• title, description, ingredients, instructions 
• prep_time, cook_time, servings, difficulty 
• image_url (opsiyonel) 
• created_at, updated_at 
Performans için: category_id ve user_id alanlarında index kullanılmıştır. 
favorites 
Kullanıcıların favorilediği tarifleri tutar (many-to-many). 
• id (PK, AUTO_INCREMENT) 
• user_id (FK → users.id, ON DELETE CASCADE) 
• recipe_id (FK → recipes.id, ON DELETE CASCADE) 
• created_at 
• UNIQUE (user_id, recipe_id) (aynı tarifin tekrar favorilenmesini engeller) 
ratings 
Tarif puanları ve yorumlarını tutar. 
• id (PK, AUTO_INCREMENT) 
• user_id (FK → users.id, ON DELETE CASCADE) 
• recipe_id (FK → recipes.id, ON DELETE CASCADE) 
• rating (1–5) 
• comment (opsiyonel) 
• created_at, updated_at 
• UNIQUE (user_id, recipe_id) (bir kullanıcı bir tarife tek puan) 
İlişkiler 
• users → recipes: One-to-Many (bir kullanıcı birden fazla tarif ekleyebilir) 
• recipes → categories: Many-to-One (bir tarif bir kategoriye ait olabilir) 
• users ↔ recipes (favorites üzerinden): Many-to-Many 
• users ↔ recipes (ratings üzerinden): Many-to-Many 
Performans ve Veri Bütünlüğü 
• Foreign key kısıtları ile referans bütünlüğü sağlanmıştır. 
• Sık kullanılan alanlarda (user_id, category_id, recipe_id) index kullanılarak sorgu 
performansı artırılmıştır. 
• Ortalama puan gibi değerler, uygulama içinde değil SQL aggregation (AVG, COUNT) 
ile hesaplanacak şekilde tasarlanmıştır. 
• Favori ve puanlamada UNIQUE constraint ile tekrar kayıtlar engellenmiştir. 
5. UYGULAMA ÖZELLİKLERİ VE FONKSİYONLAR 
Uygulamada kullanıcıların sisteme kayıt olabilmesi ve giriş yapabilmesi için bir kimlik 
doğrulama yapısı bulunmaktadır. Kayıt sırasında kullanıcı adı, e-posta ve parola bilgileri 
alınmakta, parolalar SHA-256 algoritması kullanılarak hashlenmiş şekilde veritabanında 
saklanmaktadır. Giriş işlemi sırasında girilen bilgiler doğrulanmakta ve başarılı giriş 
sonrasında kullanıcı oturumu SharedPreferences üzerinden yönetilmektedir. Kullanıcı çıkış 
yaptığında oturum bilgileri temizlenmektedir. 
Tarif yönetimi kapsamında kullanıcılar uygulama içerisindeki tüm tarifleri 
görüntüleyebilmekte, kendi tariflerini oluşturabilmekte, güncelleyebilmekte ve 
silebilmektedir. Tarif oluşturma ve düzenleme işlemleri yalnızca tarifi ekleyen kullanıcı 
tarafından yapılabilmektedir. Tarifler kategori bilgisi, hazırlık ve pişirme süresi, zorluk 
seviyesi ve görsel bağlantısı gibi alanları içermektedir. Veriler MySQL veritabanında 
saklanmakta ve işlemler asenkron olarak gerçekleştirilmektedir. 
Uygulamada favori sistemi bulunmaktadır. Kullanıcılar istedikleri tarifleri favorilerine 
ekleyebilmekte veya favorilerinden çıkarabilmektedir. Favoriye alınan tarifler, kullanıcıya 
özel bir ekranda listelenmektedir. Aynı tarifin bir kullanıcı tarafından birden fazla kez favoriye 
eklenmesi veritabanı seviyesinde engellenmiştir. 
Tarifler için puanlama ve yorumlama özelliği de uygulama içerisinde yer almaktadır. 
Kullanıcılar tariflere 1 ile 5 arasında puan verebilmekte ve isteğe bağlı olarak yorum 
ekleyebilmektedir. Her kullanıcı bir tarife yalnızca bir kez puan verebilmektedir. Tariflerin 
ortalama puan bilgileri veritabanı üzerinden hesaplanmakta ve kullanıcı arayüzünde 
gösterilmektedir. 


 
 
 

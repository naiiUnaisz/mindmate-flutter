# MindMate — Backend API

Aplikasi **habit tracker gamified** berbasis Laravel yang membantu pengguna membangun kebiasaan positif melalui sistem tugas, koin, puzzle harian, streak, dan hiburan terkontrol.

---

## Tech Stack

| Teknologi | Kegunaan |
|---|---|
| **Laravel 12** | Framework backend PHP |
| **MySQL** | Database relasional |
| **Laravel Sanctum** | Autentikasi token-based |
| **Laravel SoftDeletes** | Hapus task secara aman |
| **Storage (Local)** | Penyimpanan avatar user |

---

## Database Schema

```
users (1) ──< tasks (N)              # User punya banyak tugas
users (1) ──< daily_records (N)      # User punya banyak daily record (1/hari)
users (1) ──< entertainment_logs (N) # User punya banyak sesi hiburan
users (1) ──< punishments (N)        # User punya banyak denda
users (1) ──< coin_histories (N)     # User punya banyak riwayat koin
users (1) ──< puzzle_pieces (N)      # User punya banyak piece puzzle (via daily_record)

daily_records (1) ──< daily_task_items (N)
daily_records (1) ──< puzzle_pieces (N)
daily_task_items (1) ──< puzzle_pieces (1)
daily_task_items (1) ──< coin_histories (N)  # Polymorphic (source)
tasks (1) ──< daily_task_items (N)

apps (1) ──< entertainment_logs (N)
entertainment_logs (1) ──< punishments (1)
entertainment_logs (1) ──< coin_histories (N)  # Polymorphic (source)
punishments (1) ──< coin_histories (N)          # Polymorphic (source)
```

**Polymorphic `CoinHistories`**: Mencatat transaksi koin (reward/expense) dari 3 sumber:
- `DailyTaskItem` — reward checklist task
- `EntertainmentLog` — pembayaran sesi hiburan
- `Punishment` — denda keterlambatan

---

## Logic Bisnis

### 1. Autentikasi (Sanctum Token)

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/register` | POST | Register akun baru, return token |
| `/login` | POST | Login email+password, return token |
| `/logout` | POST | Hapus token aktif |

- Token disimpan di tabel `personal_access_tokens` (Sanctum)
- Semua endpoint kecuali register & login wajib header: `Authorization: Bearer {token}`

### 2. Task Management

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/tasks` | GET | Lihat semua tugas user |
| `/tasks/{id}` | GET | Detail tugas |
| `/tasks` | POST | Buat tugas baru |
| `/tasks/{id}` | PUT | Update tugas |
| `/tasks/{id}` | DELETE | Hapus tugas (soft delete) |

- Setiap task punya: `title`, `description`, `coin_reward`, `task_type`, `is_routine`, `is_checked`
- Soft delete: data tetap di database, hanya ditandai `deleted_at`

### 3. Checklist Task & Reward System (Core Logic)

**Endpoint:** `POST /tasks/{id}/check`

**Parameter:**
- `source` (string): `"cart"` (default) atau `"puzzle"`

**Flow:**

```
1. Ambil / buat DailyRecord untuk hari ini
2. Cek streak kemarin:
   - Jika kemarin puzzle tidak penuh (6/6) dan bukan rest day → streak di-reset ke 0
3. Buat / ambil DailyTaskItem untuk task ini
   - Jika sudah completed hari ini → return error
4. Tandai DailyTaskItem → is_completed = true
5. Hitung reward:
   ┌──────────────┬──────────────────────────────────────┐
   │ source=cart  │ +10 coin (fixed)                     │
   ├──────────────┼──────────────────────────────────────┤
   │ source=puzzle │ +10 coin per piece (max 6/hari)     │
   │              │ + bonus +100 jika full puzzle 6/6    │
   │              │ + streak +1 jika full puzzle 6/6     │
   └──────────────┴──────────────────────────────────────┘
6. Tambah koin ke user
7. Catat transaksi ke CoinHistories (polymorphic)
```

### 4. Puzzle System

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/puzzles` | GET | Status puzzle hari ini |
| `/puzzles/unlock` | POST | Buka puzzle tanpa task |

- **6 piece per hari per user**
- Per piece: +25 coin (via `/puzzles/unlock`)
- Bonus **+100 coin** + **streak +1** saat 6/6 (kecuali rest day)
- Puzzle piece berelasi ke `DailyRecord` dan `DailyTaskItem`

### 5. Streak System

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/streak` | GET | Cek current streak & rest day quota |
| `/streak/increment` | POST | Tambah streak manual |

- Streak bertambah otomatis saat puzzle 6/6 tercapai
- Streak **di-reset ke 0** jika:
  - Kemarin puzzle tidak penuh (6/6)
  - DAN kemarin **bukan** rest day
- Rest day melindungi streak dari reset

### 6. Rest Day

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/daily-record/rest-day` | POST | Aktifkan rest day hari ini |

- Quota default: **2 per user**
- Tidak bisa double rest day
- Saat rest day aktif: streak aman meski puzzle tidak penuh

### 7. Mood Tracking

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/daily-record/mood` | POST | Catat mood hari ini |
| `/mood/history` | GET | Riwayat mood |

- 3 level mood: `good`, `neutral`, `bad`
- 1 record per hari (update jika sudah ada)

### 8. Entertainment System

#### 8.1 Purchase (Beli Sesi)

**Endpoint:** `POST /apps/{id}/purchase`

**Logic Inflasi Harga:**

```
harga_aktual = harga_dasar × 1.5^(jumlah_beli_hari_ini_sama)
```

- Setiap pembelian di hari yang sama, harga naik 1.5x lipat
- Hanya boleh **1 sesi aktif** dalam satu waktu
- Sesi otomatis punya `expired_at` = sekarang + durasi menit

#### 8.2 Complete/Absen

**Endpoint:** `POST /apps/complete`

**Logic Denda:**

```
jika telat ≥ 1 menit:
    denda = menit_telat × 5 coin
    status = "fined"
jika grace period < 1 menit:
    status = "absen_success" (dianggap tepat waktu)
jika tepat waktu / lebih awal:
    status = "absen_success"
```

#### 8.3 Session Manual

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/relax/session/start` | POST | Mulai sesi dengan app & durasi kustom |
| `/relax/session/end` | POST | Akhiri sesi dengan catatan keterlambatan |
| `/relax/session/active` | GET | Cek sesi yang sedang berlangsung |
| `/relax/session/history` | GET | Riwayat sesi (paginated) |

### 9. Coin Economy

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/coins/history` | GET | Riwayat transaksi koin |
| `/coins/earn` | POST | Tambah koin manual |
| `/coins/spend` | POST | Kurangi koin manual |
| `/coin-histori` | GET | Riwayat koin (alias) |

**Sumber Pemasukan:**
- Checklist task (cart): +10 coin
- Checklist task (puzzle): +10 coin/piece + bonus +100 saat full
- Unlock puzzle manual: +25 coin/piece + bonus +100 saat full

**Sumber Pengeluaran:**
- Beli sesi hiburan: harga_dasar × 1.5^jumlah_beli
- Denda keterlambatan: menit_telat × 5 coin

### 10. User Profile & Settings

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/user/profile` | GET | Lihat profil lengkap |
| `/user/profile` | PUT | Edit profil + avatar |
| `/user/change-email` | POST | Ganti email |
| `/user/change-password` | POST | Ganti password |
| `/user/settings` | POST | Update settings (JSON) |

- Avatar disimpan di `storage/app/public/avatars/`
- `age` dihitung otomatis dari `birthday`
- `settings` adalah kolom JSON bebas (theme, notifikasi, dll)

---

## Best Practice untuk Flutter

### 1. API Service — Dio dengan Interceptor

```dart
class ApiService {
  late final Dio _dio;

  ApiService(FlutterSecureStorage storage) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://unaisah-digitallab.my.id/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(AuthInterceptor(storage));
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Dio get client => _dio;
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Redirect ke halaman login
    }
    handler.next(err);
  }
}
```

### 2. Model Contoh

```dart
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? birthday;
  final int? age;
  final String? gender;
  final String? avatar;
  final int coinBalance;
  final int currentStreak;
  final int restdayQuota;
  final Map<String, dynamic>? settings;

  UserProfile({
    required this.id, required this.name, required this.email,
    required this.username, this.birthday, this.age, this.gender,
    this.avatar, required this.coinBalance, required this.currentStreak,
    required this.restdayQuota, this.settings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    username: json['username'],
    birthday: json['birthday'],
    age: json['age'],
    gender: json['gender'],
    avatar: json['avatar'],
    coinBalance: json['coin_balance'],
    currentStreak: json['current_streak'],
    restdayQuota: json['restday_quota'],
    settings: json['settings'],
  );
}
```

### 3. Repository Pattern

```dart
class TaskRepository {
  final Dio _http;

  TaskRepository(this._http);

  Future<List<Task>> getAll() async {
    final res = await _http.get('/tasks');
    return (res.data['data'] as List).map((j) => Task.fromJson(j)).toList();
  }

  Future<Task> getById(int id) async {
    final res = await _http.get('/tasks/$id');
    return Task.fromJson(res.data['data']);
  }

  Future<Task> create(Map<String, dynamic> data) async {
    final res = await _http.post('/tasks', data: data);
    return Task.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> check(int id, {String source = 'cart'}) async {
    final res = await _http.post('/tasks/$id/check', data: {'source': source});
    return res.data['data'];
  }
}
```

### 4. State Management (Contoh Riverpod)

```dart
@riverpod
class DailyRecordNotifier extends _$DailyRecordNotifier {
  @override
  Future<DailyRecord> build() async {
    final repo = ref.watch(dailyRecordRepositoryProvider);
    return repo.getToday();
  }

  Future<void> saveMood(String mood) async {
    final repo = ref.read(dailyRecordRepositoryProvider);
    await repo.storeMood(mood);
    ref.invalidateSelf();
  }

  Future<void> useRestDay() async {
    final repo = ref.read(dailyRecordRepositoryProvider);
    await repo.useRestDay();
    ref.invalidateSelf();
  }
}
```

### 5. Upload Avatar dengan FormData

```dart
Future<void> updateAvatar(File image) async {
  final formData = FormData.fromMap({
    'avatar': await MultipartFile.fromFile(
      image.path,
      filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ),
  });

  final response = await _dio.put('/user/profile', data: formData);
}
```

### 6. Error Handling

```dart
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResult({required this.success, this.data, this.message});

  static Future<ApiResult<T>> guard<T>(Future<T> Function() call) async {
    try {
      final data = await call();
      return ApiResult(success: true, data: data);
    } on DioException catch (e) {
      return ApiResult(
        success: false,
        message: e.response?.data?['message'] ?? 'Terjadi kesalahan',
      );
    } catch (e) {
      return ApiResult(success: false, message: e.toString());
    }
  }
}
```

### 7. Caching Token — Jangan Pakai SharedPreferences

```dart
// ✅ Pakai FlutterSecureStorage
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);

// ❌ Jangan pakai SharedPreferences untuk token
// final prefs = await SharedPreferences.getInstance();
// await prefs.setString('auth_token', token); // TIDAK AMAN
```

### 8. Tips Penting untuk Flutter Developer

| Area | Best Practice |
|---|---|
| **Token Storage** | Gunakan `flutter_secure_storage`, bukan `SharedPreferences` |
| **Auth Header** | Dio interceptor — inject token otomatis, handle 401 |
| **Response Format** | Semua response punya `success`, `data`, `message` |
| **Pagination** | Endpoint `/relax/session/history` pakai pagination — implementasi scroll loading |
| **Date Format** | Backend: `YYYY-MM-DD` (date), `YYYY-MM-DD HH:mm:ss` (datetime) |
| **Source Param** | `source: "cart"` = todo list, `source: "puzzle"` = puzzle page |
| **Avatar** | Kirim sebagai `multipart/form-data`, bukan JSON |
| **Settings** | Kolom JSON bebas — cocok untuk theme, notifikasi, dll |
| **Coins** | Integer — tampilkan dengan formatting ribuan |
| **Error Message** | Selalu tampilkan `message` dari response ke user (toast/snackbar) |

---

## Setup & Instalasi

```bash
git clone <repo-url>
cd mindmate-laravel

# Install dependency
composer install

# Copy environment
cp .env.example .env
# Edit .env: DB_DATABASE, DB_USERNAME, DB_PASSWORD

# Generate key & migrate
php artisan key:generate
php artisan migrate
php artisan db:seed

# Storage link (untuk avatar)
php artisan storage:link

# Jalankan server
php artisan serve
```

## Seeder

```bash
php artisan db:seed
```

Seeder menyediakan:
- **1 test user**: `test@mindmate.com` / `password`
- **6 apps hiburan**: Spotify, Netflix, YouTube, Mobile Legends, TikTok, Instagram

---
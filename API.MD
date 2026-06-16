# API Documentation — MindMate

**Base URL:** `https://unaisah-digitallab.my.id/api`

**Format Response Umum:**
```json
{
    "success": true,
    "data": { ... },
    "message": "..."
}
```

Semua error response mengembalikan:
```json
{
    "success": false,
    "message": "Pesan error"
}
```

---

## 1. Public Endpoints (Tanpa Token)

### 1.1 Register

Mendaftarkan akun baru.

**Endpoint**
```
POST /register
```

**Request Body** (JSON)
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "rahasia123",
    "username": "johndoe"
}
```

| Parameter | Tipe | Required | Keterangan |
|---|---|---|---|
| `name` | string | Ya | Nama lengkap |
| `email` | string | Ya | Email (unique) |
| `password` | string | Ya | Min 6 karakter |
| `username` | string | Ya | Username (unique) |

**Response** `201 Created`
```json
{
    "success": true,
    "access_token": "1|abc123def456...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "username": "johndoe",
        "birthday": null,
        "age": null,
        "gender": null,
        "avatar": null,
        "coin_balance": 0,
        "current_streak": 0,
        "restday_quota": 2,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T10:00:00.000000Z"
    }
}
```

**Error Response** `422 Unprocessable Content` (validasi gagal)
```json
{
    "message": "The email has already been taken.",
    "errors": {
        "email": ["The email has already been taken."]
    }
}
```

---

### 1.2 Login

Login dan mendapatkan token akses.

**Endpoint**
```
POST /login
```

**Request Body** (JSON)
```json
{
    "email": "john@example.com",
    "password": "rahasia123"
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "access_token": "2|xyz789abc...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "username": "johndoe",
        "birthday": "2000-01-15",
        "age": 26,
        "gender": "male",
        "avatar": "http://localhost/storage/avatars/abc123.jpg",
        "coin_balance": 50,
        "current_streak": 3,
        "restday_quota": 2,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T12:00:00.000000Z"
    }
}
```

**Error Response** `401 Unauthorized`
```json
{
    "success": false,
    "message": "Email atau password salah"
}
```

---

## 2. Protected Endpoints (Wajib Bearer Token)

Semua endpoint di bawah **wajib** menyertakan token autentikasi pada HTTP Header:

```
Authorization: Bearer {access_token}
```

---

### 2.1 Fitur Tasks

#### 2.1.1 Lihat Semua Tugas

```
GET /tasks
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "user_id": 1,
            "title": "Belajar Laravel",
            "description": "Membaca dokumentasi routes",
            "coin_reward": 10,
            "task_type": "belajar",
            "is_routine": false,
            "is_checked": false,
            "is_completed_today": false,
            "created_at": "2026-06-08T10:00:00.000000Z",
            "updated_at": "2026-06-08T10:00:00.000000Z"
        }
    ]
}
```

#### 2.1.2 Lihat Detail Tugas

```
GET /tasks/{id}
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "title": "Belajar Laravel",
        "description": "Membaca dokumentasi routes",
        "coin_reward": 10,
        "task_type": "belajar",
        "is_routine": false,
        "is_checked": false,
        "is_completed_today": false,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T10:00:00.000000Z"
    }
}
```

#### 2.1.3 Tambah Tugas

```
POST /tasks
```

**Request Body**
```json
{
    "title": "Belajar Laravel",
    "description": "Membaca dokumentasi routes",
    "is_routine": false,
    "coin_reward": 10,
    "task_type": "belajar"
}
```

| Parameter | Tipe | Required | Default | Keterangan |
|---|---|---|---|---|
| `title` | string | Ya | - | Judul tugas |
| `description` | string | Tidak | null | Deskripsi tugas |
| `is_routine` | boolean | Tidak | false | Apakah tugas rutin |
| `coin_reward` | integer | Tidak | 10 | Koin yang didapat (legacy, reward sekarang fixed +10) |
| `task_type` | string | Tidak | null | Kategori tugas |

**Response** `201 Created`
```json
{
    "success": true,
    "message": "Tugas berhasil ditambahkan",
    "data": {
        "id": 1,
        "user_id": 1,
        "title": "Belajar Laravel",
        "description": "Membaca dokumentasi routes",
        "coin_reward": 10,
        "task_type": "belajar",
        "is_routine": false,
        "is_checked": false,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T10:00:00.000000Z"
    }
}
```

#### 2.1.4 Update Tugas

```
PUT /tasks/{id}
```

**Request Body**
```json
{
    "title": "Belajar Laravel Lanjutan",
    "description": "Membaca dokumentasi Eloquent",
    "is_checked": true,
    "is_routine": true,
    "coin_reward": 15,
    "task_type": "belajar"
}
```

Semua parameter bersifat opsional.

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Tugas berhasil diperbarui",
    "data": {
        "id": 1,
        "user_id": 1,
        "title": "Belajar Laravel Lanjutan",
        "description": "Membaca dokumentasi Eloquent",
        "coin_reward": 15,
        "task_type": "belajar",
        "is_routine": true,
        "is_checked": true,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T12:00:00.000000Z"
    }
}
```

**Error Response** `404 Not Found` (bukan pemilik tugas / tidak ditemukan)
```json
{
    "message": "No query results for model [App\\Models\\Task] 1"
}
```

#### 2.1.5 Hapus Tugas (Soft Delete)

```
DELETE /tasks/{id}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Tugas berhasil dihapus"
}
```

#### 2.1.6 Checklist Tugas Harian (Dapat Koin & Puzzle)

```
POST /tasks/{id}/check
```

Menandai tugas selesai untuk hari ini. Koin otomatis ditambahkan, dan potongan puzzle dibuka (jika dari halaman puzzle).

**Request Body** (opsional)
```json
{
    "source": "cart"
}
```

| Parameter | Tipe | Default | Keterangan |
|---|---|---|---|
| `source` | string | `"cart"` | Asal checklist: `"cart"` (To-Do List) atau `"puzzle"` (Halaman Puzzle) |

**Logic Reward:**

- **`source = "cart"`**: Mendapat **+10 coin** (fixed). Task ditandai `is_checked = true`.
- **`source = "puzzle"`**:
  - Membuka 1 piece puzzle (maksimal 6 per hari) → **+10 coin**
  - Jika puzzle mencapai **6/6**: bonus **+100 coin** + **streak +1**
  - Jika puzzle sudah penuh (6/6): tidak membuka piece baru

> **Catatan:** Sebelum memberi reward, sistem mengecek streak kemarin. Jika kemarin puzzle tidak penuh (kecuali rest day), streak di-reset ke 0.

**Response** `200 OK` (cart)
```json
{
    "success": true,
    "message": "Tugas berhasil diselesaikan!",
    "data": {
        "source": "cart",
        "puzzle_opened": false,
        "current_puzzle_count": 0,
        "coins_earned": 10,
        "current_coin_balance": 50,
        "current_streak": 3
    }
}
```

**Response** `200 OK` (puzzle — buka piece)
```json
{
    "success": true,
    "message": "Tugas berhasil diselesaikan!",
    "data": {
        "source": "puzzle",
        "puzzle_opened": true,
        "current_puzzle_count": 3,
        "coins_earned": 10,
        "current_coin_balance": 60,
        "current_streak": 3
    }
}
```

**Response** `200 OK` (puzzle — full puzzle + bonus)
```json
{
    "success": true,
    "message": "Tugas berhasil diselesaikan!",
    "data": {
        "source": "puzzle",
        "puzzle_opened": true,
        "current_puzzle_count": 6,
        "coins_earned": 110,
        "current_coin_balance": 170,
        "current_streak": 4
    }
}
```

**Error Response** `400 Bad Request` (tugas sudah diceklis hari ini)
```json
{
    "success": false,
    "message": "Tugas ini sudah diselesaikan hari ini."
}
```

---

### 2.2 Fitur Daily Record (Puzzle, Mood, Rest Day)

#### 2.2.1 Lihat Daily Record Hari Ini

```
GET /daily-record
```

Mengembalikan data record harian termasuk mood, status rest day, progress puzzle, dan task yang sudah dikerjakan hari ini.

**Response** `200 OK` (sudah ada aktivitas hari ini)
```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "date": "2026-06-08",
        "mood_level": "good",
        "is_rest_day": false,
        "puzzle_completed_count": 3,
        "daily_task_items": [
            {
                "id": 1,
                "daily_record_id": 1,
                "task_id": 1,
                "is_completed": true,
                "task": {
                    "id": 1,
                    "user_id": 1,
                    "title": "Belajar Laravel",
                    "description": null,
                    "coin_reward": 10,
                    "task_type": null,
                    "is_routine": false,
                    "is_checked": false,
                    "created_at": "2026-06-08T10:00:00.000000Z",
                    "updated_at": "2026-06-08T10:00:00.000000Z"
                },
                "created_at": "2026-06-08T10:00:00.000000Z",
                "updated_at": "2026-06-08T10:00:00.000000Z"
            }
        ],
        "puzzle_pieces": [
            {
                "id": 1,
                "daily_record_id": 1,
                "daily_task_item_id": 1,
                "piece_number": 1,
                "is_opened": true,
                "opened_at": "2026-06-08T10:00:00.000000Z",
                "created_at": "2026-06-08T10:00:00.000000Z",
                "updated_at": "2026-06-08T10:00:00.000000Z"
            }
        ],
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T10:00:00.000000Z"
    }
}
```

**Response** `200 OK` (belum ada aktivitas hari ini)
```json
{
    "success": true,
    "data": {
        "date": "2026-06-08",
        "mood_level": null,
        "is_rest_day": false,
        "puzzle_completed_count": 0,
        "daily_task_items": [],
        "puzzle_pieces": []
    }
}
```

#### 2.2.2 Catat Mood Harian

```
POST /daily-record/mood
```

**Request Body**
```json
{
    "mood_level": "good"
}
```

Nilai `mood_level` yang valid: `"good"`, `"neutral"`, `"bad"`.

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Mood kamu hari ini berhasil dicatat!",
    "data": {
        "date": "2026-06-08",
        "mood_level": "good"
    }
}
```

#### 2.2.3 Gunakan Rest Day

```
POST /daily-record/rest-day
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Rest Day berhasil diaktifkan! Nikmati waktu istirahatmu hari ini.",
    "data": {
        "current_restday_quota": 1,
        "is_rest_day": true
    }
}
```

**Error Response** `400 Bad Request` (rest day sudah dipakai hari ini)
```json
{
    "success": false,
    "message": "Kamu sudah mengambil jatah Rest Day untuk hari ini."
}
```

**Error Response** `400 Bad Request` (kuota habis)
```json
{
    "success": false,
    "message": "Kuota Rest Day kamu sudah habis! Tetap semangat kerjakan tugas ya."
}
```

#### 2.2.4 Riwayat Mood

```
GET /mood/history
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "date": "2026-06-08",
            "mood_level": "good",
            "is_rest_day": false
        }
    ]
}
```

---

### 2.3 Fitur Hiburan (Relax)

#### 2.3.1 Daftar Aplikasi Hiburan

```
GET /apps
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "youtube",
            "title": "YouTube",
            "category": "movie",
            "url": "https://youtube.com",
            "coin_cost": 30,
            "duration_minutes": 30,
            "created_at": null,
            "updated_at": null
        }
    ]
}
```

#### 2.3.2 Beli Sesi Hiburan

```
POST /apps/{id}/purchase
```

**Logic:**
- Harga mengalami **inflasi** setiap pembelian di hari yang sama: `harga_asli × 1.5^(jumlah_pembelian_hari_ini)`
- Hanya bisa 1 sesi aktif dalam satu waktu
- Sesi otomatis memiliki `expired_at` = waktu sekarang + durasi menit

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Pembelian berhasil! Selamat bersantai.",
    "data": {
        "app_name": "YouTube",
        "deep_link_url": "https://youtube.com",
        "duration_minutes": 30,
        "expired_at": "2026-06-08T10:30:00",
        "coins_spent": 30,
        "current_coin_balance": 20
    }
}
```

**Error Response** `400 Bad Request` (koin tidak cukup)
```json
{
    "success": false,
    "message": "Koin kamu tidak cukup! Harga aplikasi ini sudah naik menjadi 60 koin karena faktor inflasi harian. Selesaikan tugas dulu yuk."
}
```

**Error Response** `400 Bad Request` (masih punya sesi aktif)
```json
{
    "success": false,
    "message": "Kamu masih punya sesi hiburan yang aktif!"
}
```

#### 2.3.3 Mulai Sesi Hiburan (Manual)

```
POST /relax/session/start
```

**Request Body**
```json
{
    "app_id": 1,
    "duration": 30
}
```

| Parameter | Tipe | Required | Default | Keterangan |
|---|---|---|---|---|
| `app_id` | integer | Ya | - | ID aplikasi hiburan |
| `duration` | integer | Tidak | `duration_minutes` dari app | Durasi sesi dalam menit (min 1, max 180) |

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Sesi hiburan dimulai!",
    "data": {
        "session_id": 1,
        "app_name": "YouTube",
        "app_url": "https://youtube.com",
        "duration_minutes": 30,
        "start_time": "2026-06-08 10:00:00",
        "expired_at": "2026-06-08 10:30:00",
        "coins_spent": 30,
        "current_coin_balance": 20
    }
}
```

#### 2.3.4 Akhiri Sesi Hiburan (Manual)

```
POST /relax/session/end
```

**Request Body**
```json
{
    "session_id": 1,
    "late_minutes": 5
}
```

| Parameter | Tipe | Required | Default | Keterangan |
|---|---|---|---|---|
| `session_id` | integer | Ya | - | ID sesi yang akan diakhiri |
| `late_minutes` | integer | Tidak | 0 | Jumlah menit keterlambatan |

**Logic Denda:**
- Jika `late_minutes > 0`: denda = `late_minutes × 5 coin`, status `fined`
- Jika `late_minutes = 0`: status `absen_success`, tanpa denda

**Response** `200 OK` (tepat waktu)
```json
{
    "success": true,
    "message": "Sesi selesai tepat waktu!",
    "data": {
        "status": "absen_success",
        "current_coin_balance": 20
    }
}
```

**Response** `200 OK` (telat)
```json
{
    "success": true,
    "message": "Kamu telat 5 menit. Koin dipotong 25.",
    "data": {
        "status": "fined",
        "fine_amount": 25,
        "current_coin_balance": -5
    }
}
```

#### 2.3.5 Cek Sesi Aktif

```
GET /relax/session/active
```

**Response** `200 OK` (ada sesi aktif)
```json
{
    "success": true,
    "data": {
        "session_id": 1,
        "app_id": 1,
        "app_name": "YouTube",
        "app_url": "https://youtube.com",
        "start_time": "2026-06-08 10:00:00",
        "expired_at": "2026-06-08 10:30:00",
        "remaining_minutes": 15,
        "status": "playing"
    }
}
```

**Response** `200 OK` (tidak ada sesi aktif)
```json
{
    "success": true,
    "data": null
}
```

#### 2.3.6 Riwayat Sesi Hiburan

```
GET /relax/session/history
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": [
        {
            "session_id": 1,
            "app_name": "YouTube",
            "start_time": "2026-06-08 10:00:00",
            "expired_at": "2026-06-08 10:30:00",
            "status": "absen_success",
            "fine_amount": null,
            "created_at": "2026-06-08T10:00:00.000000Z"
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 1
    }
}
```

#### 2.3.7 Absen Sesi Otomatis (Complete)

```
POST /apps/complete
```

Mengakhiri sesi aktif secara otomatis. Sistem menghitung keterlambatan dari `expired_at`.

**Logic Denda:**
- Jika waktu sekarang **melebihi** `expired_at`:
  - Grace period < 1 menit: dianggap **tepat waktu** (status `absen_success`)
  - Jika telat ≥ 1 menit: denda = `menit telat × 5 coin` (status `fined`)
- Jika **tepat waktu / lebih awal**: status `absen_success`, tanpa denda

**Response** `200 OK` (tepat waktu / grace period)
```json
{
    "success": true,
    "message": "Hebat! Kamu disiplin dan absen tepat waktu. Sesi bermain ditutup.",
    "data": {
        "status": "absen_success",
        "current_coin_balance": 20
    }
}
```

**Response** `200 OK` (telat — kena denda)
```json
{
    "success": true,
    "message": "Waduh! Kamu telat absen 5 menit. Koin kamu dipotong 25 sebagai denda.",
    "data": {
        "status": "fined",
        "fine_amount": 25,
        "current_coin_balance": -5
    }
}
```

**Error Response** `400 Bad Request` (tidak ada sesi aktif)
```json
{
    "success": false,
    "message": "Kamu tidak memiliki sesi hiburan yang aktif saat ini."
}
```

---

### 2.4 Riwayat Koin

```
GET /coin-histori
```

**Response** `200 OK`
```json
{
    "success": true,
    "current_balance": 75,
    "data": [
        {
            "id": 3,
            "amount": 25,
            "status": "expense",
            "description": "Denda: Telat absen hiburan",
            "date": "2026-06-08 10:35:00"
        },
        {
            "id": 2,
            "amount": 30,
            "status": "expense",
            "description": "Membeli hiburan: YouTube",
            "date": "2026-06-08 10:00:00"
        },
        {
            "id": 1,
            "amount": 10,
            "status": "reward",
            "description": "Menyelesaikan tugas: Belajar Laravel",
            "date": "2026-06-08 09:00:00"
        }
    ]
}
```

---

### 2.5 Fitur Koin (Manual)

#### 2.5.1 Tambah Koin

```
POST /coins/earn
```

**Request Body**
```json
{
    "amount": 50
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "50 koin berhasil ditambahkan",
    "current_balance": 150
}
```

#### 2.5.2 Kurangi Koin

```
POST /coins/spend
```

**Request Body**
```json
{
    "amount": 30
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "30 koin berhasil digunakan",
    "current_balance": 120
}
```

#### 2.5.3 Riwayat Koin (alias)

```
GET /coins/history
```

Sama seperti `/coin-histori`.

---

### 2.6 Fitur Puzzle

#### 2.6.1 Status Puzzle Hari Ini

```
GET /puzzles
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": {
        "date": "2026-06-08",
        "puzzle_completed_count": 3,
        "is_rest_day": false,
        "puzzle_pieces": [
            {
                "id": 1,
                "daily_record_id": 1,
                "daily_task_item_id": 1,
                "piece_number": 1,
                "is_opened": true,
                "opened_at": "2026-06-08T10:00:00.000000Z",
                "created_at": "2026-06-08T10:00:00.000000Z",
                "updated_at": "2026-06-08T10:00:00.000000Z"
            }
        ]
    }
}
```

#### 2.6.2 Buka Puzzle (Tanpa Task)

```
POST /puzzles/unlock
```

Membuka 1 piece puzzle secara langsung tanpa harus melalui checklist task.

**Logic:**
- Maksimal 6 piece per hari
- Per piece: **+25 coin**
- Jika mencapai 6/6 dan bukan rest day: bonus **+100 coin** + **streak +1**

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Potongan puzzle berhasil dibuka!",
    "data": {
        "piece": {
            "id": 2,
            "daily_record_id": 1,
            "daily_task_item_id": 1,
            "piece_number": 2,
            "is_opened": true,
            "opened_at": "2026-06-08T11:00:00.000000Z",
            "created_at": "2026-06-08T11:00:00.000000Z",
            "updated_at": "2026-06-08T11:00:00.000000Z"
        },
        "current_puzzle_count": 2,
        "is_complete": false,
        "coins_earned": 25,
        "current_coin_balance": 100,
        "current_streak": 3
    }
}
```

---

### 2.7 Fitur Profil & Settings

#### 2.7.1 Profil User

```
GET /user/profile
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "username": "johndoe",
        "birthday": "2000-01-15",
        "age": 26,
        "gender": "male",
        "avatar": "http://localhost/storage/avatars/abc123.jpg",
        "coin_balance": 75,
        "current_streak": 3,
        "restday_quota": 2,
        "settings": null,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T12:00:00.000000Z"
    }
}
```

#### 2.7.2 Edit Profil

```
PUT /user/profile
```

**Request Body** (semua opsional, multipart/form-data untuk avatar)
```json
{
    "name": "John Updated",
    "email": "johnbaru@example.com",
    "username": "johnbaru",
    "birthday": "2001-05-20",
    "gender": "male"
}
```

| Parameter | Tipe | Required | Keterangan |
|---|---|---|---|
| `name` | string | Tidak | Nama lengkap |
| `email` | string | Tidak | Email (unique, kecuali milik sendiri) |
| `username` | string | Tidak | Username (unique, kecuali milik sendiri) |
| `birthday` | date | Tidak | Tanggal lahir (format `YYYY-MM-DD`) |
| `gender` | string | Tidak | `male` atau `female` |
| `avatar` | file | Tidak | File gambar (jpeg,png,jpg,gif,webp, max 2MB) |

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Profile updated successfully",
    "data": {
        "id": 1,
        "name": "John Updated",
        "email": "johnbaru@example.com",
        "username": "johnbaru",
        "birthday": "2001-05-20",
        "age": 25,
        "gender": "male",
        "avatar": "http://localhost/storage/avatars/xyz789.jpg",
        "coin_balance": 75,
        "current_streak": 3,
        "restday_quota": 2,
        "created_at": "2026-06-08T10:00:00.000000Z",
        "updated_at": "2026-06-08T13:00:00.000000Z"
    }
}
```

#### 2.7.3 Ganti Email

```
POST /user/change-email
```

**Request Body**
```json
{
    "email": "emailbaru@example.com"
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Email changed successfully",
    "data": { ... }
}
```

#### 2.7.4 Ganti Password

```
POST /user/change-password
```

**Request Body**
```json
{
    "current_password": "rahasia123",
    "new_password": "rahasia456",
    "new_password_confirmation": "rahasia456"
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Password changed successfully"
}
```

#### 2.7.5 Update Settings

```
POST /user/settings
```

**Request Body**
```json
{
    "settings": {
        "theme": "dark",
        "notification": true
    }
}
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Settings updated successfully",
    "data": {
        "settings": {
            "theme": "dark",
            "notification": true
        }
    }
}
```

#### 2.7.6 Cek Streak

```
GET /streak
```

**Response** `200 OK`
```json
{
    "success": true,
    "data": {
        "current_streak": 3,
        "restday_quota": 2
    }
}
```

---

### 2.8 Logout

Hapus token akses yang sedang digunakan.

```
POST /logout
```

**Response** `200 OK`
```json
{
    "success": true,
    "message": "Logout successfully"
}
```

---

## 3. Ringkasan Endpoint

| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| POST | `/register` | - | Register akun baru |
| POST | `/login` | - | Login & dapatkan token |
| POST | `/logout` | Sanctum | Hapus token |
| GET | `/tasks` | Sanctum | Lihat semua tugas |
| GET | `/tasks/{id}` | Sanctum | Lihat detail tugas |
| POST | `/tasks` | Sanctum | Tambah tugas baru |
| PUT | `/tasks/{id}` | Sanctum | Update tugas |
| DELETE | `/tasks/{id}` | Sanctum | Hapus tugas (soft delete) |
| POST | `/tasks/{id}/check` | Sanctum | Checklist tugas harian |
| GET | `/apps` | Sanctum | Daftar aplikasi hiburan |
| POST | `/apps/{id}/purchase` | Sanctum | Beli sesi hiburan |
| POST | `/apps/complete` | Sanctum | Absen selesai hiburan |
| POST | `/relax/session/start` | Sanctum | Mulai sesi hiburan manual |
| POST | `/relax/session/end` | Sanctum | Akhiri sesi hiburan manual |
| GET | `/relax/session/active` | Sanctum | Cek sesi aktif |
| GET | `/relax/session/history` | Sanctum | Riwayat sesi hiburan |
| GET | `/daily-record` | Sanctum | Daily record hari ini |
| POST | `/daily-record/mood` | Sanctum | Catat mood harian |
| POST | `/daily-record/rest-day` | Sanctum | Gunakan rest day |
| GET | `/mood/history` | Sanctum | Riwayat mood |
| GET | `/puzzles` | Sanctum | Status puzzle hari ini |
| POST | `/puzzles/unlock` | Sanctum | Buka puzzle tanpa task |
| GET | `/coin-histori` | Sanctum | Riwayat koin |
| GET | `/coins/history` | Sanctum | Riwayat koin (alias) |
| POST | `/coins/earn` | Sanctum | Tambah koin manual |
| POST | `/coins/spend` | Sanctum | Kurangi koin manual |
| GET | `/user/profile` | Sanctum | Lihat profil user |
| PUT | `/user/profile` | Sanctum | Edit profil user |
| POST | `/user/change-email` | Sanctum | Ganti email |
| POST | `/user/change-password` | Sanctum | Ganti password |
| POST | `/user/settings` | Sanctum | Update settings |
| GET | `/streak` | Sanctum | Cek streak & rest day quota |

---

## 4. Best Practice untuk Flutter

### 4.1 Autentikasi — Simpan Token dengan Aman

```dart
// flutter_secure_storage — jangan pakai SharedPreferences untuk token!
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final _http = Dio(BaseOptions(baseUrl: 'https://unaisah-digitallab.my.id/api'));

  Future<void> login(String email, String password) async {
    final response = await _http.post('/login', data: {
      'email': email,
      'password': password,
    });

    final token = response.data['access_token'];
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  Future<void> logout() async {
    final token = await getToken();
    await _http.post('/logout', options: Options(headers: {
      'Authorization': 'Bearer $token',
    }));
    await _storage.delete(key: 'auth_token');
  }
}
```

### 4.2 Dio Interceptor — Suntik Token Otomatis

```dart
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — redirect ke login
    }
    handler.next(err);
  }
}
```

### 4.3 Model — Parsing JSON dengan `fromJson`/`toJson`

```dart
class Task {
  final int id;
  final String title;
  final String? description;
  final int coinReward;
  final String? taskType;
  final bool isRoutine;
  final bool isChecked;
  final bool isCompletedToday;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.coinReward,
    this.taskType,
    required this.isRoutine,
    required this.isChecked,
    required this.isCompletedToday,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    coinReward: json['coin_reward'],
    taskType: json['task_type'],
    isRoutine: json['is_routine'],
    isChecked: json['is_checked'],
    isCompletedToday: json['is_completed_today'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'coin_reward': coinReward,
    'task_type': taskType,
    'is_routine': isRoutine,
    'is_checked': isChecked,
  };
}
```

### 4.4 Repository Pattern — Pisahkan Logika Bisnis

```dart
class TaskRepository {
  final Dio _http;

  TaskRepository(this._http);

  Future<List<Task>> getTasks() async {
    final response = await _http.get('/tasks');
    return (response.data['data'] as List)
        .map((json) => Task.fromJson(json))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    final response = await _http.post('/tasks', data: task.toJson());
    return Task.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> checkTask(int taskId, {String source = 'cart'}) async {
    final response = await _http.post('/tasks/$taskId/check', data: {
      'source': source,
    });
    return response.data['data'];
  }
}
```

### 4.5 State Management — Gunakan Provider / Riverpod / Bloc

```dart
// Contoh dengan Riverpod
@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getTasks();
  }

  Future<void> checkTask(int taskId, {String source = 'cart'}) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.checkTask(taskId, source: source);
    ref.invalidateSelf(); // reload list
  }
}
```

### 4.6 Error Handling — Tangani Semua Kemungkinan

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  static Future<ApiResponse<T>> guard<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return ApiResponse(success: true, data: data);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Terjadi kesalahan',
      );
    }
  }
}
```

### 4.7 Upload Avatar

```dart
Future<void> updateProfileWithAvatar(File? imageFile) async {
  final formData = FormData();
  if (imageFile != null) {
    formData.files.add(MapEntry(
      'avatar',
      await MultipartFile.fromFile(imageFile.path, filename: 'avatar.jpg'),
    ));
  }
  formData.fields.addAll({
    'name': 'John Updated',
    'birthday': '2000-01-15',
  }.entries);

  final response = await _http.put('/user/profile', data: formData);
}
```

### 4.8 Tips Penting

| Area | Best Practice |
|---|---|
| **Token** | Simpan di `FlutterSecureStorage`, jangan di `SharedPreferences` |
| **Header** | Gunakan Dio interceptor untuk inject token otomatis |
| **Pagination** | Endpoint `session/history` support pagination — gunakan `page` parameter |
| **Date** | Backend pakai `YYYY-MM-DD` untuk tanggal, `YYYY-MM-DD HH:mm:ss` untuk datetime |
| **Error** | Semua error response punya field `message` — tampilkan ke user |
| **Source** | `source: "cart"` untuk todo list, `source: "puzzle"` untuk puzzle page |
| **Avatar** | Kirim sebagai `multipart/form-data`, bukan JSON |
| **Settings** | Field `settings` di user adalah JSON bebas — simpan preferensi theme, notifikasi, dll |

---
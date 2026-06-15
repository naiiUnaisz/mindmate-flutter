# Requirements Document

## Introduction

Fitur ini mengintegrasikan tiga sistem utama — **Puzzle Collection**, **Task Completion**, dan **Coin Management** — agar sepenuhnya _server-driven_, _user-scoped_, dan mendukung _daily reset_ berbasis jam 00:00.

Setelah integrasi selesai:
- Backend (`/api/puzzles`, `/api/tasks/{id}/check`, `/api/daily-record`, `/api/coins/history`) menjadi satu-satunya _source of truth_.
- SharedPreferences hanya digunakan sebagai cache untuk fast-loading saat offline.
- Data puzzle pieces dan task completion status di-reset setiap ganti hari (00:00) berdasarkan tanggal server.
- Semua data ter-isolasi per user melalui prefiks email pada key SharedPreferences.

---

## Glossary

- **App**: Aplikasi Flutter MindMate.
- **Backend**: Server REST API di `https://unaisah-digitallab.my.id/api`.
- **TaskBloc**: BLoC yang mengelola state daftar task dan puzzle harian.
- **ProfileBloc**: BLoC yang mengelola state profil user, koin, streak, dan puzzle collection.
- **ApiClient**: Kelas singleton yang menangani semua HTTP request ke Backend.
- **Task**: Item tugas yang dibuat user, memiliki `taskType` (`'puzzle'` atau `'keranjang'`) dan status completion harian.
- **DailyPuzzleTask**: Task yang ditampilkan di home screen sebagai to-do list hari ini (maks. 6 item).
- **PuzzlePiece**: Satu kepingan puzzle harian milik user dari endpoint `GET /api/puzzles`.
- **DailyPuzzleData**: Agregasi data puzzle hari ini: tanggal, jumlah selesai, flag rest day, dan list `PuzzlePiece`.
- **CoinHistoryItem**: Satu entri riwayat koin dengan field: `id`, `amount`, `status` (`'reward'`|`'expense'`), `description`, `date`.
- **DailyRecord**: Data rekaman aktivitas harian dari endpoint `GET /api/daily-record`.
- **DailyReset**: Proses pembersihan cache task harian dan puzzle pieces saat tanggal berubah (deteksi via perbandingan `DateTime.now().toIso8601String().substring(0,10)` vs tanggal tersimpan).
- **UserEmail**: Email user yang tersimpan di SharedPreferences key `current_user_email`, digunakan sebagai prefiks (lowercase) untuk semua key cache user.
- **source**: Parameter string `'puzzle'` atau `'cart'` yang dikirim ke `POST /api/tasks/{id}/check` untuk membedakan jenis penyelesaian task.
- **isCompletedToday**: Field bool pada `Task` yang menunjukkan apakah task sudah diselesaikan hari ini menurut Backend.
- **isChecked**: Field bool pada `Task` yang merepresentasikan `is_checked` dari Backend (khusus task tipe `'keranjang'`).

---

## Requirements

### Requirement 1: Server-Driven Task Loading dengan Daily Reset

**User Story:** As a user, I want my daily task list to always reflect the latest data from the server, so that my progress is accurate and resets correctly at midnight.

#### Acceptance Criteria

1. WHEN the App calls `LoadTasks`, THE `TaskBloc` SHALL call `GET /api/tasks`, `GET /api/puzzles`, dan `GET /api/daily-record` secara berurutan untuk mendapatkan data hari ini.
2. WHEN `GET /api/tasks` mengembalikan status 200, THE `TaskBloc` SHALL mem-parse setiap item menggunakan `Task.fromMap()` termasuk field `task_type`, `is_completed_today`, dan `is_checked`.
3. WHEN tanggal tersimpan di cache (`UserEmail_daily_puzzle_date`) berbeda dari tanggal hari ini (`DateTime.now().toIso8601String().substring(0,10)`), THE `TaskBloc` SHALL menghapus cache task harian dan mengambil ulang semua data dari Backend (DailyReset).
4. WHEN DailyReset terjadi, THE `TaskBloc` SHALL menyimpan tanggal hari ini ke key `UserEmail_daily_puzzle_date` dan mereset `completedTasksToday` ke 0.
5. IF `GET /api/tasks` gagal atau timeout, THEN THE `TaskBloc` SHALL memuat data dari cache SharedPreferences key `UserEmail_tasks` dan mengembalikan status sukses dengan data cache.
6. WHILE `TaskBloc` sedang memproses `LoadTasks`, THE App SHALL menampilkan `TaskStatus.loading` sehingga UI dapat menampilkan indikator loading.
7. THE `TaskBloc` SHALL menggunakan `UserEmail` (lowercase) sebagai prefiks pada semua SharedPreferences key untuk memastikan Data Isolation antar user.

---

### Requirement 2: Server-Driven Puzzle Pieces di TaskState

**User Story:** As a user, I want my puzzle piece progress on the home screen to reflect exactly what the server says I've earned today, so that I see accurate progress.

#### Acceptance Criteria

1. WHEN `GET /api/puzzles` mengembalikan status 200, THE `TaskBloc` SHALL mem-parse respons menggunakan `DailyPuzzleData.fromMap()` dan menyimpan hasilnya ke `TaskState.dailyPuzzleData`.
2. THE `TaskState` SHALL memuat field `dailyPuzzleData` bertipe `DailyPuzzleData` (default: `DailyPuzzleData.empty`) yang digunakan oleh UI sebagai sumber data puzzle pieces.
3. WHEN `TaskState.dailyPuzzleData.puzzlePieces` berisi data, THE `HomeScreen` SHALL menghitung `completedPieces` dari jumlah `PuzzlePiece` yang memiliki `isOpened == true`.
4. WHEN event `RefreshPuzzles` diterima oleh `TaskBloc`, THE `TaskBloc` SHALL memanggil `GET /api/puzzles` dan memperbarui `TaskState.dailyPuzzleData` dengan data terbaru.
5. IF `GET /api/puzzles` gagal, THEN THE `TaskBloc` SHALL mempertahankan nilai `dailyPuzzleData` yang sudah ada di state tanpa mengubahnya.
6. WHERE `DailyPuzzleData.isRestDay == true`, THE `HomeScreen` SHALL menampilkan indikator rest day pada puzzle section.

---

### Requirement 3: Task Completion dengan Backend Response Parsing

**User Story:** As a user, I want completing a task to immediately update my coins, streak, and puzzle progress based on what the server returns, so that rewards are always correct.

#### Acceptance Criteria

1. WHEN user menyelesaikan task dari DailyPuzzleTask, THE `TaskBloc` SHALL memanggil `POST /api/tasks/{id}/check` dengan parameter `source: 'puzzle'`.
2. WHEN user menyelesaikan task yang hanya ada di main list (bukan DailyPuzzleTask), THE `TaskBloc` SHALL memanggil `POST /api/tasks/{id}/check` dengan parameter `source: 'cart'`.
3. WHEN `POST /api/tasks/{id}/check` mengembalikan status 200, THE `TaskBloc` SHALL mem-parse field `coins_earned`, `current_coin_balance`, `current_streak`, dan `puzzle_opened` dari respons API.
4. WHEN `puzzle_opened == true` dalam respons `POST /api/tasks/{id}/check`, THE `TaskCompletionResult` SHALL memiliki `puzzleOpened == true` dan `isStreakAchieved == true`.
5. AFTER `POST /api/tasks/{id}/check` berhasil, THE `HomeScreen` SHALL memanggil `LoadTasks` dan `LoadProfile` untuk menyinkronkan ulang semua data dari Backend.
6. WHEN `TaskCompletionResult` tersedia di state, THE `HomeScreen` SHALL menampilkan reward dialog yang memuat nilai `coins_earned` dari Backend.
7. WHEN task memiliki `isCompletedToday == true`, THE `HomeScreen` SHALL menampilkan task tersebut dalam keadaan disabled sehingga user tidak dapat menyelesaikannya dua kali.
8. IF `POST /api/tasks/{id}/check` gagal, THEN THE `TaskBloc` SHALL mempertahankan perubahan status completed secara lokal dan tidak menampilkan error ke user.

---

### Requirement 4: Unlock Puzzle Piece via Backend

**User Story:** As a user, I want unlocking a puzzle piece to call the server without any extra parameters, so that the server manages which piece gets unlocked.

#### Acceptance Criteria

1. WHEN event `UnlockPuzzlePiece` diterima oleh `TaskBloc`, THE `TaskBloc` SHALL memanggil `POST /api/puzzles/unlock` tanpa parameter body.
2. WHEN `POST /api/puzzles/unlock` mengembalikan status 200, THE `TaskBloc` SHALL memanggil `RefreshPuzzles` untuk memperbarui `TaskState.dailyPuzzleData`.
3. WHEN event `CollectDailyPuzzle` diterima oleh `ProfileBloc`, THE `ProfileBloc` SHALL memanggil `POST /api/puzzles/unlock` tanpa parameter body melalui `ApiClient.unlockPuzzle()`.
4. THE `ApiClient.unlockPuzzle()` SHALL memanggil `POST /api/puzzles/unlock` tanpa mengirimkan body apapun.
5. IF `POST /api/puzzles/unlock` gagal, THEN THE `TaskBloc` SHALL mempertahankan `dailyPuzzleData` yang ada di state tanpa melempar exception ke UI.

---

### Requirement 5: CoinHistoryItem Model dan Coin Detail Screen

**User Story:** As a user, I want my coin history to be displayed with the correct status badge (reward or expense), so that I can clearly see my earning and spending history.

#### Acceptance Criteria

1. THE `CoinHistoryItem` SHALL memiliki field: `id` (int), `amount` (int), `status` (String: `'reward'`|`'expense'`), `description` (String), dan `date` (DateTime).
2. WHEN `CoinHistoryItem.fromMap()` dipanggil, THE `CoinHistoryItem` SHALL mem-parse field `status` dari key `'status'` atau `'type'` dari map, dengan fallback ke `'reward'`.
3. WHEN `ProfileBloc._onLoadProfile` memproses respons `GET /api/coins/history`, THE `ProfileBloc` SHALL mem-parse setiap item menggunakan `CoinHistoryItem.fromMap()`.
4. WHEN `CoinDetailScreen` menampilkan riwayat koin, THE `CoinDetailScreen` SHALL menggunakan `CoinHistoryItem` untuk menentukan badge status (`'reward'` atau `'expense'`) pada setiap item.
5. WHEN `CoinHistoryItem.status == 'reward'`, THE `CoinDetailScreen` SHALL menampilkan jumlah koin dengan warna hijau dan prefix `+`.
6. WHEN `CoinHistoryItem.status == 'expense'`, THE `CoinDetailScreen` SHALL menampilkan jumlah koin dengan warna merah dan prefix `-`.

---

### Requirement 6: Re-fetch Profile Setelah Earn/Spend Coins

**User Story:** As a user, I want my coin balance to always be in sync with the server after I earn or spend coins, so that my balance is never stale.

#### Acceptance Criteria

1. WHEN `ProfileBloc._onEarnCoins` berhasil memanggil `POST /api/coins/earn`, THE `ProfileBloc` SHALL memanggil `GET /api/user/profile` untuk menyinkronkan `coin_balance` terbaru dari Backend.
2. WHEN `ProfileBloc._onSpendCoins` berhasil memanggil `POST /api/coins/spend`, THE `ProfileBloc` SHALL memanggil `GET /api/user/profile` untuk menyinkronkan `coin_balance` terbaru dari Backend.
3. WHEN `GET /api/user/profile` mengembalikan `coin_balance`, THE `ProfileBloc` SHALL memperbarui `ProfileState.user.coins` dengan nilai dari Backend sebagai _source of truth_.
4. IF `GET /api/user/profile` gagal setelah earn/spend, THEN THE `ProfileBloc` SHALL mempertahankan nilai `coins` yang sudah diperbarui secara optimistis di state lokal.

---

### Requirement 7: Data Flow App Start

**User Story:** As a user, I want the app to load all my data in the correct order when I open it, so that my profile, tasks, puzzles, and coin history are always up-to-date.

#### Acceptance Criteria

1. WHEN App dibuka dan user sudah login, THE App SHALL memanggil endpoint berikut secara berurutan: `GET /api/user/profile` → `GET /api/tasks` → `GET /api/puzzles` → `GET /api/daily-record` → `GET /api/coins/history`.
2. WHEN `GET /api/user/profile` mengembalikan `coin_balance` dan `current_streak`, THE `ProfileBloc` SHALL memperbarui `ProfileState.user.coins` dan `ProfileState.user.streak` dengan data dari Backend.
3. WHEN `GET /api/daily-record` mengembalikan data puzzle pieces, THE `ProfileBloc` SHALL menggabungkan (`merge`) puzzle pieces dari DailyRecord dengan `collectedPuzzles` yang sudah ada.
4. WHILE data sedang dimuat dari Backend pada App start, THE App SHALL menampilkan data cache (jika tersedia) sehingga UI tidak kosong.
5. IF Backend tidak dapat dijangkau saat App dibuka, THEN THE App SHALL menampilkan data dari cache SharedPreferences tanpa menampilkan pesan error ke user.

---

### Requirement 8: Puzzle Widget Berbasis Server Data

**User Story:** As a user, I want the puzzle grid on the home screen to accurately reflect the server-side puzzle pieces, so that what I see matches my actual progress.

#### Acceptance Criteria

1. THE `PuzzleWidget` SHALL menerima parameter opsional `puzzlePieces` bertipe `List<PuzzlePiece>?`.
2. WHEN `puzzlePieces` tidak null dan tidak kosong, THE `PuzzleWidget` SHALL menghitung `completedPieces` dari jumlah item yang memiliki `isOpened == true` di dalam list tersebut.
3. WHEN `puzzlePieces` adalah null atau kosong, THE `PuzzleWidget` SHALL fallback ke parameter `completedPieces` (int) yang sudah ada untuk menjaga kompatibilitas mundur.
4. THE `_PuzzleSection` di `HomeScreen` SHALL meneruskan `taskState.dailyPuzzleData.puzzlePieces` ke `PuzzleWidget` sebagai parameter `puzzlePieces`.

---

### Requirement 9: User-Scoped Cache Isolation

**User Story:** As a developer/operator, I want each user's cached data to be completely isolated from other users, so that data never leaks between accounts on the same device.

#### Acceptance Criteria

1. THE `TaskBloc` SHALL menggunakan format `{userEmail_lowercase}_{key}` untuk semua SharedPreferences key yang menyimpan data task.
2. THE `ProfileBloc` SHALL menggunakan format `{userEmail_lowercase}_{key}` untuk semua SharedPreferences key yang menyimpan data profil, streak, dan coin history.
3. WHEN `ClearTasks` event diterima oleh `TaskBloc`, THE `TaskBloc` SHALL mereset `_userEmail` ke null dan mengembalikan `const TaskState()`.
4. WHEN `ClearProfile` event diterima oleh `ProfileBloc`, THE `ProfileBloc` SHALL mereset semua state yang berhubungan dengan user ke nilai default.
5. WHEN user login dengan akun baru pada perangkat yang sama, THE App SHALL memuat data dari prefiks key yang sesuai dengan email akun baru.

---

### Requirement 10: Verifikasi Build dan Analisis Kode

**User Story:** As a developer, I want all code changes to pass static analysis and build successfully, so that the integration does not introduce regressions.

#### Acceptance Criteria

1. WHEN semua perubahan kode diimplementasikan, THE App SHALL lulus `flutter analyze` tanpa error.
2. WHEN semua perubahan kode diimplementasikan, THE App SHALL berhasil di-build menggunakan `flutter build apk --debug` tanpa error kompilasi.
3. THE semua model (`Task`, `PuzzlePiece`, `DailyPuzzleData`, `CoinHistoryItem`) SHALL memiliki `fromMap()` yang dapat mem-parse field dari API response tanpa melempar exception untuk field yang tidak ada (menggunakan null-safe fallback).

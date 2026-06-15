# Bugfix Requirements Document

## Introduction

Bug ini terjadi pada sistem puzzle collection dimana semua puzzle pieces langsung terbuka (unlocked) sekaligus ketika user menyelesaikan tasks dan mengumpulkan puzzle pieces. Hal ini melanggar aturan bisnis yang mensyaratkan hanya 1 puzzle yang boleh dibuka per hari. Bug ini berdampak pada:
- Hilangnya mekanisme pembatasan harian yang menjadi core mechanic dari fitur puzzle collection
- User mendapatkan akses ke semua puzzle sekaligus tanpa menunggu hari berikutnya
- Tidak ada isolation data puzzle per user, berpotensi terjadi data leakage antar user

Bug ini terjadi pada aplikasi Flutter dengan BLoC pattern yang terintegrasi dengan backend API untuk manajemen puzzle pieces.

---

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN user menyelesaikan 6 tasks dan mendapatkan 6 puzzle pieces THEN semua puzzle langsung terbuka (unlocked) sekaligus tanpa pembatasan harian

1.2 WHEN user mengakses puzzle collection setelah menyelesaikan tasks THEN sistem tidak memeriksa pembatasan 1 puzzle per hari

1.3 WHEN multiple users menggunakan aplikasi pada device yang sama THEN data puzzle unlock tidak terisolasi per user sehingga berpotensi terjadi data leakage

1.4 WHEN user membuka puzzle pada hari yang sama setelah sudah membuka 1 puzzle THEN sistem tetap mengizinkan membuka puzzle tambahan

### Expected Behavior (Correct)

2.1 WHEN user menyelesaikan tasks dan mendapatkan puzzle pieces THEN sistem SHALL hanya membuka maksimal 1 puzzle per hari (daily unlock limit)

2.2 WHEN user mengakses puzzle collection THEN sistem SHALL memvalidasi apakah user sudah membuka 1 puzzle hari ini sebelum mengizinkan unlock puzzle berikutnya

2.3 WHEN multiple users menggunakan aplikasi pada device yang sama THEN sistem SHALL mengisolasi data puzzle unlock per user menggunakan email sebagai identifier

2.4 WHEN user sudah membuka 1 puzzle pada hari tertentu THEN sistem SHALL menolak request unlock puzzle tambahan untuk hari yang sama dan menampilkan pesan bahwa limit harian telah tercapai

2.5 WHEN user mengakses puzzle collection pada hari berikutnya (setelah midnight/00:00) THEN sistem SHALL mereset daily unlock counter dan mengizinkan user membuka 1 puzzle lagi

### Unchanged Behavior (Regression Prevention)

3.1 WHEN user menyelesaikan task dan mendapatkan puzzle piece THEN sistem SHALL CONTINUE TO memberikan puzzle piece dan menampilkannya di puzzle collection

3.2 WHEN user belum membuka puzzle sama sekali pada hari tertentu THEN sistem SHALL CONTINUE TO mengizinkan unlock 1 puzzle pertama

3.3 WHEN user melihat daftar puzzle di puzzle collection THEN sistem SHALL CONTINUE TO menampilkan puzzle pieces yang sudah dikumpulkan dengan status locked/unlocked yang benar

3.4 WHEN backend mengembalikan data puzzle pieces dari endpoint `GET /api/puzzles` THEN sistem SHALL CONTINUE TO mem-parse dan menampilkan data tersebut dengan format yang sama

3.5 WHEN user memanggil `POST /api/puzzles/unlock` THEN sistem SHALL CONTINUE TO memanggil endpoint tersebut tanpa parameter body (server-managed unlock)

3.6 WHEN daily reset terjadi pada midnight (00:00) THEN sistem SHALL CONTINUE TO mereset task completion dan puzzle data berdasarkan perbandingan tanggal

---

## Bug Condition Derivation

### Bug Condition Function

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type PuzzleUnlockRequest
  OUTPUT: boolean
  
  // X contains:
  // - userId: string (user email)
  // - currentDate: string (YYYY-MM-DD)
  // - unlockedTodayCount: integer (jumlah puzzle yang sudah di-unlock hari ini)
  
  // Bug condition: user sudah unlock >= 1 puzzle hari ini tapi sistem masih mengizinkan unlock
  RETURN X.unlockedTodayCount >= 1
END FUNCTION
```

### Property Specification: Fix Checking

```pascal
// Property: Daily Unlock Limit Enforcement
FOR ALL X WHERE isBugCondition(X) DO
  result ← unlockPuzzle'(X)
  ASSERT result.success = FALSE 
    AND result.errorMessage = "Daily unlock limit reached"
    AND X.unlockedTodayCount UNCHANGED
END FOR
```

**Key Definitions:**
- **F (unlockPuzzle)**: Fungsi original yang mengizinkan unlock tanpa validasi daily limit
- **F' (unlockPuzzle')**: Fungsi yang sudah diperbaiki dengan validasi daily unlock limit

### Property Specification: Preservation Checking

```pascal
// Property: Normal Unlock Masih Berfungsi
FOR ALL X WHERE NOT isBugCondition(X) DO
  // X.unlockedTodayCount = 0 (belum unlock hari ini)
  ASSERT unlockPuzzle(X) = unlockPuzzle'(X)
    AND result.success = TRUE
    AND X.unlockedTodayCount = 1 (after unlock)
END FOR
```

### Concrete Counterexample

**Scenario**: User sudah unlock 1 puzzle hari ini, kemudian mencoba unlock puzzle kedua

```
Input X:
  userId: "user@example.com"
  currentDate: "2025-06-15"
  unlockedTodayCount: 1
  
Current Behavior F(X):
  → success: true
  → puzzleUnlocked: true
  → unlockedTodayCount: 2
  → Bug: sistem tidak memvalidasi daily limit
  
Expected Behavior F'(X):
  → success: false
  → errorMessage: "Daily unlock limit reached. Come back tomorrow!"
  → unlockedTodayCount: 1 (unchanged)
  → Fix: sistem menolak unlock dan mempertahankan counter
```

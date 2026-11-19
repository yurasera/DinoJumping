# Panduan Membaca Codebase DinoJumping

Project ini memakai struktur sederhana berbasis tanggung jawab. MVVM belum diperlukan karena game loop, physics, dan collision dikelola langsung oleh SpriteKit.

## Struktur folder

```text
DinoJumping/
├── CODEBASE_GUIDE.md
├── App/
│   ├── App.swift
│   └── MainView.swift
└── Game/
    ├── Game.swift
    ├── Game+Setup.swift
    ├── Game+Flow.swift
    └── Game+Obstacles.swift
```

Nama file dibuat singkat, tetapi nama type `DinoGameScene` tetap dipertahankan agar kode tidak berubah tanpa alasan.

## Urutan membaca

```text
1. App/App.swift
2. App/MainView.swift
3. Game/Game.swift
4. Game/Game+Setup.swift
5. Game/Game+Flow.swift
6. Game/Game+Obstacles.swift
```

## 1. Folder App

### App/App.swift

Entry point aplikasi.

```text
App
  └── WindowGroup
        └── MainView
```

File ini membuka `MainView` saat aplikasi dijalankan.

### App/MainView.swift

Menghubungkan SwiftUI dengan SpriteKit.

```text
MainView
  ├── SpriteView
  │     └── DinoGameScene
  └── Button "MULAI / LOMPAT"
        └── gameScene.jump()
```

Satu tombol digunakan untuk tiga kondisi:

```text
ready    → mulai game
playing  → lompat
gameOver → mulai ulang
```

## 2. Folder Game

### Game/Game.swift

File inti scene. Isinya:

- State game
- Physics category
- Konfigurasi dasar
- Player dan HUD
- Lifecycle SpriteKit
- Game loop
- Input
- Collision

Status game:

```text
ready → playing → gameOver
  ↑                 │
  └─────────────────┘
       tekan tombol
```

Saat scene tampil, `didMove(to:)` menyiapkan background, HUD, player, dan overlay.

Saat game berjalan, `update(_:)` dipanggil berulang kali untuk memperbarui skor dan rintangan.

### Game/Game+Setup.swift

Membuat tampilan game:

| Fungsi | Tugas |
| --- | --- |
| `createBackground()` | Membuat background |
| `addStars()` | Membuat bintang |
| `addGround()` | Membuat tanah dan physics ground |
| `createHUD()` | Membuat label skor |
| `createPlayer()` | Membuat Dino |
| `addPlayerFoot(at:)` | Membuat kaki Dino |

Gunakan file ini untuk mengubah bentuk Dino, warna, background, atau HUD.

### Game/Game+Flow.swift

Mengatur aksi permainan:

| Fungsi | Tugas |
| --- | --- |
| `jump()` | Mulai, lompat, atau mengulang game |
| `startGame()` | Mereset dan memulai game |
| `endGame()` | Mengakhiri game setelah collision |
| `showOverlay(title:message:)` | Menampilkan pesan |
| `updateScore()` | Menghitung skor dan kecepatan |
| `updateScoreLabels()` | Memperbarui teks skor |

Player diam sebelum mulai karena physics-nya nonaktif. Physics diaktifkan oleh `startGame()`.

### Game/Game+Obstacles.swift

Mengatur rintangan:

```text
update()
  └── createObstacleWhenNeeded()
        └── createObstacle()
              ├── createCactus()
              └── createBird()
```

| Fungsi | Tugas |
| --- | --- |
| `getDeltaTime()` | Menghitung waktu antar-frame |
| `createObstacleWhenNeeded()` | Menentukan waktu spawn |
| `moveObstacles()` | Menggerakkan rintangan |
| `createObstacle()` | Memilih jenis rintangan |
| `createCactus()` | Membuat kaktus |
| `createBird()` | Membuat burung |
| `addObstaclePhysics()` | Menambahkan physics |
| `removeObstacles()` | Menghapus rintangan saat reset |

## Alur lengkap

```text
App/App.swift
  ↓
App/MainView.swift
  ↓
SpriteView menampilkan DinoGameScene
  ↓
didMove(to:) menyiapkan scene
  ↓
Player diam di state ready
  ↓
Tekan "MULAI / LOMPAT"
  ↓
jump() memanggil startGame()
  ↓
Physics player aktif
  ↓
update(_:) menjalankan game loop
  ↓
Rintangan muncul dan bergerak
  ↓
Player melompat
  ↓
Collision memanggil endGame()
  ↓
State menjadi gameOver
```

## Menampilkan atau menyembunyikan object

Buka `Game/Game.swift`, lalu ubah nilai pada bagian:

```swift
var showBackground = true
var showStars = true
var showGround = true
var showHUD = true
var showPlayer = true
var showObstacles = true
var showOverlay = true
```

Gunakan:

- `true` untuk menampilkan object
- `false` untuk menyembunyikan object

Contoh:

```swift
var showStars = false
var showObstacles = false
```

Hasilnya:

- Bintang tidak ditampilkan.
- Rintangan tidak dibuat.
- Player dan physics tetap tersedia untuk dipelajari.

Toggle ini dibaca saat scene dibuat. Setelah mengubah nilai, jalankan ulang aplikasi agar hasilnya terlihat.

| Toggle | Object yang dikontrol | File pembuat object |
| --- | --- | --- |
| `showBackground` | Warna langit | `Game+Setup.swift` |
| `showStars` | Bintang | `Game+Setup.swift` |
| `showGround` | Tanah dan garis tanah | `Game+Setup.swift` |
| `showHUD` | Skor dan best score | `Game+Setup.swift` |
| `showPlayer` | Dino | `Game+Setup.swift` |
| `showObstacles` | Kaktus dan burung | `Game+Obstacles.swift` |
| `showOverlay` | Panel awal dan game over | `Game+Flow.swift` |

## Perubahan sederhana

### Mengubah teks tombol

Edit `App/MainView.swift`.

Cari:

```swift
Text("MULAI / LOMPAT")
```

### Mengubah kekuatan lompatan

Edit `Game/Game.swift`.

Cari:

```swift
let jumpPower: CGFloat = 720
```

### Mengubah kecepatan awal

Edit `Game/Game.swift`.

Cari:

```swift
let initialSpeed: CGFloat = 310
```

### Mengubah bentuk Dino

Edit `Game/Game+Setup.swift`, lalu buka `createPlayer()`.

### Mengubah bentuk rintangan

Edit `Game/Game+Obstacles.swift`.

Gunakan `createCactus()` untuk kaktus dan `createBird()` untuk burung.

## Ringkasan

```text
App/
  └── Menjalankan aplikasi dan menampilkan game

Game/
  ├── Game.swift
  │     └── State, lifecycle, update, input, physics
  ├── Game+Setup.swift
  │     └── Background, HUD, dan player
  ├── Game+Flow.swift
  │     └── Start, jump, game over, overlay, skor
  └── Game+Obstacles.swift
        └── Spawn, gerak, dan physics rintangan
```

Untuk memahami fitur tertentu, cari fungsi yang memulai alurnya lalu ikuti fungsi yang dipanggil dari sana.

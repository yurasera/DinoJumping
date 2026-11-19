# Panduan Membaca Codebase DinoJumping

Project ini memakai struktur sederhana. Tidak ada MVVM tambahan karena `SKScene` sudah menjadi tempat yang tepat untuk game loop, physics, collision, dan state game.

## Struktur folder

```text
DinoJumping/
├── App/
│   ├── App.swift
│   └── MainView.swift
└── Game/
    ├── Game.swift
    ├── Background.swift
    ├── Player.swift
    ├── HUD.swift
    ├── Overlay.swift
    ├── Flow.swift
    └── Obstacles.swift
```

Setiap file Game memiliki satu tanggung jawab utama.

## Urutan membaca

```text
1. App/App.swift
2. App/MainView.swift
3. Game/Game.swift
4. Game/Background.swift
5. Game/Player.swift
6. Game/Flow.swift
7. Game/Obstacles.swift
8. Game/HUD.swift
9. Game/Overlay.swift
```

## Folder App

### App/App.swift

Entry point aplikasi. File ini membuka `MainView`.

```text
App
  └── WindowGroup
        └── MainView
```

### App/MainView.swift

Menghubungkan SwiftUI dengan SpriteKit.

```text
MainView
  ├── SpriteView
  │     └── DinoGameScene
  └── Button "MULAI / LOMPAT"
        └── gameScene.jump()
```

Satu tombol memiliki tiga perilaku:

```text
ready    → mulai game
playing  → lompat
gameOver → mulai ulang
```

## Game/Game.swift

Ini adalah file utama scene. Isinya hanya pengatur umum:

- State game
- Physics category
- Konfigurasi game
- Object utama seperti player, label, dan overlay
- Lifecycle SpriteKit
- Game loop
- Input
- Collision

### State game

```swift
ready → playing → gameOver
  ↑                 │
  └─────────────────┘
       tekan tombol
```

### Lifecycle

`didMove(to:)` dipanggil saat scene tampil. Fungsi ini memanggil fungsi pembuat object dari file lain.

### Game loop

`update(_:)` dipanggil berulang kali oleh SpriteKit.

```text
update()
  ├── berhenti jika state bukan playing
  ├── menghitung waktu
  ├── memperbarui skor
  ├── menggerakkan rintangan
  └── membuat rintangan baru
```

## Game/Background.swift

Mengurus semua object background:

- Sky
- Stars
- Ground
- Ground line
- Ground physics

Fungsi utama:

| Fungsi | Tugas |
| --- | --- |
| `createBackground()` | Membuat background utama |
| `addStars()` | Membuat bintang |
| `addGround()` | Membuat tanah dan physics ground |

## Game/Player.swift

Mengurus semua hal yang berhubungan dengan Dino:

- Sprite player
- Texture sprite sheet
- Physics player
- Idle frame
- Animasi lari

Fungsi utama:

| Fungsi | Tugas |
| --- | --- |
| `createPlayer()` | Membuat Dino dan physics |
| `dinoTexture(frame:)` | Mengambil satu frame dari `dino.png` |
| `startIdleAnimation()` | Menampilkan frame idle diam |
| `startPlayerRunning()` | Memutar 8 frame animasi lari |
| `stopPlayerRunning()` | Menghentikan animasi dan kembali ke idle |

Player dibuat diam sebelum mulai:

```swift
player.physicsBody?.isDynamic = false
```

Physics diaktifkan di `startGame()`.

## Game/Flow.swift

Mengurus alur permainan:

- Lompat
- Mulai game
- Game over
- Start/stop animasi player
- Perhitungan skor

Fungsi utama:

| Fungsi | Tugas |
| --- | --- |
| `jump()` | Memulai, melompat, atau mengulang game |
| `startGame()` | Mereset dan menjalankan game |
| `endGame()` | Menghentikan game setelah collision |
| `updateScore()` | Menghitung skor dan kecepatan |

## Game/Obstacles.swift

Mengurus semua rintangan:

- Spawn timer
- Pergerakan rintangan
- Kaktus
- Burung
- Physics rintangan

Fungsi utama:

| Fungsi | Tugas |
| --- | --- |
| `getDeltaTime()` | Menghitung waktu antar-frame |
| `createObstacleWhenNeeded()` | Menentukan waktu spawn |
| `moveObstacles()` | Menggerakkan rintangan |
| `createObstacle()` | Memilih kaktus atau burung |
| `createCactus()` | Membuat kaktus |
| `createBird()` | Membuat burung |
| `addObstaclePhysics()` | Menambahkan physics |
| `removeObstacles()` | Menghapus rintangan saat reset |

## Game/HUD.swift

Mengurus skor dan best score:

- Label score
- Label best score
- Menampilkan teks skor

Fungsi utama:

- `createHUD()`
- `updateScoreLabels()`

## Game/Overlay.swift

Mengurus panel informasi awal dan game over.

Fungsi utama:

- `showOverlay(title:message:)`
- `addOverlayLabel(...)`

## Toggle untuk belajar

Toggle berada di bagian atas `Game.swift`:

```swift
var showBackground = true
var showStars = false
var showGround = true
var showHUD = false
var showPlayer = true
var showObstacles = false
var showOverlay = false
```

Gunakan:

- `true` untuk mengaktifkan object
- `false` untuk menonaktifkan object

Saat ini project sengaja fokus pada player:

- Stars nonaktif
- HUD nonaktif
- Obstacles nonaktif
- Overlay nonaktif
- Background, ground, dan player aktif

Beberapa pemanggilan yang nonaktif sudah diberi komentar di source code agar mudah dipelajari. Untuk mengaktifkannya lagi, ubah toggle menjadi `true` dan hapus komentar pemanggilannya jika diperlukan.

## Alur lengkap

```text
App/App.swift
  ↓
App/MainView.swift
  ↓
SpriteView menampilkan DinoGameScene
  ↓
Game.swift menyiapkan scene
  ↓
Background.swift membuat background
  ↓
Player.swift membuat Dino
  ↓
Player diam di state ready
  ↓
Tekan "MULAI / LOMPAT"
  ↓
Flow.swift menjalankan startGame()
  ↓
Player.swift memutar animasi lari
  ↓
Game.swift menjalankan update()
  ↓
Obstacles.swift membuat rintangan jika diaktifkan
  ↓
Collision memanggil endGame()
```

## Perubahan sederhana

### Mengubah sprite player

Edit `Player.swift`.

Asset berada di:

```text
Assets.xcassets/dino.imageset/dino.png
```

Sprite sheet memiliki 8 frame horizontal.

### Mengubah kecepatan animasi player

Edit `Game.swift`:

```swift
let playerRunDuration: TimeInterval = 0.12
```

Nilai lebih kecil membuat animasi lebih cepat.

### Mengubah kekuatan lompatan

Edit `Game.swift`:

```swift
let jumpPower: CGFloat = 720
```

### Mengubah warna atau bentuk background

Edit `Background.swift`.

### Mengubah bentuk rintangan

Edit `Obstacles.swift`.

### Mengubah teks tombol

Edit `App/MainView.swift`.

## Ringkasan

```text
App/
  └── Menjalankan aplikasi dan menampilkan game

Game/
  ├── Game.swift
  │     └── Pengatur utama
  ├── Background.swift
  │     └── Background, stars, dan ground
  ├── Player.swift
  │     └── Dino, texture, dan animasi
  ├── HUD.swift
  │     └── Score dan best score
  ├── Overlay.swift
  │     └── Panel informasi
  ├── Flow.swift
  │     └── Start, jump, dan game over
  └── Obstacles.swift
        └── Kaktus, burung, dan physics rintangan
```

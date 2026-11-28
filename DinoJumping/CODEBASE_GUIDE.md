# Panduan Membaca Codebase DinoJumping

Dokumen ini mengikuti struktur proyek yang saat ini digunakan. DinoJumping memakai SwiftUI sebagai lapisan tampilan dan SpriteKit sebagai mesin game. `DinoGameScene` menangani game loop, pergerakan, physics, collision, skor, serta lifecycle permainan.

## Struktur folder

```text
DinoJumping/
├── App/
│   ├── App.swift
│   └── GameMainView.swift
├── Configuration/
│   ├── GameState.swift
│   ├── GameViewTheme.swift
│   └── PhysicsCategory.swift
├── Nodes/
│   ├── CloudNode.swift
│   ├── FireballNode.swift
│   ├── GroundNode.swift
│   ├── ObstacleNode.swift
│   └── PlayerNode.swift
├── Scenes/
│   └── DinoGameScene.swift
├── UI/
│   └── GameOverlay.swift
├── Assets.xcassets
└── CODEBASE_GUIDE.md
```

## Tanggung jawab tiap folder

| Folder | Tanggung jawab |
| --- | --- |
| `App/` | Entry point aplikasi dan komposisi tampilan SwiftUI dengan SpriteKit. |
| `Configuration/` | State permainan, kategori physics, dan tema warna background. |
| `Nodes/` | Node SpriteKit yang dapat digunakan oleh scene: player, ground, cloud, dan obstacle. |
| `Scenes/` | Scene utama dan koordinasi seluruh gameplay. |
| `UI/` | Overlay SwiftUI untuk state awal dan game over. |
| `Assets.xcassets` | Asset visual yang digunakan oleh node dan tampilan game. |

## Urutan membaca yang disarankan

1. `App/App.swift`
2. `Configuration/GameState.swift`
3. `Configuration/PhysicsCategory.swift`
4. `Configuration/GameViewTheme.swift`
5. `App/GameMainView.swift`
6. `UI/GameOverlay.swift`
7. `Nodes/PlayerNode.swift`
8. `Nodes/GroundNode.swift`
9. `Nodes/CloudNode.swift`
10. `Nodes/ObstacleNode.swift`
11. `Nodes/FireballNode.swift`
12. `Scenes/DinoGameScene.swift`

Urutan ini dimulai dari entry point dan kontrak dasar, kemudian UI, node individual, dan terakhir orkestrasi gameplay.

## Lapisan aplikasi

### `App/App.swift`

Entry point SwiftUI. `WindowGroup` menampilkan `GameMainView`.

```text
DinoJumpingApp
  └── WindowGroup
        └── GameMainView
```

### `App/GameMainView.swift`

Menghubungkan SwiftUI dengan `DinoGameScene`.

Tanggung jawab utama:

- Membuat scene berukuran awal 900 × 500.
- Menampilkan background dinamis melalui `TimelineView` dan `GameViewTheme`.
- Menampilkan scene SpriteKit melalui `SpriteView`.
- Menampilkan skor dan high score.
- Menampilkan tombol lompat ketika permainan aktif.
- Menampilkan `GameOverlay` ketika state masih `ready` atau sudah `gameOver`.
- Menerima callback perubahan state dan skor dari scene.
- Membaca high score dari `UserDefaults` dengan key `DinoJumping.highScore`.

Alur komponen tampilannya:

```text
GameMainView
├── TimelineView
│   └── GameViewTheme.background(for:)
├── SpriteView
│   └── DinoGameScene
├── ScoreBoard
├── JumpButton              jika state = playing
└── GameOverlay             jika state = ready atau gameOver
```

## Konfigurasi

### `Configuration/GameState.swift`

Mendefinisikan tiga state permainan:

```text
ready → playing → gameOver
  ↑                    │
  └──── restart ───────┘
```

- `ready`: permainan belum dimulai.
- `playing`: game loop aktif dan player dapat melompat.
- `gameOver`: permainan berhenti setelah player jatuh atau terkena obstacle.

### `Configuration/PhysicsCategory.swift`

Menyediakan bit mask untuk collision SpriteKit:

| Kategori | Nilai | Kegunaan |
| --- | --- | --- |
| `player` | `1 << 0` | Physics body Dino. |
| `ground` | `1 << 1` | Physics body tanah. |
| `obstacle` | `1 << 2` | Obstacle dan fireball. |

Kategori ini dipakai oleh `PlayerNode`, `GroundNode`, `ObstacleNode`, `FireballNode`, dan `DinoGameScene`.

### `Configuration/GameViewTheme.swift`

Menyediakan warna langit berdasarkan waktu saat ini.

- `background(for:)` mengembalikan warna SwiftUI.
- `spriteKitBackground(for:)` mengembalikan warna SpriteKit.
- Warna bertransisi antara malam, pagi, siang, dan sore.
- Fungsi internal `blend(from:to:progress:)` melakukan interpolasi warna.

## Node SpriteKit

### `Nodes/PlayerNode.swift`

Mewakili Dino sebagai `SKSpriteNode`.

Tanggung jawab:

- Memuat asset sprite sheet `dino`.
- Memotong sprite sheet menjadi 8 frame horizontal.
- Membuat physics body player.
- Menonaktifkan rotasi player.
- Menetapkan collision dan contact mask.
- Menjalankan animasi lari berulang.

Fungsi penting:

| Fungsi | Tugas |
| --- | --- |
| `init()` | Membuat sprite dan physics player. |
| `texture(forFrame:)` | Mengambil satu frame dari sprite sheet. |
| `startRunningAnimation(speedMultiplier:)` | Menjalankan animasi lari 8 frame. |

Player dibuat tidak dinamis saat inisialisasi. Scene mengaktifkan physics saat `startGame()`.

### `Nodes/GroundNode.swift`

Mewakili tanah dan visual terrain yang dapat bergerak.

Tanggung jawab:

- Mengulang tile terrain sepanjang lantai.
- Menambahkan physics body ground pada tile.
- Menggeser tile secara horizontal.
- Mengembalikan posisi tile saat restart.
- Membuat dan memulihkan gap tanah pada skor tertentu.

Fungsi penting:

| Fungsi | Tugas |
| --- | --- |
| `startScrolling(speed:)` | Memulai pergerakan visual tanah. |
| `stopScrolling()` | Menghentikan pergerakan tanah. |
| `resetScrolling()` | Mengembalikan tile ke posisi awal. |
| `createGapAtRightEdge(sceneWidth:count:)` | Membuat celah di sisi kanan lantai. |
| `restoreGap()` | Mengembalikan tile yang dihilangkan. |

Physics ground tetap berada pada node tile, sehingga pergerakan visual dan collision dapat dikontrol secara terpisah.

### `Nodes/CloudNode.swift`

Mewakili satu awan yang bergerak sebagai dekorasi foreground.

- Menggunakan asset cloud yang diberikan oleh scene.
- Menyimpan posisi awal untuk kebutuhan reset.
- Bergerak horizontal dan wrap kembali ke sisi kanan.
- Berada di depan matahari dan bulan melalui `zPosition`.

### `Nodes/ObstacleNode.swift`

Mewakili obstacle berbasis sprite.

- Memilih salah satu rangkaian frame asset `sawit` secara acak.
- Memiliki physics body statis.
- Menggunakan nama node `obstacle`.
- Memutar animasi obstacle.
- Menyediakan delay spawn acak melalui `nextSpawnDelay()`.

### `Nodes/FireballNode.swift`

Mewakili obstacle fireball berbasis `SKShapeNode`, bukan image asset.

- Terdiri dari glow luar, bola api, core, dan flame.
- Menggunakan physics body berbentuk lingkaran.
- Memakai kategori physics `obstacle`.
- Memiliki animasi pulse agar terlihat menyala.

## Scene utama

### `Scenes/DinoGameScene.swift`

Ini adalah pusat koordinasi game. Scene mewarisi `SKScene` dan mengimplementasikan `SKPhysicsContactDelegate`.

State dan data utama yang dikelola:

- `gameState`
- `score` dan `highScore`
- `gameStartTime`
- `gameSpeedMultiplier`
- `canJump`
- `groundContactCount`
- `ground`, `player`, `clouds`, `sun`, dan `moon`
- Jadwal pembuatan obstacle dan gap ground

Scene mengirim perubahan ke SwiftUI melalui dua callback:

```swift
var onGameStateChange: ((GameState) -> Void)?
var onScoreChange: ((Int, Int) -> Void)?
```

### Setup scene

Saat scene ditampilkan, scene menyiapkan:

1. Background SpriteKit.
2. Matahari dan bulan.
3. Ground berbasis tile.
4. Awan.
5. Player.
6. Physics contact delegate.

Fungsi setup yang relevan:

- `addSun()`
- `addMoon()`
- `addMoonCrater(to:position:radius:)`
- `updateSunPosition()`
- `addGround()`
- `addClouds()`
- `addPlayer()`

### Siklus permainan

```text
GameMainView
  ↓
GameOverlay menekan MULAI
  ↓
DinoGameScene.startGame()
  ↓
state = playing
  ↓
player, ground, dan cloud mulai bergerak
  ↓
obstacle dibuat berkala
  ↓
update(_:) memperbarui waktu dan skor
  ↓
jump() membuat player melompat
  ↓
collision atau jatuh memanggil showGameOver()
  ↓
GameOverlay menampilkan GAME OVER
  ↓
restartGame() menghapus obstacle dan memulai ulang
```

### Fungsi gameplay penting

| Fungsi | Tugas |
| --- | --- |
| `startGame()` | Mengatur state aktif, mereset skor, mengaktifkan physics player, dan memulai pergerakan. |
| `update(_:)` | Menghitung skor, meningkatkan kecepatan pada skor 1000, dan menjadwalkan gap ground. |
| `jump()` | Menjalankan lompatan berbentuk arc dan haptic feedback saat lepas landas serta mendarat. |
| `publishScore()` | Mengirim skor dan high score ke SwiftUI. |
| `didBegin(_:)` | Mendeteksi kontak dengan ground atau obstacle. |
| `didEnd(_:)` | Memperbarui status kontak player dengan ground. |
| `showGameOver()` | Menghentikan seluruh gerakan dan mengubah state menjadi `gameOver`. |
| `restartGame()` | Menghapus obstacle, mereset posisi, mereset ground, lalu memanggil `startGame()`. |

### Spawn obstacle

`spawnObstacle()` memilih obstacle secara acak:

- `FireballNode` dengan posisi vertikal acak.
- `ObstacleNode` pada jalur tanah.

Obstacle bergerak dari sisi kanan ke kiri dan dihapus setelah keluar dari scene. Saat ground gap akan dibuat, scene menunggu sampai area kanan cukup aman, menghentikan spawn sementara, lalu mengaktifkan kembali spawn setelah gap dilewati.

### Skor dan kesulitan

- Skor dihitung dari durasi permainan aktif.
- High score disimpan di `UserDefaults`.
- Pada skor 1000, `gameSpeedMultiplier` berubah dari 1 menjadi 1.25.
- Kecepatan player, ground, cloud, dan obstacle disesuaikan dengan multiplier.
- Gap ground dibuat secara berkala mulai dari skor 200 dengan interval skor 60.

## UI

### `UI/GameOverlay.swift`

Overlay SwiftUI yang ditampilkan ketika game belum aktif.

Untuk state `ready`, overlay menampilkan:

- Judul DINO JUMPING.
- Instruksi menghindari obstacle.
- High score.
- Tombol `MULAI`.

Untuk state `gameOver`, overlay menampilkan:

- Judul GAME OVER.
- Skor terakhir.
- High score.
- Tombol `RESTART`.

Saat state `playing`, overlay mengembalikan `EmptyView`.

## Asset

Asset dipakai melalui nama image dalam kode SpriteKit. Beberapa nama yang digunakan:

- `dino`: sprite sheet player dengan 8 frame.
- `Terrain`: sprite sheet tile ground.
- `Clouds_01` sampai `Clouds_07`: variasi awan.
- `sawit`, `sawit2`, `sawit3`, `sawit4`, `sawit5`: frame animasi obstacle.

Jika mengganti asset, pertahankan nama image yang dipanggil kode atau perbarui pemanggilannya pada node terkait.

## Perubahan umum

### Mengubah tampilan background

Edit `Configuration/GameViewTheme.swift`. Atur nilai warna `night`, `morning`, `day`, dan `evening`.

### Mengubah animasi player

Edit `Nodes/PlayerNode.swift`.

- Jumlah frame diatur oleh `frameCount`.
- Durasi tiap frame diatur pada `timePerFrame`.
- Asset sprite sheet dibaca dengan nama `dino`.

### Mengubah bentuk atau perilaku obstacle

- Obstacle sprite: edit `Nodes/ObstacleNode.swift`.
- Fireball: edit `Nodes/FireballNode.swift`.
- Jadwal dan posisi spawn: edit `Scenes/DinoGameScene.swift`.

### Mengubah gerakan ground atau gap

Edit `Nodes/GroundNode.swift` untuk perilaku tile dan physics. Edit `Scenes/DinoGameScene.swift` untuk kapan gap dibuat dan berapa lama obstacle ditahan.

### Mengubah overlay atau kontrol

- Overlay awal dan game over: edit `UI/GameOverlay.swift`.
- Scoreboard dan tombol lompat: edit `App/GameMainView.swift`.

## Ringkasan arsitektur

```text
SwiftUI
├── GameMainView
│   ├── ScoreBoard
│   ├── JumpButton
│   └── GameOverlay
│
└── SpriteKit
    └── DinoGameScene
        ├── PlayerNode
        ├── GroundNode
        ├── CloudNode
        ├── ObstacleNode
        └── FireballNode

Configuration
├── GameState
├── PhysicsCategory
└── GameViewTheme
```

Prinsip pembagian tanggung jawabnya sederhana: SwiftUI mengatur komposisi UI dan callback state, node mengatur bentuk serta perilaku objek SpriteKit individual, sedangkan `DinoGameScene` mengatur aturan permainan dan hubungan antarobjek.

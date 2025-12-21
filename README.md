## 👥 Nama Anggota
- Muhammad Rifqi Ilham (2406495483)
- Valerian Hizkia Emmanuel (2406495382)
- Faris Huda (2406421970)
- Geraldus Catur Gigih Wahyudi (2406496113)
- Fathan Alfahrezi (2406496284)

## 🔗 Tautan Aplikasi
- TBA

## ⚽ MatchPlay Flutter

Matchplay adalah website yang membantu pengguna menemukan tempat olahraga sekaligus teman bermain di sekitar mereka. Dengan fitur matchmaking dan booking lapangan secara online, Matchplay memudahkan pemain untuk tetap aktif berolahraga, walaupun jika mereka belum memiliki teman bermain atau rekan main.

Sistem Matchmaking memungkinkan pengguna menemukan lawan atau teman bermain. Saat pengguna melakukan matchmaking, maka sistem akan menandai slot waktu lapangan sebagai pending. Jika jumlah pemain terpenuhi sebelum waktu cut off, sistem akan mengonfirmasi booking dan mengunci slot tersebut. Dengan mekanisme ini, Matchplay dapat memberikan kesempatan yang adil bagi pengguna yang bermain sendiri melalui matchmaking maupun bagi team yang siap melakukan booking secara langsung.

## 💡 Manfaat
- Mempermudah booking lapangan secara praktis dan real-time melalui web.
- Membantu menemukan partner atau teman bermain untuk olahraga berkelompok.
- Penyewaan perlengkapan olahraga yang lebih efisien.
- Meningkatkan pendapatan pengelola lapangan.
- Sistem manajemen yang lebih terorganisir dan praktis untuk pengelola lapangan maupun penyewa lapangan.

## 🧰 Modul-Modul Matchplay
Aplikasi ini dibagi menjadi beberapa modul.

| Nama Modul | Fungsi | Pembuat |
|------------|--------|---------|
| ```main``` | Modul ini berfungsi untuk mengurus halaman utama website. | Valerian Hizkia Emmanuel |
| ```authentication``` | Modul ini nantinya akan berfungsi untuk mengurus segala macam autentikasi yang terdapat di aplikasi ini. Mau itu dari pengguna biasa ataupun pemilik lapangan. Modul ini juga nantinya mengurus perizinan (authorization) yang dimiliki oleh seorang pengguna. | Seluruh Anggota |
|```fields```| Modul ini berfungsi untuk mengurus model dari lapangan. | Faris Huda |
|```dashboard```| Modul ini berfungsi untuk mengurus segala macam hal yang berhubungan dengan lapangan. Hal-hal ini mencakup membuat, melihat, mengubah, dan menghapus lapangan yang ada (CRUD). Modul ini juga menyimpan review dan penilaian pengguna terhadap lapangan tersebut. | Faris Huda |
| ```matches``` | Modul ini berfungsi untuk menjalankan fitur matchmaking. Modul ini juga berfungsi untuk memberikan data matchmaking yang sedang berjalan. Modul ini juga nantinya akan mengurus fitur tournament antar tim. | Valerian Hizkia Emmanuel |
| ```bookings``` | Modul ini berfungsi untuk mengurus pemesanan atau peminjaman sebuah lapangan. Beda dengan matchmaking, fitur ini digunakan untuk orang yang ingin menyewa sebuah lapangan secara langsung tanpa matchmaking dengan orang lain. | Valerian Hizkia Emmanuel |
| ```tournament``` | Modul ini berfungsi untuk menjalankan fungsi turnamen. Modul ini nantinya akan mengurus anggota-anggota dari sebuah tim, nama tim, dan hal-hal lainnya yang berhubungan dengan turnamen. | Muhammad Rifqi Ilham |
| ```equipment``` | Modul ini berfungsi untuk menjalankan fungsi peminjaman alat olahraga. | Fathan Alfahrezi |
| ```blog``` | Modul ini berfungsi untuk menjalankan fungsi CRUD untuk blog pada website. | Geraldus Catur Gigih Wahyudi |

## 📊 Sumber Initial Dataset
- Dataset lapangan didapatkan dari hasil <i>scrapping dari website</i> https://ayo.co.id/sitemap/v.xml
- Dataset customer dan perlengkapan olahraga didapat dari Dataset customer dan perlengkapan olahraga dari https://www.kaggle.com/datasets/cnezhmar/sporting-goods-store

## 👤 Peran Pengguna Aplikasi
- User, yang memiliki akses untuk mem-<i>booking</i> lapangan, melakukan <i>matchmaking</i>, dan menyewa alat.
- Admin, yang memiliki akses untuk mengatur segala hal dari melakukan <i>listing</i> lapangan dan alat sampai membatalkan <i>matchmaking</i>.

## ⛓️ Alur Integrasi
- Kita melanjutkan dari projek sebelumnya dengan API sebagai berikut

| API | Deskripsi | Penanggung Jawab |
|-----|-----------|------------------|
| POST `/api/auth/login` | <i>Login</i> ke aplikasi | Seluruh Anggota |
| POST `/api/auth/register` | <i>Membuat akun baru</i> | Seluruh Anggota |
| POST `/api/auth/logout` | <i>logout dari aplikasi</i> | Seluruh Anggota |
| GET `/fields/api/` | Mendapatkan list seluruh lapangan (bila perlu filtering dan searching, tambahkan parameter yang sesuai) | Faris Huda |
| POST `/fields/api/` | Menambahkan lapangan baru | Faris Huda |
| GET `/fields/api/<int:pk>/` | Mendapatkan detail dari suatu lapangan dengan primary key (pk) tertentu | Faris Huda |
| PATCH `/fields/api/<int:pk>/` | Meng-edit lapangan dengan pk tertentu | Faris Huda |
| DELETE `/fields/api/<int:pk>/` | Menghapus lapangan dengan pk tertentu | Faris Huda |
| GET `/api/matches` | Mengambil daftar <i>match</i> yang telah dibuat | Valerian Hizkia Emmanuel |
| POST `/api/matches` | Membuat sebuah <i>match</i> baru | Valerian Hizkia Emmanuel |
| PUT `/api/matches/<int:pk>` | Meng-update detail match | Valerian Hizkia Emmanuel |
| DELETE `/api/matches/<int:pk>` | Menghapus sebuah <i>match</i> | Valerian Hizkia Emmanuel |
| GET `/api/bookings` | Mengambil daftar <i>booking</i> yang telah dibuat | Valerian Hizkia Emmanuel |
| POST `/api/bookings` | Membuat sebuah <i>booking</i> baru | Valerian Hizkia Emmanuel |
| PUT `api/bookings/<int:pk>` | Meng-update detail booking | Valerian Hizkia Emmanuel |
| DELETE `/api/bookings/<int:pk>` | Menghapus sebuah <i>booking</i> | Valerian Hizkia Emmanuel |
| GET `/api/matches/<int:slot>` | Mendapatkan daftar jadwal yang telah diambil oleh sebuah <i>match</i> | Valerian Hizkia Emmanuel |
| GET `/api/bookings/<int:slot>` | Mendapatkan daftar jadwal yang telah diambil oleh sebuah <i>booking</i> | Valerian Hizkia Emmanuel |
| POST `/tournament/create` | membuat tournament baru | Muhammad Rifqi Ilham |
| GET `/tournament` | menampilkan tournament | Muhammad Rifqi Ilham |
| GET `/tournament/<pk>` | melihat detil tournament | Muhammad Rifqi Ilham |
| PUT `/tournament/<pk>/edit` | mengedit tournament | Muhammad Rifqi Ilham |
| DELETE `/tournament/<pk>/delete` | menghapus tournament | Muhammad Rifqi Ilham |
| GET `/tournament/<pk>/matches` | list semua match dalam tournament | Muhammad Rifqi Ilham |
| GET `/tournament/<pk>/matches/<match_id>` | detail match | Muhammad Rifqi Ilham |
| POST `/tournament/<pk>/matches/create` | membuat match di tournament | Muhammad Rifqi Ilham |
| PUT `/tournament/<pk>/matches/<match_id>/edit` | update match | Muhammad Rifqi Ilham |
| DELETE `/tournament/<pk>/matches/<match_id>/delete` | delete match | Muhammad Rifqi Ilham |
| GET `/equipments` | Mendapatkan list seluruh equipment  | Fathan Alfahrezi |
| GET `/equipments/<int:pk>` | Mendapatkan detail dari suatu equipment dengan primary key (pk) tertentu | Fathan Alfahrezi |
| POST `/equipments` | Menambahkan equipment baru | Fathan Alfahrezi |
| PATCH `/equipments/<int:pk>` | Meng-edit equipment dengan pk tertentu | Fathan Alfahrezi |
| DELETE `/equipments/<int:pk>` | Menghapus equipment dengan pk tertentu | Fathan Alfahrezi |
| GET `/blog` | Mendapatkan list seluruh blog | Geraldus Catur Gigih Wahyudi |
| GET `/blog/<uuid:id>` | Mendapatkan detail dari suatu blog dengan id tertentu | Geraldus Catur Gigih Wahyudi |
| POST `/blog` | Menambahkan blog baru | Geraldus Catur Gigih Wahyudi |
| PATCH `/blog/<uuid:id>` | Meng-edit blog dengan id tertentu | Geraldus Catur Gigih Wahyudi |
| DELETE `/blog/<uuid:id>` | Menghapus blog dengan id tertentu | Geraldus Catur Gigih Wahyudi |

## 🖼️ Link Desain
- https://www.figma.com/design/adNQOklC9KkLehcjLanEan/Matchplay-Mobile?node-id=0-1&p=f&t=3aIdBygfXGnauWeF-0

## 🖼️ Link Video
- https://youtube.com/playlist?list=PLJIE90PT58zIyLgPghUnZrv2lbItR_-YZ&si=7wkVK7WltBWKKAzH

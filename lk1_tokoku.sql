-- ============================================================
-- LEMBAR KERJA PRAKTIKUM 1 (LK 1) - Database: tokoku
-- 20 soal | 5 poin per soal
-- ============================================================
-- CATATAN ASUMSI NAMA TABEL & KOLOM (sesuaikan jika berbeda):
--   pelanggan : id, nama, email, kota, tanggal_daftar
--   produk    : id, nama, kategori, harga, stok
--   pesanan   : id, pelanggan_id, jumlah, status, tanggal_pesan, catatan
-- Nilai status: 'selesai', 'diproses', 'dikirim', 'dibatalkan'
-- ============================================================

USE tokoku;

-- ============================================================
-- PERSIAPAN TERLEBIH DAHULU
-- ============================================================

CREATE DATABASE tokoku CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tokoku;

CREATE TABLE pelanggan (
    id             INT PRIMARY KEY AUTO_INCREMENT,
    nama           VARCHAR(100) NOT NULL,
    email          VARCHAR(100),               -- boleh kosong (NULL)
    kota           VARCHAR(50)  NOT NULL,
    tanggal_daftar DATE         NOT NULL
);

CREATE TABLE produk (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    nama_produk VARCHAR(100) NOT NULL,
    kategori    VARCHAR(50)  NOT NULL,
    harga       INT          NOT NULL,
    stok        INT          NOT NULL
);

CREATE TABLE pesanan (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    pelanggan_id  INT         NOT NULL,
    produk_id     INT         NOT NULL,
    jumlah        INT         NOT NULL,
    status        VARCHAR(20) NOT NULL,   -- diproses, dikirim, selesai, dibatalkan
    tanggal_pesan DATE        NOT NULL,
    catatan       VARCHAR(200),           -- boleh kosong (NULL)
    FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id),
    FOREIGN KEY (produk_id)    REFERENCES produk(id)
);

INSERT INTO pelanggan (nama, email, kota, tanggal_daftar) VALUES
('Budi Santoso',    'budi@mail.com',  'Jember',     '2025-01-10'),
('Siti Aminah',     'siti@mail.com',  'Surabaya',   '2025-02-14'),
('Andi Pratama',    NULL,             'Jember',     '2025-03-05'),
('Dewi Lestari',    'dewi@mail.com',  'Malang',     '2025-03-20'),
('Rizky Ramadhan',  'rizky@mail.com', 'Banyuwangi', '2025-04-02'),
('Putri Anggraini', NULL,             'Surabaya',   '2025-05-18'),
('Agus Salim',      'agus@mail.com',  'Jember',     '2025-06-01'),
('Nur Hidayah',     'nur@mail.com',   'Malang',     '2025-07-09'),
('Budi Hartono',    'budih@mail.com', 'Jakarta',    '2025-08-15'),
('Citra Dewi',      'citra@mail.com', 'Jember',     '2025-09-22');

INSERT INTO produk (nama_produk, kategori, harga, stok) VALUES
('Laptop Asus Vivobook',   'Elektronik', 7500000, 15),
('Mouse Logitech M331',    'Aksesoris',   175000, 80),
('Keyboard Mekanik Rexus', 'Aksesoris',   450000, 35),
('Monitor LG 24 Inch',     'Elektronik', 1850000, 12),
('Flashdisk Sandisk 64GB', 'Aksesoris',    85000,  0),
('Headset Gaming Fantech', 'Aksesoris',   320000, 25),
('Webcam Logitech C270',   'Elektronik',  495000, 18),
('Buku Basis Data Dasar',  'Buku',         95000, 50),
('Buku Pemrograman Web',   'Buku',        120000, 40),
('SSD Kingston 480GB',     'Elektronik',  650000, 22),
('Laptop Lenovo IdeaPad',  'Elektronik', 6800000,  8),
('Mousepad Gaming XL',     'Aksesoris',    65000,  0);

INSERT INTO pesanan (pelanggan_id, produk_id, jumlah, status, tanggal_pesan, catatan) VALUES
(1,  2, 1, 'selesai',    '2025-10-01', NULL),
(2,  1, 1, 'selesai',    '2025-10-03', 'Mohon dibungkus kardus tebal'),
(3,  8, 2, 'dikirim',    '2025-10-05', NULL),
(4,  3, 1, 'diproses',   '2025-10-07', NULL),
(5,  4, 1, 'dibatalkan', '2025-10-08', 'Salah pilih ukuran'),
(1,  9, 1, 'selesai',    '2025-10-10', NULL),
(6,  6, 2, 'dikirim',    '2025-10-12', 'Kirim sebelum Jumat'),
(7, 10, 1, 'diproses',   '2025-10-13', NULL),
(8,  2, 3, 'selesai',    '2025-10-14', NULL),
(9, 11, 1, 'dikirim',    '2025-10-15', NULL),
(10, 7, 1, 'diproses',   '2025-10-16', 'Hadiah ulang tahun'),
(3,  5, 4, 'selesai',    '2025-10-17', NULL),
(2,  8, 1, 'dibatalkan', '2025-10-18', NULL),
(4,  1, 1, 'diproses',   '2025-10-18', 'Tolong cek garansi'),
(7, 12, 2, 'selesai',    '2025-10-19', NULL);



-- ============================================================
-- BAGIAN A: WHERE & OPERATOR PERBANDINGAN (Soal 1-5)
-- ============================================================

  -- [SOAL 1] Nama dan email semua pelanggan dari Surabaya
  SELECT nama, email FROM pelanggan WHERE kota = 'Surabaya';

  -- [SOAL 2] Nama produk dan harga untuk produk dengan harga di bawah Rp100.000
  SELECT nama_produk, harga FROM produk WHERE harga < 100000;

  -- [SOAL 3] Semua pesanan dengan jumlah lebih dari 2
  SELECT * FROM pesanan WHERE jumlah > 2;

  -- [SOAL 4] Semua pesanan yang statusnya bukan 'selesai'
  SELECT * FROM pesanan WHERE status <> 'selesai';

  -- [SOAL 5] Pelanggan yang mendaftar pada atau sebelum 31 Maret 20250
  SELECT * FROM pelanggan WHERE tanggal_daftar <= '2025-03-31';


-- ============================================================
-- BAGIAN B: OPERATOR LOGIKA (Soal 6-14)
-- ============================================================

-- [SOAL 6]
SELECT * FROM produk WHERE kategori = 'Aksesoris'
  AND stok > 0;

-- [SOAL 7]
SELECT * FROM produk WHERE kategori = 'Elektronik'
  AND harga <= 1000000;

-- [SOAL 8]
SELECT * FROM pelanggan WHERE kota = 'Jember'
   OR kota = 'Jakarta';

-- [SOAL 9]
SELECT * FROM pesanan WHERE status IN ('diproses', 'dikirim');

-- [SOAL 10]
SELECT * FROM pelanggan WHERE kota NOT IN ('Jember', 'Malang');

-- [SOAL 11]
SELECT * FROM produk WHERE harga BETWEEN 100000 AND 500000;

-- [SOAL 12]
SELECT * FROM pesanan WHERE tanggal_pesan BETWEEN '2025-10-10' AND '2025-10-15';

-- [SOAL 13]
SELECT * FROM pesanan WHERE (status = 'selesai' OR status = 'dikirim')
  AND jumlah > 1;

-- [SOAL 14]

-- Query 1 (tanpa kurung)
SELECT * FROM produk WHERE kategori = 'Buku' OR kategori = 'Aksesoris' AND stok = 0;

-- Query 2 (dengan kurung)
SELECT * FROM produk WHERE (kategori = 'Buku' OR kategori = 'Aksesoris') AND stok = 0;

/*
  PENJELASAN SOAL 14:
  Dalam SQL, operator AND dievaluasi lebih dulu daripada OR (AND punya
  prioritas lebih tinggi).

  - Query 1 dibaca sebagai:
        kategori = 'Buku'  OR  (kategori = 'Aksesoris' AND stok = 0)
    Artinya: SEMUA produk Buku (berapa pun stoknya) ditampilkan, ditambah
    produk Aksesoris yang stoknya 0. Hasilnya lebih banyak.

  - Query 2 dibaca sebagai:
        (kategori = 'Buku' OR kategori = 'Aksesoris')  AND  stok = 0
    Karena ada kurung, kondisi OR diproses dulu, baru hasilnya difilter
    stok = 0. Artinya: hanya produk Buku ATAU Aksesoris yang stoknya 0.
    Hasilnya lebih sedikit (Buku yang stoknya masih ada tidak ikut).

  Kesimpulan: jumlah baris berbeda karena urutan evaluasi AND/OR berbeda.
  Gunakan kurung agar maksud query jelas.
*/


-- ============================================================
-- BAGIAN C: NULL (Soal 15-17)
-- ============================================================

-- [SOAL 15]
SELECT * FROM pelanggan WHERE email IS NULL;

-- [SOAL 16]
SELECT * FROM pesanan WHERE status = 'diproses'
  AND catatan IS NOT NULL;

-- [SOAL 17] (Jawab dengan kalimat sendiri + query perbaikan)
-- Query bermasalah (pesanan tanpa catatan TIDAK ikut tampil):
-- SELECT * FROM pesanan WHERE catatan <> 'Hadiah ulang tahun';

/*
  PENJELASAN SOAL 17:
  NULL berarti "tidak diketahui / kosong", bukan sebuah nilai. Setiap
  perbandingan biasa (=, <>, >, <) dengan NULL menghasilkan UNKNOWN, bukan
  TRUE. Karena WHERE hanya meloloskan baris yang hasilnya TRUE, baris
  dengan catatan NULL ikut tersaring dan tidak tampil.
  Solusinya: periksa NULL secara eksplisit dengan IS NULL.
*/

-- Query perbaikan (pesanan tanpa catatan ikut tampil):
SELECT * FROM pesanan WHERE catatan <> 'Hadiah ulang tahun'
   OR catatan IS NULL;


-- ============================================================
-- BAGIAN D: STUDI KASUS GABUNGAN (Soal 18-20)
-- ============================================================

-- [SOAL 18]
SELECT * FROM pelanggan WHERE (kota = 'Jember' OR kota = 'Surabaya')
  AND email IS NOT NULL;

-- [SOAL 19]
SELECT * FROM produk WHERE kategori <> 'Buku'
  AND harga > 100000
  AND stok < 30;

-- [SOAL 20]
SELECT id, pelanggan_id, status, tanggal_pesan FROM pesanan WHERE status <> 'dibatalkan'
  AND tanggal_pesan >= '2025-10-10'
  AND catatan IS NULL;
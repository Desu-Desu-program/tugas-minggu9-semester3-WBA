-- ============================================================
-- LEMBAR KERJA PRAKTIKUM 2 (LK 2) - Database: tokoku
-- LIKE, ORDER BY, LIMIT & Pagination, Praktik Industri
-- ============================================================
-- CATATAN: Menggunakan database & tabel yang sama dengan LK 1
--   pelanggan : id, nama, email, kota, tanggal_daftar
--   produk    : id, nama_produk, kategori, harga, stok
--   pesanan   : id, pelanggan_id, produk_id, jumlah, status, tanggal_pesan, catatan
-- Sesuai petunjuk: tidak memakai SELECT * pada jawaban akhir
-- ============================================================

USE tokoku;


-- BAGIAN A: LIKE (Soal 1-7)

-- [SOAL 1]
SELECT id, nama_produk, harga FROM produk WHERE nama_produk LIKE 'Buku%';

-- [SOAL 2]
SELECT id, nama_produk, harga FROM produk WHERE nama_produk LIKE '%Gaming%';

-- [SOAL 3]
SELECT id, nama, kota FROM pelanggan WHERE nama LIKE '%Dewi';

-- [SOAL 4] 
SELECT id, nama, kota FROM pelanggan WHERE nama LIKE 'Budi%'
  OR nama LIKE '%Dewi';

-- [SOAL 5] 
SELECT id, nama, email FROM pelanggan WHERE email LIKE '___@mail.com';

-- [SOAL 6]
SELECT id, nama_produk, harga FROM produk WHERE nama_produk LIKE '%Logitech%'
  AND nama_produk NOT LIKE '%Webcam%';

-- [SOAL 7]
SELECT id, pelanggan_id, status, catatan FROM pesanan WHERE catatan LIKE '%kirim%';


-- BAGIAN B: ORDER BY (Soal 8-12)

-- [SOAL 8]
SELECT nama_produk, harga FROM produk ORDER BY harga ASC;

-- [SOAL 9]
SELECT id, nama, email, kota, tanggal_daftar FROM pelanggan ORDER BY tanggal_daftar DESC;

-- [SOAL 10]
SELECT id, nama_produk, kategori, harga FROM produk ORDER BY kategori ASC, harga DESC;

-- [SOAL 11]
SELECT id, nama_produk, harga, stok FROM produk WHERE kategori = 'Elektronik'
  AND stok > 10
ORDER BY harga DESC;

-- [SOAL 12]
SELECT id, nama, kota FROM pelanggan ORDER BY kota ASC, nama DESC;


-- BAGIAN C: LIMIT & PAGINATION (Soal 13-16)

-- [SOAL 13]
SELECT nama_produk, harga FROM produk ORDER BY harga DESC
LIMIT 3;

-- [SOAL 14]
SELECT id, pelanggan_id, status, tanggal_pesan FROM pesanan WHERE status = 'selesai'
ORDER BY tanggal_pesan DESC, id DESC
LIMIT 2;

-- [SOAL 15]
SELECT id, nama_produk, harga FROM produk ORDER BY harga ASC, id ASC
LIMIT 4 OFFSET 4;

-- [SOAL 16] (Jawab dengan kalimat sendiri)
/*
  PENJELASAN SOAL 16:
  1) Mengapa kolom id perlu ditambahkan sebagai urutan terakhir?
     Jika beberapa baris punya nilai harga yang sama, database tidak
     menjamin urutan di antara baris-baris tersebut dan urutannya bisa
     berubah di setiap query. Akibatnya, saat pindah halaman, sebuah data
     bisa muncul dua kali (di halaman 1 dan 2) atau malah tidak muncul
     sama sekali. Kolom id bersifat unik, sehingga urutan menjadi pasti
     (deterministik) dan pagination konsisten. Itulah fungsi tie-breaker.

  2) Nilai OFFSET untuk halaman ke-5 dengan 10 data per halaman:
        OFFSET = (halaman - 1) * jumlah_per_halaman
               = (5 - 1) * 10
               = 40
     Jadi query-nya: ... LIMIT 10 OFFSET 40;
*/


-- BAGIAN D: PRAKTIK INDUSTRI & STUDI KASUS (Soal 17-20)

-- [SOAL 17] (Jawab dengan kalimat sendiri + query perbaikan)
-- Query bermasalah (tidak sargable):
-- SELECT id FROM pesanan WHERE MONTH(tanggal_pesan) = 10 AND YEAR(tanggal_pesan) = 2025;

/*
  PENJELASAN SOAL 17:
  Query asli memakai fungsi MONTH() dan YEAR() pada kolom tanggal_pesan.
  Saat kolom dibungkus fungsi, database harus menghitung fungsi tersebut
  untuk SETIAP baris, sehingga index pada tanggal_pesan tidak bisa
  dipakai dan terjadi full table scan (tidak sargable).

  Solusinya: biarkan kolom tetap "telanjang" dan ubah kondisinya menjadi
  rentang tanggal. Dengan begitu index bisa dipakai (range scan).
  Batas atas memakai < 1 November agar aman untuk tipe DATE maupun DATETIME.
*/

-- Query perbaikan (sargable / ramah index):
SELECT id FROM pesanan WHERE tanggal_pesan >= '2025-10-01'
  AND tanggal_pesan <  '2025-11-01';

-- [SOAL 18] (Jawab dengan kalimat sendiri)
-- Query A: SELECT id, nama_produk FROM produk WHERE nama_produk LIKE 'Mouse%';
-- Query B: SELECT id, nama_produk FROM produk WHERE nama_produk LIKE '%Mouse%';

/*
  PENJELASAN SOAL 18:
  Yang lebih cepat adalah Query A ('Mouse%').

  Index B-Tree menyimpan data dalam keadaan terurut dari awal kata.
  Pada 'Mouse%', awalan teks diketahui sehingga database bisa langsung
  loncat ke posisi "Mouse..." di index (range scan) dan berhenti saat
  awalan sudah tidak cocok.

  Pada '%Mouse%', wildcard di depan membuat awal teks tidak diketahui,
  sehingga index tidak bisa dipakai dan database harus memeriksa semua
  baris (full table scan). Pada tabel jutaan baris, perbedaannya sangat
  terasa.
*/

-- [SOAL 19] Pencarian "Laptop", kategori Elektronik, harga termahal, halaman 1 (5 data/halaman)
-- Versi SQL (nilai di bawah ini hanya contoh; di aplikasi nilainya berasal dari prepared statement):
SELECT id, nama_produk, kategori, harga, stok FROM produk WHERE nama_produk LIKE '%Laptop%'
  AND kategori = 'Elektronik'
ORDER BY harga DESC, id ASC
LIMIT 5 OFFSET 0;

/*
  VERSI PHP PDO (aman dari SQL Injection, memakai prepared statement):

  <?php
  $pdo = new PDO(
      'mysql:host=localhost;dbname=tokoku;charset=utf8mb4',
      'root',
      '',
      [
          PDO::ATTR_ERRMODE          => PDO::ERRMODE_EXCEPTION,
          PDO::ATTR_EMULATE_PREPARES => false,   // pakai prepared statement asli
      ]
  );

  // Input dari pengguna (contoh)
  $keyword  = 'Laptop';
  $kategori = 'Elektronik';
  $halaman  = 1;
  $perHal   = 5;
  $offset   = ($halaman - 1) * $perHal;

  $sql = "SELECT id, nama_produk, kategori, harga, stok
          FROM produk
          WHERE nama_produk LIKE :keyword
            AND kategori = :kategori
          ORDER BY harga DESC, id ASC
          LIMIT :limit OFFSET :offset";

  $stmt = $pdo->prepare($sql);
  $stmt->bindValue(':keyword',  '%' . $keyword . '%', PDO::PARAM_STR);
  $stmt->bindValue(':kategori', $kategori,            PDO::PARAM_STR);
  $stmt->bindValue(':limit',    $perHal,              PDO::PARAM_INT);
  $stmt->bindValue(':offset',   $offset,              PDO::PARAM_INT);
  $stmt->execute();

  $hasil = $stmt->fetchAll(PDO::FETCH_ASSOC);
  ?>

  Mengapa aman? Input pengguna TIDAK digabung langsung ke string SQL.
  Query dan data dikirim terpisah (placeholder :keyword, :kategori, dst.),
  sehingga input seperti "' OR 1=1 --" hanya dianggap teks biasa, bukan
  perintah SQL.
*/

-- [SOAL 20] Fitur pencarian admin: pesanan aktif (diproses/dikirim), sejak 10 Oktober 2025 (inklusif),
--           catatan tidak kosong, urut tanggal terlama lalu id
-- (catatan <> '' ditambahkan agar catatan berisi string kosong juga tidak ikut)
SELECT id, tanggal_pesan, status, catatan FROM pesanan WHERE status IN ('diproses', 'dikirim')
  AND tanggal_pesan >= '2025-10-10'
  AND catatan IS NOT NULL
  AND catatan <> ''
ORDER BY tanggal_pesan ASC, id ASC;

-- ============================================================
-- SELESAI
-- ============================================================

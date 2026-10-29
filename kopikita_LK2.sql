USE `kopikita`;

-- Soal 1. Jumlah produk per category_id.
SELECT category_id,
       COUNT(*) AS jumlah_produk
FROM products
GROUP BY category_id
ORDER BY category_id;

-- Soal 2. Jumlah pelanggan per kota, urut dari terbanyak (NULL = "Tidak diketahui").
SELECT COALESCE(city, 'Tidak diketahui') AS kota,
       COUNT(*) AS jumlah_pelanggan
FROM customers
GROUP BY city
ORDER BY jumlah_pelanggan DESC;

-- Soal 3. Jumlah pesanan per status, urut dari terbanyak.
SELECT status,
       COUNT(*) AS jumlah_pesanan
FROM orders
GROUP BY status
ORDER BY jumlah_pesanan DESC;

-- Soal 4. Total stok per category_id, urut dari stok terbesar.
SELECT category_id,
       SUM(stock) AS total_stok
FROM products
GROUP BY category_id
ORDER BY total_stok DESC;

-- Soal 5. Rata-rata harga per category_id (dibulatkan), urut dari tertinggi.
SELECT category_id,
       ROUND(AVG(price)) AS rata_rata_harga
FROM products
GROUP BY category_id
ORDER BY rata_rata_harga DESC;

-- Soal 6. Total kuantitas terjual per product_id, urut dari terbanyak.
SELECT product_id,
       SUM(quantity) AS total_kuantitas
FROM order_items
GROUP BY product_id
ORDER BY total_kuantitas DESC;

-- Soal 7. Kota yang memiliki minimal 2 pelanggan, beserta jumlahnya.
SELECT city,
       COUNT(*) AS jumlah_pelanggan
FROM customers
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY jumlah_pelanggan DESC;

-- Soal 8. product_id yang total terjualnya lebih dari 5 unit, urut terbanyak.
SELECT product_id,
       SUM(quantity) AS total_terjual
FROM order_items
GROUP BY product_id
HAVING SUM(quantity) > 5
ORDER BY total_terjual DESC;

-- Soal 9. category_id yang memiliki minimal 3 produk dengan stock > 0, beserta jumlahnya.
SELECT category_id,
       COUNT(*) AS jumlah_produk_tersedia
FROM products
WHERE stock > 0
GROUP BY category_id
HAVING COUNT(*) >= 3;

-- Penjelasan: syarat per baris (stock > 0) diletakkan di WHERE karena harus
-- disaring SEBELUM pengelompokan, sehingga produk berstok 0 tidak ikut
-- dihitung. Syarat per kelompok (COUNT(*) >= 3) diletakkan di HAVING karena
-- baru bisa dinilai SETELAH GROUP BY terbentuk. Kalau stock > 0 dipindah ke
-- HAVING, COUNT(*) tetap menghitung produk berstok 0 sehingga hasilnya salah.

-- Soal 10. customer_id yang memiliki minimal 2 pesanan 'selesai'.
SELECT customer_id,
       COUNT(*) AS jumlah_pesanan_selesai
FROM orders
WHERE status = 'selesai'
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY jumlah_pesanan_selesai DESC;

-- Soal 11. Total ongkir per status, hanya status dengan total ongkir > 50000 (tidak NULL).
SELECT status,
       COALESCE(SUM(shipping_fee), 0) AS total_ongkir
FROM orders
GROUP BY status
HAVING SUM(shipping_fee) > 50000;

-- Soal 12. Per bulan: jumlah pesanan dan total ongkir, khusus pesanan 'selesai'.
SELECT DATE_FORMAT(order_date, '%Y-%m') AS bulan,
       COUNT(*)                         AS jumlah_pesanan,
       COALESCE(SUM(shipping_fee), 0)   AS total_ongkir
FROM orders
WHERE status = 'selesai'
GROUP BY bulan
ORDER BY bulan;

-- Soal 13. Jumlah pelanggan yang bergabung per bulan (joined_at).
SELECT DATE_FORMAT(joined_at, '%Y-%m') AS bulan,
       COUNT(*) AS jumlah_pelanggan
FROM customers
GROUP BY bulan
ORDER BY bulan;

-- Soal 14. Laporan per bulan: selesai, dikirim, dibatalkan, menunggu (memakai CASE WHEN).
SELECT DATE_FORMAT(order_date, '%Y-%m') AS bulan,
       SUM(CASE WHEN status = 'selesai'    THEN 1 ELSE 0 END) AS selesai,
       SUM(CASE WHEN status = 'dikirim'    THEN 1 ELSE 0 END) AS dikirim,
       SUM(CASE WHEN status = 'dibatalkan' THEN 1 ELSE 0 END) AS dibatalkan,
       SUM(CASE WHEN status = 'menunggu'   THEN 1 ELSE 0 END) AS menunggu
FROM orders
GROUP BY bulan
ORDER BY bulan;

-- Soal 15. Segmen harga Murah (< 50000), Menengah (50000-<150000), Premium (>= 150000): jumlah produk dan total stok.
SELECT CASE
         WHEN price < 50000  THEN 'Murah'
         WHEN price < 150000 THEN 'Menengah'
         ELSE 'Premium'
       END        AS segmen_harga,
       COUNT(*)   AS jumlah_produk,
       SUM(stock) AS total_stok
FROM products
GROUP BY segmen_harga
ORDER BY segmen_harga;

-- Soal 16. Per order_id: jumlah baris item dan total kuantitas, hanya total kuantitas >= 5.
SELECT order_id,
       COUNT(*)      AS jumlah_item,
       SUM(quantity) AS total_kuantitas
FROM order_items
GROUP BY order_id
HAVING SUM(quantity) >= 5
ORDER BY total_kuantitas DESC;

-- Soal 17. Dengan CTE, hitung total nilai per pesanan lalu tampilkan jumlah pesanan, rata-rata, terkecil, terbesar.
WITH total_pesanan AS (
  SELECT order_id,
         SUM(quantity * unit_price) AS total
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*)         AS jumlah_pesanan,
       ROUND(AVG(total)) AS rata_rata_nilai,
       MIN(total)        AS nilai_terkecil,
       MAX(total)        AS nilai_terbesar
FROM total_pesanan;

-- Soal 18. Dengan CTE, berapa pesanan yang nilainya di atas rata-rata.
WITH total_pesanan AS (
  SELECT order_id,
         SUM(quantity * unit_price) AS total
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*) AS jumlah_pesanan_di_atas_rata_rata
FROM total_pesanan
WHERE total > (SELECT AVG(total) FROM total_pesanan);

-- Soal 19. Jumlah pesanan per status September 2026 memakai filter rentang tanggal, beserta index pendukungnya.
SELECT status,
       COUNT(*) AS jumlah_pesanan
FROM orders
WHERE order_date >= '2026-09-01'
  AND order_date < '2026-10-01'
GROUP BY status;

-- Penjelasan: versi rentang lebih baik karena kolom order_date dibandingkan
-- langsung dengan nilai tanggal (sargable), sehingga MySQL bisa memakai index
-- pada order_date dengan range scan. Kalau kolom dibungkus fungsi seperti
-- MONTH(order_date) atau YEAR(order_date), index tidak bisa dipakai dan server
-- harus memeriksa setiap baris (full table scan). Index di bawah cukup
-- dijalankan sekali; kalau sudah ada, MySQL menolak dengan ERROR 1061.
CREATE INDEX idx_orders_order_date ON orders (order_date);

-- Soal 20. Mini-laporan pesanan Oktober 2026 dalam satu query.
SELECT COUNT(*) AS total_pesanan,
       SUM(CASE WHEN status = 'selesai'    THEN 1 ELSE 0 END) AS selesai,
       SUM(CASE WHEN status = 'dikirim'    THEN 1 ELSE 0 END) AS dikirim,
       SUM(CASE WHEN status = 'dibatalkan' THEN 1 ELSE 0 END) AS dibatalkan,
       SUM(CASE WHEN status = 'menunggu'   THEN 1 ELSE 0 END) AS menunggu,
       COALESCE(SUM(CASE WHEN status = 'selesai' THEN shipping_fee ELSE 0 END), 0) AS total_ongkir_selesai,
       MIN(order_date) AS tanggal_pertama,
       MAX(order_date) AS tanggal_terakhir
FROM orders
WHERE order_date >= '2026-10-01'
  AND order_date < '2026-11-01';

-- Penjelasan: definisi "pesanan selesai" sebaiknya dibakukan dalam VIEW agar
-- aturannya hanya ditulis di satu tempat. Status 'selesai' sekarang diulang di
-- banyak query (soal 10, 11, 12, 14, 20); kalau definisinya berubah, cukup ubah
-- VIEW-nya dan semua laporan otomatis konsisten tanpa menyunting query satu
-- per satu.

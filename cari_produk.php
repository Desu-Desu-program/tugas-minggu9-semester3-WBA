<?php
$pdo = new PDO(
    'mysql:host=localhost;dbname=tokoku;charset=utf8mb4',
    'root',  
    '',
    [
        PDO::ATTR_ERRMODE          => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]
);

$keyword  = $_GET['keyword']  ?? 'Laptop';
$kategori = $_GET['kategori'] ?? 'Elektronik';
$halaman  = max(1, (int)($_GET['halaman'] ?? 1));
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

$stmtTotal = $pdo->prepare(
    "SELECT COUNT(*) FROM produk
     WHERE nama_produk LIKE :keyword AND kategori = :kategori"
);
$stmtTotal->execute([':keyword' => '%' . $keyword . '%', ':kategori' => $kategori]);
$total      = (int)$stmtTotal->fetchColumn();
$totalHalaman = max(1, (int)ceil($total / $perHal));
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Cari Produk - tokoku</title>
</head>
<body>
    <h2>Cari Produk</h2>

    <form method="get">
        <input type="text" name="keyword" placeholder="Kata kunci"
               value="<?= htmlspecialchars($keyword) ?>">
        <select name="kategori">
            <?php foreach (['Elektronik', 'Aksesoris', 'Buku'] as $k): ?>
                <option value="<?= $k ?>" <?= $k === $kategori ? 'selected' : '' ?>><?= $k ?></option>
            <?php endforeach; ?>
        </select>
        <button type="submit">Cari</button>
    </form>

    <p>Ditemukan <?= $total ?> produk. Halaman <?= $halaman ?> dari <?= $totalHalaman ?>.</p>

    <table border="1" cellpadding="6" cellspacing="0">
        <tr><th>ID</th><th>Nama Produk</th><th>Kategori</th><th>Harga</th><th>Stok</th></tr>
        <?php foreach ($hasil as $row): ?>
            <tr>
                <td><?= $row['id'] ?></td>
                <td><?= htmlspecialchars($row['nama_produk']) ?></td>
                <td><?= htmlspecialchars($row['kategori']) ?></td>
                <td>Rp<?= number_format($row['harga'], 0, ',', '.') ?></td>
                <td><?= $row['stok'] ?></td>
            </tr>
        <?php endforeach; ?>
        <?php if (!$hasil): ?>
            <tr><td colspan="5">Tidak ada data.</td></tr>
        <?php endif; ?>
    </table>

    <p>
        <?php $q = http_build_query(['keyword' => $keyword, 'kategori' => $kategori]); ?>
        <?php if ($halaman > 1): ?>
            <a href="?<?= $q ?>&halaman=<?= $halaman - 1 ?>">&laquo; Sebelumnya</a>
        <?php endif; ?>
        <?php if ($halaman < $totalHalaman): ?>
            <a href="?<?= $q ?>&halaman=<?= $halaman + 1 ?>">Berikutnya &raquo;</a>
        <?php endif; ?>
    </p>
</body>
</html>

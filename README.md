# deploy-laravel-script

A simple bash script to deploy a Laravel app on shared hosting.

Script bash sederhana untuk deploy aplikasi Laravel di shared hosting.

## What it does / Apa yang dilakukan

* Check PHP and Composer are installed / Cek PHP dan Composer sudah terpasang
* Install dependencies (`composer install --no-dev`) / Install dependency
* Create `.env` from `.env.example` if it doesn't exist / Buat `.env` dari `.env.example` kalau belum ada
* Ask for DB credentials and write them into `.env` / Minta kredensial database dan tulis ke `.env`
* Generate app key / Generate app key
* Run database migration / Jalankan migrasi database
* Set permissions on `storage` and `bootstrap/cache` / Set permission folder `storage` dan `bootstrap/cache`
* Move `public/` contents to the project root with a custom `index.php` and `.htaccess` (the shared hosting way) / Pindah isi `public/` ke root bersama `index.php` dan `.htaccess` custom (cara shared hosting)

## Usage / Cara pakai

Run the script from the root of your Laravel project:

Jalankan script dari root folder project Laravel:

```bash
bash deploy.sh
```

You'll be asked to fill in database name, username, and password. Password input is hidden (won't show while you type).

Kamu akan diminta mengisi nama database, username, dan password. Input password disembunyikan (tidak tampil saat mengetik).

## Requirements / Kebutuhan

* PHP with Composer installed / PHP dan Composer sudah terpasang
* Bash

## Notes / Catatan

* Designed for shared hosting where Laravel needs to run from the public directory, not the project root / Dibuat untuk shared hosting di mana Laravel dijalankan dari direktori public, bukan root project
* Make sure there's a `.env.example` in your project / Pastikan project punya `.env.example`
* Existing `.env` DB values will be overwritten every run / Nilai DB di `.env` akan selalu ditimpa setiap menjalankan script
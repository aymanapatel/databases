# Seed a million



## Java

## Golang

## PHP
### Prerequisite

1. Docker MySQL or cloud provider
2. Postgres PHP driver `sudo dnf install php-mysqlnd`
3. Install Composer and PHP


### How to use this?


1. Create model `php artisan make:model User` (already done)
2. Create Seed Command `php artisan make:command Seed`

Result putput should be

```
app/Console
├── Commands
│   └── Seed.php    

```

3. `php artisan migrate:fresh` : To create tables

4. `php artisan app:seed`: Seed the database
5. `php artisan app:seed --processes=5`: Seed the database with multi-threading




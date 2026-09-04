# 🌐 آموزش WSSMux

[← بازگشت به BUB TUNNEL](../../README.md)

برای استفاده از WSSMux ابتدا یک دامنه یا زیردامنه آماده کنید، رکورد DNS آن را تنظیم کنید و Proxy را در سرویس سازگار مورد استفاده خود فعال کنید.

## ۱. انتخاب روش انتقال

هنگام ساخت تونل، `WSSMux` را انتخاب کنید.

## ۲. دامنه در هر دو سمت

همان دامنه Proxy‌شده را در هر دو سمت وارد کنید.

```text
Foreign: tunnel.example.com
Iran:    tunnel.example.com
```

## ۳. آدرس کلاینت و پورت

در سمت کلاینت به‌جای IP مستقیم سرور، دامنه Proxy‌شده را در `Server Address` وارد کنید.

پورت‌های رایج سازگار با HTTPS:

```text
443
2053
2083
2087
2096
8443
```

نمونه:

```text
Transport: WSSMux
Server Address: tunnel.example.com
Tunnel Port: 443
Domain: tunnel.example.com
```
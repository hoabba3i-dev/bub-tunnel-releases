# BUB TUNNEL

> **A resilient tunneling platform for difficult networks — with Reverse and Direct modes, multiple transport strategies, live monitoring, traffic control, and resilient failover.**

[🇮🇷 راهنمای فارسی](#persian-guide) · [🚀 Installation](#installation) · [↩️ Reverse Setup](#reverse-setup) · [➡️ Direct Setup](#direct-setup) · [🌐 WSSMux Guide](#wssmux-guide) · [🔀 BUBMIX](#bubmix) · [⚡ NEXUS](#nexus) · [🧩 BUBTun](#bubtun) · [🛠️ Manager](#manager) · [📊 Monitoring](#monitoring)

BUB Tunnel is designed to create and manage Linux network tunnels without forcing every network path to use the same transport strategy.

A tunnel can operate in **Reverse** or **Direct** mode. Depending on the selected mode and deployment, BUB provides conventional transports such as `TCP`, `UDP`, `WebSocket`, and `TLS`, as well as BUB-specific technologies such as `NEXUS`, `BUBTun`, and `BUBMIX`.

---

## ✨ Key Features

- Reverse and Direct tunnel modes
- `TCP Raw`, `TCP Mux`, `TCP Shadow`, `TCP Core`
- `WS Mux`, `WSS Mux`, `TLS Mux`
- `UDP`, `KCP`, `QUIC`
- `ICMP Echo`
- `NEXUS` resilient multipath connectivity
- `BUBTun` dedicated transport
- `BUBMIX` multi-carrier management for Reverse tunnels
- Bonding and multipath support
- Automatic recovery capabilities
- Live tunnel monitoring
- Ping, jitter, and packet-loss visibility
- Per-tunnel traffic limits
- Live logs
- Start, Stop, Restart, and Scheduled Restart
- Auto Refresh
- Integrated GitHub Releases updater
- License-controlled production releases
- Linux AMD64 and ARM64 builds

---

<a id="installation"></a>
## 🚀 Installation

Install the latest stable BUB Tunnel release with the official installer:

```bash
curl -fsSL https://raw.githubusercontent.com/hoabba3i-dev/bub-tunnel-releases/main/install.sh | bash
```

The installer detects the supported architecture and downloads the matching production package.

After installation, start the manager with:

```bash
bub
```

Public production packages are provided for:

```text
Linux AMD64
Linux ARM64
```

---

## 🧭 First Setup

BUB is managed from the main `bub` interface.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fd783572-071a-450d-afd7-41fe77ceb5fc" alt="BUB Tunnel main menu" width="680">
</p>

During setup, choose the tunnel direction first and then complete the transport-specific configuration.

<p align="center">
  <img src="https://github.com/user-attachments/assets/f3110430-7111-4e06-b956-0c39f928dfb5" alt="BUB Tunnel mode selection" width="620">
</p>

---

<a id="reverse-setup"></a>
## ↩️ Reverse Setup

Typical direction:

```text
Foreign / Client
       │
       ▼
    Reverse
       │
       ▼
 Iran / Server
```

General setup flow:

```text
1. Start `bub` on the Iran side.
2. Choose Setup Server.
3. Select Reverse.
4. Select the required transport and complete the Server configuration.
5. Start `bub` on the Foreign side.
6. Choose Setup Client.
7. Select Reverse.
8. Enter the matching tunnel parameters, token, and transport settings.
9. Start the tunnel and verify its status.
```

Transport-specific settings must match where required by that transport.

`BUBMIX` is available for Reverse tunnels when multiple transport options are required.

---

<a id="direct-setup"></a>
## ➡️ Direct Setup

For Direct tunnels, configure the **Foreign Client first**, then configure the **Iran Server**.

```text
1. Foreign  → Setup Client → Direct
2. Iran     → Setup Server → Direct
```

### Step 1 — Foreign Client

Run `bub`, choose `Setup Client → Direct`, select the required transport, and complete the Client configuration.

If the setup asks:

```text
Enable 4-link multipath striping [Y/n]:
```

- Press `Enter` or choose `Y` to enable four bonded links.
- Choose `n` for a single-link Direct tunnel.

### Step 2 — Iran Server

Run `bub`, choose `Setup Server → Direct`, and use the corresponding tunnel port, token, and compatible transport settings.

---

## 🚚 Transport Overview

| Family | Transport methods |
|---|---|
| TCP | `TCP Raw`, `TCP Mux`, `TCP Shadow` |
| Web / TLS | `WS Mux`, `WSS Mux`, `TLS Mux` |
| UDP | `UDP`, `KCP`, `QUIC` |
| Advanced | `TCP Core`, `ICMP Echo` |
| BUB | `BUBTun`, `NEXUS` |
| Orchestration | `BUBMIX` |

Different transports are intended for different network conditions.

<p align="center">
  <img src="https://github.com/user-attachments/assets/cea4a927-9eef-4293-a7b1-384c0de0fab4" alt="BUB Tunnel transport selection" width="620">
</p>

---

<a id="wssmux-guide"></a>
## 🌐 WSSMux Guide

`WSSMux` carries BUB traffic through secure WebSocket connections.

### 1. Prepare the domain

Create or select a domain/subdomain, configure its DNS record for the intended endpoint, and enable Proxy on the compatible proxy service you use.

Make sure the domain resolves correctly and Proxy is active before continuing.

### 2. Select WSSMux

During tunnel setup select `WSSMux`.

### 3. Use the same domain on both sides

When BUB asks for the WSS domain, enter the same prepared domain on both endpoints.

```text
Foreign:
Domain: tunnel.example.com

Iran:
Domain: tunnel.example.com
```

### 4. Client Server Address and HTTPS port

On the **Client**, do not use the Server's direct IP as `Server Address`. Use the **proxied domain address** instead.

Use an HTTPS-compatible port supported by your proxy service, for example:

```text
443
2053
2083
2087
2096
8443
```

Example Client configuration:

```text
Transport: WSSMux
Server Address: tunnel.example.com
Tunnel Port: 443
Domain: tunnel.example.com
```

The exact port must also be correctly configured for your deployment and proxy service.

---

## 🛡️ TCP Shadow

`TCP Shadow` is an authenticated and encrypted BUB transport option. Internal cryptographic and protocol implementation details are intentionally not documented in the public README.

---

## ⚙️ TCP Core

`TCP Core` is an advanced Linux transport intended for specialized network paths. It may require `root` or `CAP_NET_RAW` depending on the environment. Internal packet-processing design is not documented publicly.

---

## 📡 ICMP Echo

`ICMP Echo` provides an alternative BUB transport using ICMP-compatible network paths. It requires the necessary system permissions and ICMP reachability between endpoints. Internal framing and transport mechanics are intentionally omitted from public documentation.

---

<a id="bubmix"></a>
## 🔀 BUBMIX

`BUBMIX` is BUB's multi-transport management capability for **Reverse** tunnels.

It can manage multiple configured carriers, observe their availability, and provide automatic failover capabilities when network conditions change.

Each underlying transport keeps its own configuration and behavior.

<p align="center">
  <img src="https://github.com/user-attachments/assets/4c22f687-3771-4bbc-8bc7-460bd78a5b2b" alt="BUBMIX transport configuration" width="520">
</p>

> The public documentation intentionally describes BUBMIX at the feature level. Carrier-selection logic, health algorithms, failover sequencing, session handling, scheduling, probe behavior, and other internal implementation details are proprietary and are not documented here.

---

<a id="nexus"></a>
## ⚡ NEXUS

`NEXUS` is BUB's resilient multipath transport technology.

It is designed for environments where multiple links, connection recovery, and improved tunnel resilience are useful.

> Internal link scheduling, recovery algorithms, session mechanics, health logic, and protocol implementation are intentionally not documented in the public README.

---

<a id="bubtun"></a>
## 🧩 BUBTun

`BUBTun` is a dedicated BUB transport with its own configuration and runtime behavior.

It can be used independently or, where supported, as a transport option managed by `BUBMIX`.

Internal protocol details are intentionally kept out of public documentation.

---

<a id="manager"></a>
## 🛠️ Manager and Tunnel Administration

Typical actions include Edit, Start, Stop, Restart, Live Log, Delete, and Scheduled Restart.

Common configuration areas include `Connection`, `Transport`, transport-specific settings, and advanced tunnel configuration.

<p align="center">
  <img src="https://github.com/user-attachments/assets/cd735f4b-e975-4fb4-b513-f5ee636c178e" alt="BUB Tunnel configuration menu" width="620">
</p>

---

<a id="monitoring"></a>
## 📊 Live Monitoring

The live status view can report operational information such as uptime, active connections, traffic, current and peak speed, CPU and memory usage, reconnect counter, peer ping/jitter/packet loss, external connectivity checks, and tunnel health.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9eead10b-7776-4bc6-8282-a0e45815fa39" alt="BUB Tunnel live monitoring and traffic limit" width="620">
</p>

---

## 📦 Traffic Limit

Traffic limits are configured independently per tunnel and can provide quota, usage, remaining traffic, percentage, and automatic stop behavior.

---

## 📜 Live Logs and Troubleshooting

If a tunnel does not connect, check matching Client/Server settings, port reachability, token, selected transport, required permissions, service status, and Live Log errors.

For `WSSMux`, also verify the domain, DNS, Proxy status, Client Server Address, and HTTPS-compatible port.

---

## 🔄 Updates

From the main menu choose `UPDATE`. The updater checks the official BUB Tunnel Releases repository and installs the package for the current supported architecture.

---

## 🔐 Licensing

License Bot: **@bub_Licensebot**

Support: **@Bubtunnel_support**

Telegram Channel: **@bub_tunnel**

---

## 📦 Public Release Packages

Public binary packages contain only:

```text
bub
bub-client
bub-server
bub-manager.sh
```

Source code, credentials, tokens, SSH keys, private configuration, and personal material are not included in public release assets.

---

<a id="persian-guide"></a>
# 🇮🇷 راهنمای فارسی BUB TUNNEL

> **یک پلتفرم قدرتمند و پایدار برای ساخت و مدیریت تونل در شبکه‌های دشوار**

[⬆️ بازگشت به ابتدای صفحه](#bub-tunnel) · [🚀 نصب](#fa-installation) · [↩️ Reverse](#fa-reverse) · [➡️ Direct](#fa-direct) · [🌐 WSSMux](#fa-wssmux) · [🔀 BUBMIX](#fa-bubmix) · [⚡ NEXUS](#fa-nexus) · [🧩 BUBTun](#fa-bubtun) · [🛠️ مدیریت](#fa-manager) · [📊 مانیتورینگ](#fa-monitoring)

`BUB Tunnel` برای ساخت و مدیریت تونل‌های شبکه در `Linux` طراحی شده است و از حالت‌های `Reverse` و `Direct` و چندین روش انتقال پشتیبانی می‌کند.

---

## ✨ قابلیت‌های اصلی

- تونل `Reverse` و `Direct`
- `TCP Raw`، `TCP Mux`، `TCP Shadow` و `TCP Core`
- `WS Mux`، `WSS Mux` و `TLS Mux`
- `UDP`، `KCP` و `QUIC`
- `ICMP Echo`
- ارتباط چندمسیره با `NEXUS`
- روش انتقال اختصاصی `BUBTun`
- مدیریت چند مسیر در `Reverse` با `BUBMIX`
- بازیابی خودکار ارتباط
- مانیتورینگ زنده
- نمایش `Ping`، `Jitter` و `Packet Loss`
- محدودیت مصرف ترافیک
- `Live Log`
- `Scheduled Restart`
- بروزرسانی داخلی
- پشتیبانی از `Linux AMD64` و `Linux ARM64`

---

<a id="fa-installation"></a>
## 🚀 آموزش نصب

```bash
curl -fsSL https://raw.githubusercontent.com/hoabba3i-dev/bub-tunnel-releases/main/install.sh | bash
```

بعد از نصب، مدیر برنامه را با دستور `bub` اجرا کنید.

---

## 🧭 شروع کار با Manager

<p align="center">
  <img src="https://github.com/user-attachments/assets/fd783572-071a-450d-afd7-41fe77ceb5fc" alt="منوی اصلی BUB Tunnel" width="680">
</p>

ابتدا جهت Tunnel را انتخاب کنید و سپس تنظیمات روش انتقال موردنظر را انجام دهید.

<p align="center">
  <img src="https://github.com/user-attachments/assets/f3110430-7111-4e06-b956-0c39f928dfb5" alt="انتخاب حالت Reverse یا Direct" width="620">
</p>

---

<a id="fa-reverse"></a>
## ↩️ آموزش راه‌اندازی Reverse

```text
Foreign / Client
       │
       ▼
    Reverse
       │
       ▼
 Iran / Server
```

ترتیب کلی:

```text
1. در سمت Iran دستور bub را اجرا کنید.
2. Setup Server را انتخاب کنید.
3. Reverse را انتخاب کنید.
4. روش انتقال و تنظیمات Server را کامل کنید.
5. در سمت Foreign دستور bub را اجرا کنید.
6. Setup Client و سپس Reverse را انتخاب کنید.
7. تنظیمات متناظر Tunnel، Token و Transport را وارد کنید.
8. Tunnel را اجرا و Status را بررسی کنید.
```

`BUBMIX` برای مدیریت چند روش انتقال در معماری `Reverse` در دسترس است.

---

<a id="fa-direct"></a>
## ➡️ آموزش راه‌اندازی Direct

در `Direct` ترتیب نصب به این شکل است:

```text
1. Foreign  → Setup Client → Direct
2. Iran     → Setup Server → Direct
```

تنظیمات `Tunnel Port`، `Token` و روش انتقال باید بین دو سمت سازگار باشند.

در صورت نمایش گزینه چهار لینک، با `Enter` یا `Y` حالت چهار لینک و با `n` حالت تک‌لینک انتخاب می‌شود.

---

## 🚚 روش‌های انتقال

روش‌های انتقال BUB از خانواده‌های `TCP`، `Web/TLS`، `UDP`، `BUB` و روش‌های پیشرفته تشکیل شده‌اند.

<p align="center">
  <img src="https://github.com/user-attachments/assets/cea4a927-9eef-4293-a7b1-384c0de0fab4" alt="فهرست روش‌های انتقال BUB Tunnel" width="620">
</p>

---

<a id="fa-wssmux"></a>
## 🌐 آموزش WSSMux

برای استفاده از `WSSMux` ابتدا یک دامنه یا زیردامنه آماده کنید، رکورد `DNS` آن را تنظیم کنید و `Proxy` را در سرویس سازگار مورد استفاده خود فعال کنید.

سپس در BUB روش `WSSMux` را انتخاب کنید.

### دامنه WSS در هر دو سمت

همان دامنه Proxy‌شده را در قسمت `Domain` هر دو سمت وارد کنید.

### نکته مهم در Client

در سمت `Client`، به‌جای IP مستقیم Server، **آدرس دامنه Proxy‌شده** را در `Server Address` وارد کنید.

برای `Tunnel Port` نیز از یک پورت سازگار با `HTTPS` که توسط سرویس Proxy شما پشتیبانی می‌شود استفاده کنید؛ برای مثال:

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

---

## 🛡️ TCP Shadow

`TCP Shadow` یکی از روش‌های انتقال امن BUB است. جزئیات داخلی احراز هویت، رمزنگاری و ساختار پروتکل عمداً در مستندات عمومی منتشر نمی‌شود.

---

## ⚙️ TCP Core

`TCP Core` یک روش انتقال پیشرفته برای محیط‌های `Linux` است و بسته به محیط ممکن است به `root` یا `CAP_NET_RAW` نیاز داشته باشد. جزئیات طراحی و پردازش داخلی آن عمومی نشده است.

---

## 📡 ICMP Echo

`ICMP Echo` یک روش انتقال جایگزین برای مسیرهای سازگار با `ICMP` است. دسترسی لازم سیستم و امکان عبور `ICMP` بین دو سمت ضروری است. جزئیات داخلی پروتکل در README عمومی ارائه نمی‌شود.

---

<a id="fa-bubmix"></a>
## 🔀 BUBMIX

`BUBMIX` قابلیت مدیریت چند روش انتقال برای تونل‌های `Reverse` است.

این قابلیت می‌تواند چند مسیر تنظیم‌شده را مدیریت کند، وضعیت در دسترس بودن آن‌ها را بررسی کند و هنگام تغییر شرایط شبکه امکان `Failover` خودکار را فراهم کند.

هر روش انتقال تنظیمات و رفتار مخصوص خودش را حفظ می‌کند.

<p align="center">
  <img src="https://github.com/user-attachments/assets/4c22f687-3771-4bbc-8bc7-460bd78a5b2b" alt="تنظیم Carrier های BUBMIX" width="520">
</p>

> مستندات عمومی عمداً فقط قابلیت‌های BUBMIX را معرفی می‌کنند. منطق انتخاب مسیر، الگوریتم‌های سلامت، ترتیب Failover، مدیریت Session، Scheduler، Probe و سایر جزئیات پیاده‌سازی داخلی منتشر نمی‌شوند.

---

<a id="fa-nexus"></a>
## ⚡ NEXUS

`NEXUS` فناوری چندمسیره مقاوم BUB است و برای مسیرهایی طراحی شده که استفاده از چند لینک، بازیابی ارتباط و پایداری بیشتر اهمیت دارد.

> الگوریتم‌های داخلی مدیریت لینک، بازیابی، Session، Health Check، Scheduling و جزئیات پروتکل در مستندات عمومی منتشر نمی‌شوند.

---

<a id="fa-bubtun"></a>
## 🧩 BUBTun

`BUBTun` یک روش انتقال اختصاصی BUB با تنظیمات و Runtime مخصوص خودش است.

می‌توان از آن به‌صورت مستقل یا در موارد پشتیبانی‌شده به‌عنوان یکی از روش‌های انتقال تحت مدیریت `BUBMIX` استفاده کرد.

جزئیات داخلی پروتکل در مستندات عمومی ارائه نمی‌شود.

---

<a id="fa-manager"></a>
## 🛠️ مدیریت Tunnel

از Manager می‌توانید عملیات مدیریت و تنظیم Tunnel را انجام دهید.

<p align="center">
  <img src="https://github.com/user-attachments/assets/cd735f4b-e975-4fb4-b513-f5ee636c178e" alt="منوی تنظیمات Tunnel" width="620">
</p>

---

<a id="fa-monitoring"></a>
## 📊 مانیتورینگ زنده

بخش `Status` اطلاعات عملیاتی مانند زمان فعالیت، اتصال‌ها، ترافیک، سرعت، مصرف منابع، تعداد اتصال مجدد، `Ping`، `Jitter`، `Packet Loss` و سلامت Tunnel را نمایش می‌دهد.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9eead10b-7776-4bc6-8282-a0e45815fa39" alt="مانیتورینگ زنده و Traffic Limit" width="620">
</p>

---

## 📦 محدودیت مصرف ترافیک

برای هر Tunnel می‌توان محدودیت مصرف مستقل تنظیم کرد و میزان مصرف، باقی‌مانده و درصد استفاده را مشاهده کرد.

---

## 📜 Live Log و عیب‌یابی

در صورت عدم اتصال، تنظیمات متناظر Client و Server، Port، Token، Transport، وضعیت Service و `Live Log` را بررسی کنید.

در `WSSMux` همچنین `Domain`، `DNS`، `Proxy`، مقدار `Server Address` در Client و پورت سازگار با `HTTPS` را بررسی کنید.

---

## 🔄 بروزرسانی

از منوی اصلی گزینه `UPDATE` را انتخاب کنید. Updater نسخه مناسب معماری سیستم را از Repository رسمی دریافت و نصب می‌کند.

---

## 🔐 License و راه‌های ارتباطی

License Bot: **@bub_Licensebot**

پشتیبانی: **@Bubtunnel_support**

کانال رسمی Telegram: **@bub_tunnel**

---

## 📦 فایل‌های Release عمومی

Package عمومی هر معماری فقط شامل فایل‌های Production زیر است:

```text
bub
bub-client
bub-server
bub-manager.sh
```

Source Code، Token، Credential، SSH Key، تنظیمات خصوصی و اطلاعات شخصی داخل Release عمومی قرار نمی‌گیرند.

---

# BUB TUNNEL

```text
Built for difficult networks.
Built for stability.
Built to recover.

Reverse or Direct.
Single link or Multipath.
One manager. Multiple transport strategies.

BUB TUNNEL
```

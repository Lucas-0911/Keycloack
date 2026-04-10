# Keycloak - Flash DTF SSO

Keycloak 26.2 với custom theme Flash DTF và RabbitMQ Event Listener cho đồng bộ user.

## Kiến trúc

```
┌─────────────────┐    ┌──────────────┐    ┌──────────────────┐
│   Keycloak 26.2 │───>│   MySQL 8    │    │  RabbitMQ 3.13   │
│  (Custom Theme) │    │  (Database)  │    │ (Event Messages) │
│  Port: 8080     │    │  Port: 3307  │    │ AMQP: 5672       │
│                 │───>│              │    │ UI:   15672      │
│ Event Listener  │──────────────────────>│                  │
└─────────────────┘    └──────────────┘    └──────────────────┘
```

## Quick Start

### 1. Khởi chạy

```bash
docker-compose up -d --build
```

### 2. Truy cập

| Service            | URL                          | Credentials         |
|--------------------|------------------------------|----------------------|
| Keycloak Admin     | http://localhost:8080         | admin / admin        |
| RabbitMQ Manager   | http://localhost:15672        | admin / admin_password |
| MySQL              | localhost:3307               | keycloak / keycloak_password |

### 3. Cấu hình Realm

1. Đăng nhập Admin Console: http://localhost:8080/admin
2. Tạo Realm mới (VD: `flash-dtf`)
3. **Realm Settings → Themes → Login Theme** → chọn `flash-dtf`
4. **Realm Settings → Login** → Bật `User registration`
5. **Authentication → Required Actions** → Bật `Verify Email` (set as Default Action)
6. **Realm Settings → Email** → Cấu hình SMTP server
7. **Realm Settings → Events → Event Listeners** → Thêm `rabbitmq-event-listener`

### 4. Cấu hình Social Login (Optional)

- **Google**: Realm → Identity Providers → Add Google → Cấu hình Client ID/Secret
- **Apple**: Realm → Identity Providers → Add Apple → Cấu hình Service ID/Secret

## Cấu trúc thư mục

```
keycloack/
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # Custom Keycloak image with extensions
├── themes/
│   └── flash-dtf/
│       └── login/
│           ├── theme.properties  # Theme configuration
│           ├── template.ftl      # Main layout template
│           ├── login.ftl         # Sign-in page
│           ├── register.ftl      # Sign-up page
│           └── resources/
│               ├── css/login.css # Custom styles
│               └── img/          # Logo & icons
└── extensions/
    └── keycloak-event-listener-rabbitmq/
        ├── pom.xml               # Maven project
        └── src/                  # Java source code
```

## RabbitMQ Event Message Format

Khi user đăng ký mới, message JSON sau được publish vào queue `keycloak.user.registered`:

```json
{
  "eventType": "REGISTER",
  "timestamp": "2026-04-10T09:30:00Z",
  "realmId": "flash-dtf",
  "userId": "uuid-of-user",
  "username": "john@example.com",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "emailVerified": false,
  "enabled": true,
  "createdTimestamp": 1744278600000
}
```

## Development

### Hot-reload theme

Theme được mount volume nên chỉ cần sửa file và refresh browser (theme cache đã tắt).

### Rebuild extension

```bash
docker-compose build keycloak
docker-compose up -d keycloak
```

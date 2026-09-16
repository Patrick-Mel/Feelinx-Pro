# 🇨🇲 FEELINX — Application Mobile & Backend de Rencontre (Afrique)

> « Des liens qui se ressentent. » / *« Links you can feel. »*

Feelinx est une application mobile grand public de rencontre et de mise en relation sociale (amour, amitié, réseautage professionnel) spécialement conçue pour le contexte culturel, économique et technique africain (Cameroun, Côte d'Ivoire, Sénégal, etc.).

---

## 🚀 Architecture Technique

Le projet est structuré sous forme de monorepo à deux dossiers principaux :

```
Feelinx Pro/
├── backend/                 # API Django REST Framework + Channels (WebSockets) + Celery
├── mobile/                  # Frontend Flutter 3.x (Android, iOS, Web) en Clean Architecture
├── docker-compose.yml       # Stack PostgreSQL 16 + Redis 7 + Django + Celery Worker/Beat
└── README.md                # Guide d'installation et d'utilisation
```

### Stack Backend
- **Langage & Framework** : Python 3.12, Django 5.0, Django REST Framework
- **Temps Réel** : Django Channels 4 (`channels_redis`) pour les WebSockets du chat et de la présence
- **Base de données & Cache** : PostgreSQL 16 (avec formule SQL Haversine) + Redis 7
- **Tâches asynchrones** : Celery (expiration d'abonnements, notifications push)
- **Authentification** : OTP SMS + JWT SimpleJWT (Access 60 min, Refresh 30j)
- **Paiements Mobile Money** : MTN MoMo Collection API & Orange Money Web Payment API (avec provider `MockPaymentProvider` pour le dev local)
- **Notifications Push** : OneSignal REST API Service

### Stack Frontend Mobile
- **Framework** : Flutter 3.2x (Android, iOS, Web)
- **State Management** : Riverpod 2.x
- **Routing** : `go_router` (routes déclaratives & shell routes pour la barre inférieure)
- **Réseau & WebSocket** : `dio` avec intercepteurs JWT & refresh + `web_socket_channel`
- **Design System** : Material 3 custom (Coral `#FF4E64`, Indigo `#6C4AB6`, Gold `#F4B740`)
- **Swipe Stack Engine** : Implémentation custom à la main avec `GestureDetector`, spring physics, overlays dynamiques et retours haptiques

---

## 🛠️ Démarrage Rapide en Local

### 1. Cloner le dépôt et configurer les variables d'environnement
```bash
cp .env.example .env
```

### 2. Lancer le Backend Django (Docker ou Python local)

#### Option A : Via Docker Compose (Recommandé)
```bash
docker-compose up --build
```
L'API sera accessible sur `http://localhost:8000/api/v1/` et la documentation OpenAPI Swagger sur `http://localhost:8000/api/docs/`.

#### Option B : Lancement Python direct
```bash
cd backend
pip install -r requirements/base.txt
python manage.py migrate
python manage.py seed_demo
python manage.py runserver 0.0.0.0:8000
```

> **Note sur le Seeding Démo** : La commande `python manage.py seed_demo` peuple automatiquement la base de données avec ~60 centres d'intérêt locaux, 3 formules d'abonnement, 50 profils fictifs réalistes (noms camerounais, photos, bios), des swipes et des conversations actives.

---

### 3. Lancer l'Application Flutter Mobile / Web

```bash
cd mobile
flutter pub get
flutter run -d chrome # Ou android / ios
```

---

## 🧪 Tests & Qualité

### Backend Django Tests
```bash
cd backend
pytest --cov=apps
```

### Frontend Flutter Tests
```bash
cd mobile
flutter analyze
flutter test
```

---

## ☁️ Déploiement en Production (Railway)

Le backend Django est hébergé en production sur Railway avec PostgreSQL et Redis :
- **URL API Production** : `https://feelinx-backend-production-9537.up.railway.app/api/v1/`
- **Documentation API Swagger** : `https://feelinx-backend-production-9537.up.railway.app/api/docs/`
- **Interface d'administration Admin** : `https://feelinx-backend-production-9537.up.railway.app/admin/`

---

## 📄 Licence
Propriété exclusive de Feelinx Inc. Tous droits réservés.


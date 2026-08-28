# 🛍️ Sellora

**Modern Sales Management Application built with Flutter, Node.js, Express, and MongoDB**

Sellora is a full-stack sales management application designed to simplify the process of recording, updating, searching, and analyzing sales transactions. The application features a modern Flutter frontend and a RESTful API backend built with Node.js and Express, with MongoDB as the database.

---

## ✨ Features

### Authentication

* User registration
* Secure login with JWT authentication
* Persistent login session
* Logout functionality
* Protected API routes

### Dashboard

* Live sales statistics
* Total transactions
* Total revenue
* Sales table from MongoDB
* Search by invoice number or customer
* Filter by sales date
* Manual refresh

### Sales Management

* Add new sales transaction
* Update existing transaction
* Delete transaction with confirmation
* Form validation
* Loading indicators
* Error handling

---

## 🖼️ Application Preview

> Replace these placeholders with screenshots after uploading them to GitHub.

| Login            | Dashboard            |
| ---------------- | -------------------- |
| `docs/login.png` | `docs/dashboard.png` |

| Add Sales            | Update Sales            |
| -------------------- | ----------------------- |
| `docs/add-sales.png` | `docs/update-sales.png` |

| Delete Sales            |
| ----------------------- |
| `docs/delete-sales.png` |

---

## 🛠️ Tech Stack

| Layer             | Technology        |
| ----------------- | ----------------- |
| Frontend          | Flutter           |
| Backend           | Node.js + Express |
| Database          | MongoDB           |
| Authentication    | JWT               |
| State Management  | Stateful Widget   |
| API Communication | HTTP Package      |

---

## 📁 Project Structure

```text
Sellora/
│
├── frontend/                 # Flutter Application
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── storage/
│   └── pubspec.yaml
│
├── backend/                  # Node.js REST API
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── server.js
│   └── package.json
│
└── README.md
```

---

## 🚀 Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/Rayshan10/Sellora.git
cd Sellora
```

### 2. Backend Setup

```bash
cd backend
npm install
```

Create `.env`

```env
PORT=5000
MONGO_URI=mongodb://127.0.0.1:27017/sellora
JWT_SECRET=your_secret_key
```

Run backend

```bash
npm run dev
```

Server will run at:

```text
http://localhost:5000
```

---

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

---

## 🗄️ Database

Database name:

```text
sellora
```

Collections:

```text
users
sales
```

---

## 🔐 Authentication Flow

```text
User
 │
 ▼
Login
 │
 ▼
JWT Token
 │
 ▼
Flutter Secure Storage
 │
 ▼
Protected API Request
 │
 ▼
MongoDB
```

---

## 📊 Dashboard Flow

```text
MongoDB
 │
 ▼
GET /api/sales
 │
 ▼
SalesService
 │
 ▼
Dashboard
 ├── Total Transactions
 ├── Total Revenue
 ├── Search
 └── Date Filter
```

---

## 🌐 REST API

### Authentication

| Method | Endpoint             | Description      |
| ------ | -------------------- | ---------------- |
| POST   | `/api/auth/register` | Register user    |
| POST   | `/api/auth/login`    | Login user       |
| GET    | `/api/auth/me`       | Get current user |

### Sales

| Method | Endpoint         | Description   |
| ------ | ---------------- | ------------- |
| GET    | `/api/sales`     | Get all sales |
| POST   | `/api/sales`     | Create sale   |
| PUT    | `/api/sales/:id` | Update sale   |
| DELETE | `/api/sales/:id` | Delete sale   |

---

## 📱 Main Features

### Login

* JWT authentication
* Session persistence
* Secure logout

### Dashboard

* Live statistics
* Search invoice/customer
* Filter by date
* Refresh data

### Add Sales

* Invoice validation
* Customer validation
* Quantity validation
* Total validation
* Loading state

### Update Sales

* Select invoice
* Confirmation dialog
* Validation
* Loading indicator

### Delete Sales

* Confirmation dialog
* Safe deletion
* Instant UI update

---

## 🧪 Testing

The application has been successfully tested with the following scenarios:

| Test Case            | Status |
| -------------------- | ------ |
| User Registration    | ✅      |
| User Login           | ✅      |
| JWT Authentication   | ✅      |
| Session Persistence  | ✅      |
| Get User Profile     | ✅      |
| Add Sales            | ✅      |
| Update Sales         | ✅      |
| Delete Sales         | ✅      |
| Dashboard Statistics | ✅      |
| Search Sales         | ✅      |
| Date Filter          | ✅      |
| Logout               | ✅      |

---

## 🔮 Future Improvements

* Export sales to PDF & Excel
* Monthly sales reports
* Revenue charts
* Customer management
* Product inventory integration
* Dark mode
* Role-based authentication

---

## 👨‍💻 Developer

**Rayshan Gani Putra**

Full Stack Developer • Flutter • Node.js • MongoDB

GitHub: https://github.com/Rayshan10

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more information.

# 📊 Sellora - Architecture & Implementation Overview

## 🏗️ Aplikasi Flow Diagram

### SEBELUMNYA:

```
┌─────────────────┐
│   Login Page    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Home Page     │ (Menu Buttons)
└────────┬────────┘
         │
    ┌────┴──────┬───────────┬──────────┐
    ▼           ▼           ▼          ▼
┌────────────┐ ┌──────────┐ ┌──────┐ ┌────────┐
│ Dashboard  │ │  Add     │ │Update│ │ Delete │
│   Page     │ │ Page     │ │Page  │ │ Page   │
└────────────┘ └──────────┘ └──────┘ └────────┘
```

### SEKARANG (Modern):

```
┌──────────────────────────────────────────────────┐
│            LOGIN PAGE                            │
│  ├─ Username Input                              │
│  ├─ Password Input                              │
│  └─ Login Button → Navigasi ke /dashboard       │
└──────────────────────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────┐
│         DASHBOARD HOME SCREEN                    │
│ ┌────────────────────────────────────────────┐  │
│ │ SIDEBAR (Always Accessible)                │  │
│ ├─ Sellora Logo & App Title                 │  │
│ ├─ User Profile (Username)                  │  │
│ ├─ Dashboard Menu                           │  │
│ ├─ Tambah Penjualan Menu                    │  │
│ ├─ Edit Penjualan Menu                      │  │
│ ├─ Logout Menu (dengan konfirmasi)          │  │
│ └────────────────────────────────────────────┘  │
│                                                  │
│ ┌────────────────────────────────────────────┐  │
│ │ MAIN CONTENT AREA (Dinamis)                │  │
│ │                                            │  │
│ │ [View 0: Dashboard]                        │  │
│ │ ├─ Header dengan gradien                  │  │
│ │ ├─ Stat Cards (Transaksi, Omzet)          │  │
│ │ ├─ Search Bar                             │  │
│ │ ├─ Date Filter                            │  │
│ │ └─ Data Table (All Sales)                 │  │
│ │                                            │  │
│ │ [View 1: Add Sales]                       │  │
│ │ ├─ Form dengan fields:                    │  │
│ │ │  - No Faktur                            │  │
│ │ │  - Tanggal Penjualan (Date Picker)      │  │
│ │ │  - Nama Pelanggan                       │  │
│ │ │  - Jumlah Barang                        │  │
│ │ │  - Total Penjualan                      │  │
│ │ └─ Tombol Simpan Data                     │  │
│ │                                            │  │
│ │ [View 2: Edit/Delete]                     │  │
│ │ ├─ List Penjualan (Selectable)            │  │
│ │ ├─ Form untuk edit (populated on select)  │  │
│ │ └─ Tombol Update & Hapus                  │  │
│ │                                            │  │
│ └────────────────────────────────────────────┘  │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 🎯 State Management Flow

```
DashboardHomeScreen (_DashboardHomeScreenState)
│
├─ _selectedIndex (0: Dashboard, 1: Add, 2: Edit/Delete)
│
├─ Dashboard State:
│  ├─ _salesFuture (fetch semua sales)
│  ├─ _searchQuery (search filter)
│  ├─ _selectedDate (date filter)
│  └─ _filterSales() (logic untuk filter)
│
├─ Add Sales State:
│  ├─ _formKey (form validation)
│  ├─ _invoiceController (input)
│  ├─ _customerController (input)
│  ├─ _quantityController (input)
│  ├─ _totalController (input)
│  ├─ _selectedSaleDate (date picker)
│  └─ _addSale() (submit logic)
│
└─ Edit/Delete State:
   ├─ _sales (list semua sales untuk dipilih)
   ├─ _selectedSale (selected untuk edit)
   ├─ _selectSale() (select logic)
   ├─ _updateSale() (update logic)
   └─ _deleteSale() (delete logic)
```

---

## 🧩 Component Architecture

```
lib/
│
├─ main.dart
│  └─ MyApp (Routing & Theme Configuration)
│
├─ screens/
│  ├─ login_page.dart
│  │  └─ LoginPage → navigates to /dashboard
│  │
│  └─ dashboard_home_screen.dart ⭐ MAIN
│     ├─ DashboardHomeScreen (Stateful)
│     └─ _DashboardHomeScreenState
│        ├─ build() → Scaffold + Drawer
│        ├─ _buildContent() → switch by index
│        ├─ _buildDashboardView()
│        ├─ _buildAddSalesView()
│        ├─ _buildEditDeleteView()
│        ├─ _buildHeaderCard()
│        └─ Business Logic Methods
│
├─ widgets/
│  ├─ sidebar_widget.dart
│  │  ├─ SidebarWidget (Stateful)
│  │  ├─ _buildNavItem()
│  │  └─ _handleLogout()
│  │
│  └─ stat_card_widget.dart
│     └─ StatCardWidget (Stateless)
│
├─ theme/
│  └─ app_theme.dart
│     ├─ Colors & Gradients
│     ├─ Box Shadows
│     ├─ Border Radius
│     └─ ThemeData
│
├─ services/
│  ├─ auth_service.dart (Login, Logout, GetMe)
│  └─ sales_service.dart (CRUD operations)
│
├─ models/
│  └─ sale.dart (Data model + fromJson)
│
└─ storage/
   └─ token_storage.dart (JWT token management)
```

---

## 🎨 UI Component Hierarchy

```
DashboardHomeScreen
│
├─ Scaffold
│  ├─ drawer: SidebarWidget
│  │  ├─ Header (Logo, Title, User Profile)
│  │  ├─ Navigation Items
│  │  │  ├─ Dashboard (with icon)
│  │  │  ├─ Tambah Penjualan (with icon)
│  │  │  ├─ Edit Penjualan (with icon)
│  │  │  └─ Logout (with icon & confirmation)
│  │  └─ Styling (Dark theme, gradient header)
│  │
│  └─ body: Column
│     ├─ _buildHeaderCard() [Reusable]
│     │  └─ Icon + Title + Subtitle + Version
│     │
│     └─ Dynamic Content Area:
│        │
│        ├─ [Dashboard View]
│        │  ├─ Row
│        │  │  ├─ StatCardWidget (Transaksi)
│        │  │  └─ StatCardWidget (Omzet)
│        │  ├─ Row
│        │  │  ├─ TextField (Search)
│        │  │  ├─ IconButton (Date Filter)
│        │  │  └─ IconButton (Clear)
│        │  └─ DataTable (Sales Data)
│        │
│        ├─ [Add Sales View]
│        │  └─ Form
│        │     ├─ TextFormField (Invoice)
│        │     ├─ DatePicker (Date)
│        │     ├─ TextFormField (Customer)
│        │     ├─ TextFormField (Quantity)
│        │     ├─ TextFormField (Total)
│        │     └─ ElevatedButton (Save)
│        │
│        └─ [Edit/Delete View]
│           ├─ ListView (Sales Selection)
│           └─ Form (Edit Fields)
│              ├─ TextFormField (Invoice - readonly)
│              ├─ DatePicker (Date)
│              ├─ TextFormField (Customer)
│              ├─ TextFormField (Quantity)
│              ├─ TextFormField (Total)
│              ├─ ElevatedButton (Update)
│              └─ ElevatedButton (Delete)
```

---

## 🔄 Data Flow Diagram

### Login Flow:

```
LoginPage.login()
    ↓
AuthService.login(username, password)
    ↓
API POST /auth/login
    ↓
Response: {token: "jwt..."}
    ↓
TokenStorage.saveToken()
    ↓
Navigate to /dashboard
    ↓
DashboardHomeScreen loads with token
```

### Dashboard Data Flow:

```
DashboardHomeScreen.initState()
    ↓
_loadSales()
    ↓
SalesService.getSales()
    ↓
API GET /sales (with Authorization header)
    ↓
Response: {data: [Sale, Sale, ...]}
    ↓
setState() → _salesFuture updated
    ↓
FutureBuilder builds DataTable with sales
    ↓
User searches/filters
    ↓
_filterSales(sales) → filtered list
    ↓
DataTable rebuilds with filtered data
```

### Add Sales Flow:

```
User clicks "Tambah Penjualan" in Sidebar
    ↓
setState(_selectedIndex = 1)
    ↓
_buildAddSalesView() renders form
    ↓
User fills form & clicks "Simpan Data"
    ↓
_addSale() validation
    ↓
SalesService.createSale()
    ↓
API POST /sales (with Authorization)
    ↓
Backend creates document in MongoDB
    ↓
Response: {data: newSale}
    ↓
Success notification + setState()
    ↓
_selectedIndex = 0 (back to Dashboard)
    ↓
_loadSales() refreshed
    ↓
DataTable shows new sale
```

### Edit/Delete Flow:

```
User clicks "Edit Penjualan" in Sidebar
    ↓
setState(_selectedIndex = 2)
    ↓
_buildEditDeleteView() renders
    ↓
User selects sale from list
    ↓
_selectSale() populates form
    ↓
User modifies fields & clicks "Update"
    ↓
_updateSale() validation
    ↓
SalesService.updateSale()
    ↓
API PUT /sales/:id
    ↓
Backend updates document
    ↓
Success notification
    ↓
_loadSales() refreshed

OR

User clicks "Hapus"
    ↓
Confirmation dialog
    ↓
_deleteSale()
    ↓
SalesService.deleteSale()
    ↓
API DELETE /sales/:id
    ↓
Backend deletes document
    ↓
Success notification
    ↓
_loadSales() refreshed
```

---

## 📊 Database Integration

```
Frontend (Flutter)
    ↓ (HTTP + JWT Token)
Backend (Express.js)
    ↓
MongoDB
    ├─ users collection
    │  └─ {_id, username, password}
    │
    └─ sales collection
       └─ {_id, invoiceNumber, saleDate, customerName, itemQuantity, totalSale}
```

---

## 🎭 State Transitions

```
Initial State
    ↓
Login Screen
    ├─ Valid credentials
    ↓
Dashboard Screen (View 0: Dashboard)
    ├─ Click "Tambah Penjualan"
    ↓
Dashboard Screen (View 1: Add Sales)
    ├─ Fill form & save
    ↓
Dashboard Screen (View 0: Dashboard) [Refreshed]
    ├─ Click "Edit Penjualan"
    ↓
Dashboard Screen (View 2: Edit/Delete)
    ├─ Select sale
    ↓
Dashboard Screen (View 2) [Form populated]
    ├─ Click Update/Delete
    ↓
Dashboard Screen (View 0: Dashboard) [Refreshed]
    ├─ Click "Logout"
    ↓
Confirmation Dialog
    ├─ Confirm
    ↓
Login Screen
```

---

## 🚀 Performance Considerations

| Aspect           | Implementation                                          |
| ---------------- | ------------------------------------------------------- |
| Page Transitions | No page reload, state management handles view switching |
| Data Fetching    | FutureBuilder with async/await                          |
| Form Validation  | Client-side validation before API call                  |
| Error Handling   | Try-catch blocks + user-friendly messages               |
| Loading States   | Loading indicators during API calls                     |
| Responsive       | MediaQuery + flexible widgets                           |
| Memory           | Proper disposal of controllers & listeners              |

---

## 📚 Key Design Patterns Used

1. **Stateful Widget** - DashboardHomeScreen untuk state management
2. **FutureBuilder** - Async data loading dengan UI states
3. **ListView.builder** - Efficient list rendering
4. **Form Validation** - Using GlobalKey<FormState>
5. **Controller Management** - TextEditingController disposal
6. **Error Handling** - Try-catch dengan error propagation
7. **Theme System** - Centralized AppTheme class
8. **Component Composition** - Reusable SidebarWidget & StatCardWidget

---

## 🔐 Security Measures

- ✅ JWT Token stored in secure storage (SharedPreferences)
- ✅ Token sent in Authorization header for protected endpoints
- ✅ Login validation before dashboard access
- ✅ Logout clears token from storage
- ✅ Error messages sanitized (tidak expose sensitive data)
- ✅ HTTPS ready (backend CORS configured)

---

## 📈 Scalability Readiness

- ✅ Component-based architecture (easy to add new features)
- ✅ Centralized theme system (easy to rebrand)
- ✅ Service layer abstraction (easy to change API)
- ✅ Reusable widgets (reduce code duplication)
- ✅ State management ready for upgrade to Provider/Riverpod
- ✅ Environment configuration support

---

**Architecture Version:** 1.0  
**Last Updated:** 2026-08-29  
**Status:** Production Ready ✅

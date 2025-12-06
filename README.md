# Library Management System

A modern, feature-rich Library Management System built with **Flutter** and **Supabase**. This application serves both Library Administrators and Members, providing a seamless experience for managing books, borrowing, and user profiles.

## 🚀 Features

### 🛡️ Admin Panel
- **Dashboard**: Overview of library statistics.
- **Book Management**: Add, update, and remove books from the catalog.
- **Inventory Control**: Manage physical copies of books.
- **Borrowing Management**: View and manage active borrowing sessions.

### 👤 Member Panel
- **Book Discovery**: Browse and search for books by category or title.
- **Borrowing**: Request to borrow books and track due dates.
- **Profile**: Manage personal details and view borrowing history.

### 🔐 Authentication
- Secure Email/Password login.
- Role-based access control (Admin vs. Member).

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: Dart
- **Backend**: [Supabase](https://supabase.com/) (PostgreSQL + Auth)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **UI/UX**: `flutter_screenutil` for responsiveness, Custom Theming.

## 📂 Project Structure

```
lib/
├── core/           # Shared utilities, theme, constants
├── feature/        # Feature-based modules (Admin, Member, Auth)
├── service/        # Data services and Supabase integration
└── main.dart       # Application entry point
```

## ⚙️ Setup & Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/library_project.git
    cd library_project
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration**
    Create a `.env` file in the root directory and add your Supabase credentials:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

## 📖 Documentation

For detailed information about the database schema, architecture, and workflows, please refer to the [DOCUMENTATION.md](DOCUMENTATION.md) file.

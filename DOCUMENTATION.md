# Project Documentation

## 1. Architecture Overview

This project follows a **Feature-First** architecture, organizing code by business features rather than technical layers. This ensures scalability and maintainability.

### Folder Structure
- **`lib/core`**: Contains shared utilities, constants, theme definitions, and global widgets.
- **`lib/feature`**: Contains the main business logic, split by feature:
  - **`admin`**: Admin-specific screens and logic (Dashboard, Book Management).
  - **`authentication`**: Login and Signup flows.
  - **`member`**: Member-specific screens (Dashboard, Borrowing).
  - **`onboarding`**: Initial app introduction screens.
- **`lib/service`**: Contains data services and repositories, primarily for interacting with Supabase.

### State Management
The project uses **Riverpod** for state management. Providers are used to manage app state, handle dependency injection, and separate business logic from UI code.

---

## 2. Database Schema (Supabase)

The application uses Supabase (PostgreSQL) as its backend. Below is the SQL schema used for the project.

### Tables

#### 1. Profiles
Links to Supabase Auth users and stores role information.
```sql
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Librarian', 'Member')) DEFAULT 'Member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Categories
Stores book categories.
```sql
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. Books
Stores general book information (Title, Author, etc.).
```sql
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(120),
    description TEXT,
    category_id INT REFERENCES categories(id) ON DELETE SET NULL,
    daily_price DECIMAL(10, 2) DEFAULT 0.00, -- Added for pricing model
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 4. Book Copies
Tracks physical copies of books and their status.
```sql
CREATE TABLE IF NOT EXISTS book_copies (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK(status IN ('Available', 'Borrowed', 'Lost')) DEFAULT 'Available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 5. Members
Stores additional member details like email, phone, and address.
```sql
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    email VARCHAR(150),
    phone VARCHAR(30),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 6. Borrowing
Tracks borrowing transactions and requests.
```sql
CREATE TABLE IF NOT EXISTS borrowing (
    id SERIAL PRIMARY KEY,
    copy_id INT NOT NULL REFERENCES book_copies(id) ON DELETE CASCADE,
    member_id INT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    borrowed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    due_at TIMESTAMP WITH TIME ZONE,
    returned_at TIMESTAMP WITH TIME ZONE,
    status TEXT CHECK(status IN ('pending', 'approved', 'declined', 'returned')) DEFAULT 'pending',
    days_requested INT CHECK(days_requested >= 1 AND days_requested <= 15),
    total_cost DECIMAL(10, 2)
);
```

### Triggers
- **`set_copy_borrowed`**: Automatically updates `book_copies` status to 'Borrowed' ONLY when a borrowing record's status is set to 'approved'.
- **`set_copy_returned`**: Automatically updates `book_copies` status to 'Available' when `returned_at` is updated. Also updates the borrowing record status to 'returned'.

---

## 3. Key Workflows

### Authentication
- Users log in via email/password using Supabase Auth.
- Upon login, the app checks the `profiles` table to determine if the user is an **Admin** or **Member** and routes them to the appropriate dashboard.

### Admin Workflows
- **Add Book**: Admins can add new books to the catalog, including setting a `daily_price`.
- **Manage Borrowing Requests**: Admins view a list of pending borrowing requests. They can **Approve** (which marks the book copy as borrowed) or **Decline** the request.

### Member Workflows
- **Browse Books**: Members can view available books and their daily rates.
- **Request to Borrow**: Members select a duration (1-15 days), see the total cost, and submit a borrowing request.
- **Status Tracking**: Members can see if their request is pending, approved, or declined.

## 4. Environment Variables
The project uses `flutter_dotenv` to manage sensitive keys. Ensure your `.env` file contains:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

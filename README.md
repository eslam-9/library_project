-- ================================================
-- LIBRARY SYSTEM SCHEMA FOR SUPABASE + FLUTTER
-- ================================================

-- ================================================
-- 1. PROFILES (Linked to Supabase Auth users)
-- ================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Librarian', 'Member')) DEFAULT 'Member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index to speed up user searching
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);


-- ================================================
-- 2. CATEGORIES
-- ================================================
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);


-- ================================================
-- 3. BOOKS (Book information only)
-- ================================================
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(120),
    description TEXT,
    category_id INT REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_category ON books(category_id);


-- ================================================
-- 4. BOOK COPIES (Physical copies of books)
-- ================================================
CREATE TABLE IF NOT EXISTS book_copies (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK(status IN ('Available', 'Borrowed', 'Lost')) DEFAULT 'Available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookcopies_status ON book_copies(status);
CREATE INDEX IF NOT EXISTS idx_bookcopies_bookid ON book_copies(book_id);


-- ================================================
-- 5. MEMBERS (Library member accounts)
-- ================================================
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    email VARCHAR(150),
    phone VARCHAR(30),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_members_email ON members(email);


-- ================================================
-- 6. BORROWING
-- Track borrowing of individual copies
-- ================================================
CREATE TABLE IF NOT EXISTS borrowing (
    id SERIAL PRIMARY KEY,
    copy_id INT NOT NULL REFERENCES book_copies(id) ON DELETE CASCADE,
    member_id INT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    borrowed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    due_at TIMESTAMP WITH TIME ZONE,
    returned_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_borrow_copy ON borrowing(copy_id);
CREATE INDEX IF NOT EXISTS idx_borrow_member ON borrowing(member_id);
CREATE INDEX IF NOT EXISTS idx_borrow_returned ON borrowing(returned_at);


-- =================================================
-- 7. TRIGGER: When a copy is borrowed → set status
-- =================================================
CREATE OR REPLACE FUNCTION set_copy_borrowed()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book_copies
    SET status = 'Borrowed'
    WHERE id = NEW.copy_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_copy_borrowed
AFTER INSERT ON borrowing
FOR EACH ROW
EXECUTE FUNCTION set_copy_borrowed();


-- =================================================
-- 8. TRIGGER: When a copy is returned → available
-- =================================================
CREATE OR REPLACE FUNCTION set_copy_returned()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.returned_at IS NOT NULL THEN
        UPDATE book_copies
        SET status = 'Available'
        WHERE id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_copy_returned
AFTER UPDATE ON borrowing
FOR EACH ROW
EXECUTE FUNCTION set_copy_returned();

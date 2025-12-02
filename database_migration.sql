-- ================================================
-- LIBRARY SYSTEM - BORROWING WITH PRICING MIGRATION
-- ================================================
-- Run this script in your Supabase SQL Editor

-- Add daily_price to books table
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS daily_price DECIMAL(10, 2) DEFAULT 0.00;

-- Add new columns to borrowing table
ALTER TABLE borrowing 
ADD COLUMN IF NOT EXISTS status TEXT CHECK(status IN ('pending', 'approved', 'declined', 'returned')) DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS days_requested INT CHECK(days_requested >= 1 AND days_requested <= 15),
ADD COLUMN IF NOT EXISTS total_cost DECIMAL(10, 2);

-- Create index for status filtering
CREATE INDEX IF NOT EXISTS idx_borrowing_status ON borrowing(status);

-- Update existing borrowing records to have 'approved' status
UPDATE borrowing SET status = 'approved' WHERE status IS NULL OR status = 'pending';

-- Update trigger to only set status to 'Borrowed' when borrowing is approved
DROP TRIGGER IF EXISTS trg_copy_borrowed ON borrowing;

CREATE OR REPLACE FUNCTION set_copy_borrowed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' THEN
        UPDATE book_copies
        SET status = 'Borrowed'
        WHERE id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_copy_borrowed
AFTER INSERT OR UPDATE ON borrowing
FOR EACH ROW
EXECUTE FUNCTION set_copy_borrowed();

-- Update return trigger to also update borrowing status
DROP TRIGGER IF EXISTS trg_copy_returned ON borrowing;

CREATE OR REPLACE FUNCTION set_copy_returned()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.returned_at IS NOT NULL THEN
        UPDATE book_copies
        SET status = 'Available'
        WHERE id = NEW.copy_id;
        
        UPDATE borrowing
        SET status = 'returned'
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_copy_returned
AFTER UPDATE ON borrowing
FOR EACH ROW
EXECUTE FUNCTION set_copy_returned();

-- ================================================
-- FIX: Change total_cost column type to DECIMAL
-- ================================================
-- Run this script in your Supabase SQL Editor

-- First, drop the column if it exists with wrong type
ALTER TABLE borrowing 
DROP COLUMN IF EXISTS total_cost;

-- Add it back with the correct DECIMAL type
ALTER TABLE borrowing 
ADD COLUMN total_cost DECIMAL(10, 2);

-- Also ensure daily_price in books table is DECIMAL
ALTER TABLE books 
DROP COLUMN IF EXISTS daily_price;

ALTER TABLE books 
ADD COLUMN daily_price DECIMAL(10, 2) DEFAULT 0.00;

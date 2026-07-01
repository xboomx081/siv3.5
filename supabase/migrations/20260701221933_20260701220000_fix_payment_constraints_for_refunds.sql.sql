/*
# Fix Payment Constraints for Refunds

## Problem
The payments table has constraints that don't support refund processing:
1. `payment_type` only allows 'received' or 'made' - not 'refund'
2. `payment_method` doesn't include 'store_credit'

## Changes
1. Add 'refund' to the payment_type check constraint
2. Add 'store_credit' to the payment_method check constraint

This allows the sales returns system to properly record refund payments.
*/

-- Drop existing constraints
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_payment_type_check;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_payment_method_check;

-- Add updated constraints
ALTER TABLE payments ADD CONSTRAINT payments_payment_type_check
  CHECK (payment_type IN ('received', 'made', 'refund'));

ALTER TABLE payments ADD CONSTRAINT payments_payment_method_check
  CHECK (payment_method IN ('cash', 'bank_transfer', 'bkash', 'nagad', 'rocket', 'sslcommerz', 'cheque', 'card', 'store_credit'));
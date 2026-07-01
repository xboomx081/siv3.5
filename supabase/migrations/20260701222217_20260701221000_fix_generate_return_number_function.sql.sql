/*
# Fix generate_sales_return_number Function

## Problem
The generate_sales_return_number() function has an ambiguous column reference.
The variable name `return_number` conflicts with the table column of the same name.

## Fix
- Rename the local variable to avoid ambiguity
- Use explicit table.column reference
*/

CREATE OR REPLACE FUNCTION generate_sales_return_number()
RETURNS TEXT AS $$
DECLARE
  prefix TEXT := 'SR-';
  next_num INTEGER;
  new_return_number TEXT;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(sr.return_number FROM 4) AS INTEGER)), 0) + 1
  INTO next_num
  FROM sales_returns sr
  WHERE sr.return_number LIKE 'SR-%';
  
  new_return_number := prefix || LPAD(next_num::TEXT, 5, '0');
  RETURN new_return_number;
END;
$$ LANGUAGE plpgsql;
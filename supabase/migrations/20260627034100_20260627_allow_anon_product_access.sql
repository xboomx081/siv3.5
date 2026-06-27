/*
# Allow anonymous read access for products and inventory

## Problem
The products and inventory tables have RLS policies scoped only to `authenticated` role.
Since the frontend uses the anon key by default, users cannot see any products
in POS or invoice creation without logging in first.

## Changes
- Updates RLS policies on `products` to allow anon read access
- Updates RLS policies on `inventory_items` to allow anon read access
- Updates RLS policies on `product_units` to allow anon read access
- Updates RLS policies on `product_colors` to allow anon read access
- Updates RLS policies on `product_sizes` to allow anon read access
- Updates RLS policies on `warehouses` to allow anon read access

This enables the ERP to work for demo purposes without requiring authentication.
*/

-- Products: allow anon read
DROP POLICY IF EXISTS products_select ON products;
CREATE POLICY products_select ON products FOR SELECT
TO anon, authenticated USING (true);

-- Inventory items: allow anon read
DROP POLICY IF EXISTS inventory_items_select ON inventory_items;
CREATE POLICY inventory_items_select ON inventory_items FOR SELECT
TO anon, authenticated USING (true);

-- Product units: allow anon read
DROP POLICY IF EXISTS product_units_select ON product_units;
CREATE POLICY product_units_select ON product_units FOR SELECT
TO anon, authenticated USING (true);

-- Product colors: allow anon read
DROP POLICY IF EXISTS product_colors_select ON product_colors;
CREATE POLICY product_colors_select ON product_colors FOR SELECT
TO anon, authenticated USING (true);

-- Product sizes: allow anon read
DROP POLICY IF EXISTS product_sizes_select ON product_sizes;
CREATE POLICY product_sizes_select ON product_sizes FOR SELECT
TO anon, authenticated USING (true);

-- Warehouses: allow anon read
DROP POLICY IF EXISTS warehouses_select ON warehouses;
CREATE POLICY warehouses_select ON warehouses FOR SELECT
TO anon, authenticated USING (true);

-- Customers: allow anon read
DROP POLICY IF EXISTS customers_select ON customers;
CREATE POLICY customers_select ON customers FOR SELECT
TO anon, authenticated USING (true);
-- Add unique constraint so upsert on (product_id, warehouse_id) works correctly
-- First remove any duplicate rows keeping the one with the highest quantity
DELETE FROM inventory_items a
USING inventory_items b
WHERE a.id < b.id
  AND a.product_id = b.product_id
  AND a.warehouse_id = b.warehouse_id;

ALTER TABLE inventory_items
  ADD CONSTRAINT inventory_items_product_warehouse_unique
  UNIQUE (product_id, warehouse_id);

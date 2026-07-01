
-- Trigger function: deduct stock and record stock movement when invoice_items are inserted
-- This fires on each invoice_item row inserted, and only acts when the parent invoice is a sale (not a return)
CREATE OR REPLACE FUNCTION deduct_stock_on_invoice_item()
RETURNS TRIGGER AS $$
DECLARE
  v_inv_item RECORD;
  v_new_qty NUMERIC;
  v_base_qty NUMERIC;
BEGIN
  -- Use base_quantity if set, otherwise fall back to quantity
  v_base_qty := COALESCE(NEW.base_quantity, NEW.quantity);

  -- Find the best inventory item for this product (highest stock)
  SELECT id, warehouse_id, quantity_on_hand
  INTO v_inv_item
  FROM inventory_items
  WHERE product_id = NEW.product_id
  ORDER BY quantity_on_hand DESC
  LIMIT 1;

  -- No inventory record — nothing to deduct
  IF v_inv_item IS NULL THEN
    RETURN NEW;
  END IF;

  -- Deduct stock (floor at 0)
  v_new_qty := GREATEST(0, COALESCE(v_inv_item.quantity_on_hand, 0) - v_base_qty);

  UPDATE inventory_items
  SET quantity_on_hand = v_new_qty,
      updated_at = NOW()
  WHERE id = v_inv_item.id;

  -- Record stock movement
  INSERT INTO stock_movements (
    product_id,
    warehouse_id,
    movement_type,
    quantity,
    unit_cost,
    reference_type,
    reference_id,
    reference_number,
    unit_name,
    unit_conversion_factor,
    base_quantity,
    notes
  )
  SELECT
    NEW.product_id,
    v_inv_item.warehouse_id,
    'sale',
    -v_base_qty,
    COALESCE(p.cost_price, 0),
    'invoice',
    NEW.invoice_id,
    i.invoice_number,
    NEW.unit_name,
    COALESCE(NEW.unit_conversion_factor, 1),
    v_base_qty,
    'Sale - ' || COALESCE(NEW.quantity::text, '') || COALESCE(' ' || NEW.unit_name, ' units')
  FROM products p
  JOIN invoices i ON i.id = NEW.invoice_id
  WHERE p.id = NEW.product_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop old trigger if it exists
DROP TRIGGER IF EXISTS trg_deduct_stock_on_invoice_item ON invoice_items;

-- Create the trigger
CREATE TRIGGER trg_deduct_stock_on_invoice_item
AFTER INSERT ON invoice_items
FOR EACH ROW
EXECUTE FUNCTION deduct_stock_on_invoice_item();

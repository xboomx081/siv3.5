-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  full_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  role text NOT NULL DEFAULT 'sales_executive'
    CHECK (role IN ('super_admin','manager','sales_executive','inventory_manager','accountant','delivery_staff','customer_portal','store_customer')),
  avatar_url text,
  phone text,
  department text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles_select" ON profiles;
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "profiles_insert" ON profiles;
CREATE POLICY "profiles_insert" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "profiles_update" ON profiles;
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "profiles_delete" ON profiles;
CREATE POLICY "profiles_delete" ON profiles FOR DELETE TO authenticated USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- CATEGORIES
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  parent_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  image_url text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS categories_tenant_slug ON categories(tenant_id, slug);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "cats_select" ON categories;
CREATE POLICY "cats_select" ON categories FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "cats_insert" ON categories;
CREATE POLICY "cats_insert" ON categories FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "cats_update" ON categories;
CREATE POLICY "cats_update" ON categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "cats_delete" ON categories;
CREATE POLICY "cats_delete" ON categories FOR DELETE TO authenticated USING (true);

-- ============================================================
-- BRANDS
-- ============================================================
CREATE TABLE IF NOT EXISTS brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  slug text NOT NULL,
  logo_url text,
  description text,
  country_of_origin text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS brands_tenant_slug ON brands(tenant_id, slug);
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "brands_select" ON brands;
CREATE POLICY "brands_select" ON brands FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "brands_insert" ON brands;
CREATE POLICY "brands_insert" ON brands FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "brands_update" ON brands;
CREATE POLICY "brands_update" ON brands FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "brands_delete" ON brands;
CREATE POLICY "brands_delete" ON brands FOR DELETE TO authenticated USING (true);

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  sku text NOT NULL,
  barcode text,
  name text NOT NULL,
  description text,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  brand_id uuid REFERENCES brands(id) ON DELETE SET NULL,
  unit text NOT NULL DEFAULT 'pcs',
  cost_price decimal(15,2) NOT NULL DEFAULT 0,
  sale_price decimal(15,2) NOT NULL DEFAULT 0,
  mrp decimal(15,2),
  tax_rate decimal(5,2) NOT NULL DEFAULT 0,
  min_stock_level integer NOT NULL DEFAULT 0,
  max_stock_level integer,
  image_url text,
  images jsonb DEFAULT '[]',
  specifications jsonb DEFAULT '{}',
  is_active boolean NOT NULL DEFAULT true,
  is_online boolean NOT NULL DEFAULT false,
  weight decimal(10,3),
  dimensions jsonb,
  warranty_months integer DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS products_tenant_sku ON products(tenant_id, sku);
CREATE INDEX IF NOT EXISTS products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS products_brand ON products(brand_id);
CREATE INDEX IF NOT EXISTS products_name_search ON products USING gin(to_tsvector('english', name));

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "products_select" ON products;
CREATE POLICY "products_select" ON products FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "products_insert" ON products;
CREATE POLICY "products_insert" ON products FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "products_update" ON products;
CREATE POLICY "products_update" ON products FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "products_delete" ON products;
CREATE POLICY "products_delete" ON products FOR DELETE TO authenticated USING (true);

-- ============================================================
-- PRODUCT VARIANTS
-- ============================================================
CREATE TABLE IF NOT EXISTS product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  sku text NOT NULL,
  barcode text,
  name text NOT NULL,
  attributes jsonb NOT NULL DEFAULT '{}',
  cost_price decimal(15,2),
  sale_price decimal(15,2),
  image_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS variants_product ON product_variants(product_id);
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "variants_select" ON product_variants;
CREATE POLICY "variants_select" ON product_variants FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "variants_insert" ON product_variants;
CREATE POLICY "variants_insert" ON product_variants FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "variants_update" ON product_variants;
CREATE POLICY "variants_update" ON product_variants FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "variants_delete" ON product_variants;
CREATE POLICY "variants_delete" ON product_variants FOR DELETE TO authenticated USING (true);

-- ============================================================
-- WAREHOUSES
-- ============================================================
CREATE TABLE IF NOT EXISTS warehouses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  code text NOT NULL,
  address text,
  city text,
  contact_person text,
  contact_phone text,
  is_default boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "wh_select" ON warehouses;
CREATE POLICY "wh_select" ON warehouses FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "wh_insert" ON warehouses;
CREATE POLICY "wh_insert" ON warehouses FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "wh_update" ON warehouses;
CREATE POLICY "wh_update" ON warehouses FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "wh_delete" ON warehouses;
CREATE POLICY "wh_delete" ON warehouses FOR DELETE TO authenticated USING (true);

-- ============================================================
-- INVENTORY ITEMS (stock levels)
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  variant_id uuid REFERENCES product_variants(id) ON DELETE CASCADE,
  warehouse_id uuid NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
  quantity_on_hand decimal(15,3) NOT NULL DEFAULT 0,
  quantity_reserved decimal(15,3) NOT NULL DEFAULT 0,
  quantity_incoming decimal(15,3) NOT NULL DEFAULT 0,
  last_counted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS inv_items_product ON inventory_items(product_id);
CREATE INDEX IF NOT EXISTS inv_items_warehouse ON inventory_items(warehouse_id);

ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "inv_select" ON inventory_items;
CREATE POLICY "inv_select" ON inventory_items FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "inv_insert" ON inventory_items;
CREATE POLICY "inv_insert" ON inventory_items FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "inv_update" ON inventory_items;
CREATE POLICY "inv_update" ON inventory_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "inv_delete" ON inventory_items;
CREATE POLICY "inv_delete" ON inventory_items FOR DELETE TO authenticated USING (true);

-- ============================================================
-- STOCK MOVEMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS stock_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  product_id uuid NOT NULL REFERENCES products(id),
  variant_id uuid REFERENCES product_variants(id),
  warehouse_id uuid NOT NULL REFERENCES warehouses(id),
  movement_type text NOT NULL
    CHECK (movement_type IN ('purchase','sale','adjustment','transfer_in','transfer_out','return_in','return_out','damage','opening')),
  quantity decimal(15,3) NOT NULL,
  unit_cost decimal(15,2),
  reference_type text,
  reference_id uuid,
  reference_number text,
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS movements_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS movements_created ON stock_movements(created_at DESC);

ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "movements_select" ON stock_movements;
CREATE POLICY "movements_select" ON stock_movements FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "movements_insert" ON stock_movements;
CREATE POLICY "movements_insert" ON stock_movements FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "movements_update" ON stock_movements;
CREATE POLICY "movements_update" ON stock_movements FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "movements_delete" ON stock_movements;
CREATE POLICY "movements_delete" ON stock_movements FOR DELETE TO authenticated USING (true);

-- ============================================================
-- SUPPLIERS
-- ============================================================
CREATE TABLE IF NOT EXISTS suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  code text NOT NULL,
  name text NOT NULL,
  company_name text,
  email text,
  phone text,
  mobile text,
  address text,
  city text,
  country text DEFAULT 'Bangladesh',
  tax_id text,
  credit_limit decimal(15,2) NOT NULL DEFAULT 0,
  credit_days integer NOT NULL DEFAULT 0,
  payment_terms text,
  bank_details jsonb DEFAULT '{}',
  outstanding_balance decimal(15,2) NOT NULL DEFAULT 0,
  total_purchases decimal(15,2) NOT NULL DEFAULT 0,
  notes text,
  rating integer CHECK (rating BETWEEN 1 AND 5),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS suppliers_tenant_code ON suppliers(tenant_id, code);
CREATE INDEX IF NOT EXISTS suppliers_name ON suppliers(name);

ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "sup_select" ON suppliers;
CREATE POLICY "sup_select" ON suppliers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "sup_insert" ON suppliers;
CREATE POLICY "sup_insert" ON suppliers FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "sup_update" ON suppliers;
CREATE POLICY "sup_update" ON suppliers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "sup_delete" ON suppliers;
CREATE POLICY "sup_delete" ON suppliers FOR DELETE TO authenticated USING (true);

-- ============================================================
-- CUSTOMERS
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  code text NOT NULL,
  name text NOT NULL,
  type text NOT NULL DEFAULT 'retail'
    CHECK (type IN ('retail','contractor','builder','architect','interior_designer','corporate','government')),
  company_name text,
  email text,
  phone text,
  mobile text,
  address text,
  city text,
  country text DEFAULT 'Bangladesh',
  tax_id text,
  credit_limit decimal(15,2) NOT NULL DEFAULT 0,
  credit_days integer NOT NULL DEFAULT 0,
  outstanding_balance decimal(15,2) NOT NULL DEFAULT 0,
  total_purchases decimal(15,2) NOT NULL DEFAULT 0,
  loyalty_points integer NOT NULL DEFAULT 0,
  discount_percent decimal(5,2) NOT NULL DEFAULT 0,
  assigned_to uuid REFERENCES profiles(id),
  notes text,
  tags text[],
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS customers_tenant_code ON customers(tenant_id, code);
CREATE INDEX IF NOT EXISTS customers_name ON customers(name);
CREATE INDEX IF NOT EXISTS customers_type ON customers(type);

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "cust_select" ON customers;
CREATE POLICY "cust_select" ON customers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "cust_insert" ON customers;
CREATE POLICY "cust_insert" ON customers FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "cust_update" ON customers;
CREATE POLICY "cust_update" ON customers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "cust_delete" ON customers;
CREATE POLICY "cust_delete" ON customers FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS customer_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  note text NOT NULL,
  note_type text DEFAULT 'general' CHECK (note_type IN ('general','call','meeting','follow_up','complaint')),
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE customer_notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "cn_select" ON customer_notes;
CREATE POLICY "cn_select" ON customer_notes FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "cn_insert" ON customer_notes;
CREATE POLICY "cn_insert" ON customer_notes FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "cn_update" ON customer_notes;
CREATE POLICY "cn_update" ON customer_notes FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "cn_delete" ON customer_notes;
CREATE POLICY "cn_delete" ON customer_notes FOR DELETE TO authenticated USING (true);
-- Drop attribute payload column from checkout line items
ALTER TABLE "SaleLineItem" DROP COLUMN IF EXISTS "selectedAttributes";

-- Drop attribute feature tables
DROP TABLE IF EXISTS "ProductAttribute" CASCADE;
DROP TABLE IF EXISTS "AttributeOption" CASCADE;
DROP TABLE IF EXISTS "Attribute" CASCADE;

-- Drop attribute enum type
DROP TYPE IF EXISTS "AttributeSelectionType";

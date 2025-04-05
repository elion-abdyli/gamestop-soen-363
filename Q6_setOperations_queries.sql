-- Set operations queries:

--- Ex 1: UNION SET OPERATION ---
-- with  UNION:  (finds all assets that are used in symbols, either as base or quote assets)
SELECT base_asset AS asset_id FROM Symbol
UNION
SELECT quote_asset AS asset_id FROM Symbol;

-- Equivalent without UNION: (Alternative approach using OR condition)
SELECT DISTINCT a.asset_id
FROM Asset a
WHERE EXISTS (
    SELECT 1 FROM Symbol s 
    WHERE s.base_asset = a.asset_id 
       OR s.quote_asset = a.asset_id
);

--- Ex 2: INTERSECT SET OPERATION ---
-- with  INTERSECT:  (finds assets that are used as both base assets and quote assets in trading pairs.)
SELECT base_asset AS asset_id FROM Symbol
INTERSECT
SELECT quote_asset AS asset_id FROM Symbol;

-- Equivalent without INTERSECT: (Alternative approach using EXISTS)
SELECT DISTINCT base_asset AS asset_id 
FROM Symbol s1
WHERE EXISTS (
    SELECT 1 
    FROM Symbol s2
    WHERE s2.quote_asset = s1.base_asset
);

--- Ex 3: DIFFERENCE SET OPERATION ---
-- with  EXCEPT:  (finds assets that are used exclusively as base assets.)
SELECT base_asset AS asset_id FROM Symbol
EXCEPT
SELECT quote_asset AS asset_id FROM Symbol;

-- Equivalent without EXCEPT: (Alternative approach using NOT EXISTS)
SELECT DISTINCT base_asset AS asset_id 
FROM Symbol s1
WHERE NOT EXISTS (
    SELECT 1 
    FROM Symbol s2
    WHERE s2.quote_asset = s1.base_asset
);
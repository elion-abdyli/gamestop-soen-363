-- Inner Join: Get all trading pairs with their market names
SELECT 
    s.market_id, 
    s.base_asset, 
    s.quote_asset,
    m.name AS market_name
FROM Symbol s
INNER JOIN Market m ON s.market_id = m.market_id;

-- Cartesian product equivalent for inner join
SELECT 
    s.market_id, 
    s.base_asset, 
    s.quote_asset,
    m.name AS market_name
FROM Symbol s, Market m
WHERE s.market_id = m.market_id;

-------------------------------------------------------
-- Outer join: Get all assets and their trading pairs
SELECT 
    a.asset_id, 
    s.market_id, 
    s.base_asset, 
    s.quote_asset
FROM Asset a
LEFT OUTER JOIN Symbol s ON a.asset_id = s.base_asset OR a.asset_id = s.quote_asset;

-- Cartesian product equivalent for outer join
SELECT 
    a.asset_id, 
    s.market_id, 
    s.base_asset, 
    s.quote_asset
FROM Asset a, Symbol s
WHERE a.asset_id = s.base_asset OR a.asset_id = s.quote_asset
UNION
SELECT 
    a.asset_id, 
    NULL AS market_id, 
    NULL AS base_asset, 
    NULL AS quote_asset
FROM Asset a
WHERE NOT EXISTS (
    SELECT 1 FROM Symbol s 
    WHERE a.asset_id = s.base_asset OR a.asset_id = s.quote_asset
);

-------------------------------------------------------
-- Full join: Show all assets and markets
SELECT 
    a.asset_id, 
    m.market_id, 
    m.name AS market_name
FROM Asset a
FULL OUTER JOIN Market_Asset ma ON a.asset_id = ma.asset_id
FULL OUTER JOIN Market m ON ma.market_id = m.market_id;

-- Cartesian product equivalent for full join
-- Part 1: Matching pairs
SELECT 
    a.asset_id, 
    m.market_id, 
    m.name AS market_name
FROM Asset a, Market_Asset ma, Market m
WHERE a.asset_id = ma.asset_id AND ma.market_id = m.market_id
UNION
-- Part 2: Assets without markets
SELECT 
    a.asset_id, 
    NULL AS market_id, 
    NULL AS market_name
FROM Asset a
WHERE NOT EXISTS (
    SELECT 1 FROM Market_Asset ma 
    WHERE ma.asset_id = a.asset_id
)
UNION
-- Part 3: Markets without assets
SELECT 
    NULL AS asset_id, 
    m.market_id, 
    m.name AS market_name
FROM Market m
WHERE NOT EXISTS (
    SELECT 1 FROM Market_Asset ma 
    WHERE ma.market_id = m.market_id
);

-------------------------------------------------------
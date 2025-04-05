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
-- Few queries to demonstrate use of Null values for undefined / non-applicable:
-- ex 1/ Query to find assets that have never been traded (no trade data)

SELECT 
    a.asset_id,
    'Never been traded' AS status
FROM Asset a
LEFT JOIN (
    SELECT DISTINCT base_asset AS asset_id FROM Trade
    UNION
    SELECT DISTINCT quote_asset AS asset_id FROM Trade
) AS traded_assets ON a.asset_id = traded_assets.asset_id
WHERE traded_assets.asset_id IS NULL;

-- ex 2/ Query to find symbols where order data is non-applicable: (Some symbols might have events but no orders (e.g., only price updates or trades))
SELECT 
    s.market_id,
    s.base_asset,
    s.quote_asset,
    e.time_utc,
    e.price AS event_price,
    o.qty AS order_quantity,
    o.type AS order_type,
    CASE 
        WHEN o.time_utc IS NULL THEN 'No order applicable for this event'
        ELSE 'Has corresponding order'
    END AS explanation
FROM Symbol s
JOIN Event e ON s.market_id = e.market_id 
            AND s.base_asset = e.base_asset 
            AND s.quote_asset = e.quote_asset
LEFT JOIN "Order" o ON e.market_id = o.market_id 
                     AND e.base_asset = o.base_asset 
                     AND e.quote_asset = o.quote_asset
                     AND e.time_utc = o.time_utc
WHERE o.time_utc IS NULL;

-------------------------------------------------------
--  GROUP BY queries' examples:
-- Ex 1: GROUP BY without WHERE or HAVING (Count the number of events per trading pair)
SELECT 
    market_id,
    base_asset,
    quote_asset,
    COUNT(*) AS event_count
FROM Event
GROUP BY market_id, base_asset, quote_asset;

-- Ex 2: GROUP BY with WHERE clause (Count the number of events per trading pair, but only for BTC pairs)
SELECT 
    market_id,
    base_asset,
    quote_asset,
    COUNT(*) AS event_count
FROM Event
WHERE base_asset = 'BTC' OR quote_asset = 'BTC'
GROUP BY market_id, base_asset, quote_asset;

-- Ex 3: GROUP BY with HAVING clause (Find trading pairs with more than 1 event)
SELECT 
    market_id,
    base_asset,
    quote_asset,
    COUNT(*) AS event_count
FROM Event
GROUP BY market_id, base_asset, quote_asset
HAVING COUNT(*) > 1;

-- Ex 4: GROUP BY with both WHERE and HAVING (Find trading pairs with USDT and average price > 100)
SELECT 
    market_id,
    base_asset,
    quote_asset,
    AVG(price) AS avg_price,
    COUNT(*) AS event_count
FROM Event
WHERE quote_asset = 'USDT'
GROUP BY market_id, base_asset, quote_asset
HAVING AVG(price) > 100;

-------------------------------------------------------
-- Join query with nested sub-query (2 levels nesting): Find all trades for the trading pairs with the highest price
SELECT 
    t.market_id,
    t.base_asset,
    t.quote_asset,
    t.time_utc,
    t.qty,
    t.price,
    e.price AS original_event_price
FROM Trade t
JOIN Event e ON t.market_id = e.market_id 
             AND t.base_asset = e.base_asset 
             AND t.quote_asset = e.quote_asset
             AND t.time_utc = e.time_utc
WHERE (t.market_id, t.base_asset, t.quote_asset) IN (
    -- First nested subquery: Find the trading pair with maximum price
    SELECT 
        market_id, 
        base_asset, 
        quote_asset
    FROM Event
    WHERE price = (
        -- Second nested subquery: Find the maximum price
        SELECT MAX(price)
        FROM Event
    )
);

-------------------------------------------------------
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

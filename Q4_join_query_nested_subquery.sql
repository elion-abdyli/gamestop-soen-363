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
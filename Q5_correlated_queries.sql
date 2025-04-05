-- Correlated Queries

-- Ex 1: correlated query where the inner query references the outer query's row (Find events with higher than average price for their specific trading pair)
SELECT 
    e1.market_id,
    e1.base_asset,
    e1.quote_asset,
    e1.time_utc,
    e1.price
FROM Event e1
WHERE e1.price > (
    -- Correlated subquery calculates average price for this specific trading pair
    SELECT AVG(e2.price)
    FROM Event e2
    WHERE e2.market_id = e1.market_id
    AND e2.base_asset = e1.base_asset
    AND e2.quote_asset = e1.quote_asset
);

-- Ex 2: correlated NOT EXISTS query (Find trading pairs where all events have prices above a certain threshold)
SELECT DISTINCT
    s.market_id,
    s.base_asset,
    s.quote_asset
FROM Symbol s
WHERE NOT EXISTS (
    -- Correlated subquery finds events with price below threshold
    SELECT 1
    FROM Event e
    WHERE e.market_id = s.market_id
    AND e.base_asset = s.base_asset
    AND e.quote_asset = s.quote_asset
    AND e.price < 10  
);
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

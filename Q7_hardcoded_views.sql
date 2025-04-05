-- View that has a hard-coded criteria
-- Create a view that shows trading activity for a specific asset (hard-coded to 'BTC')
CREATE OR REPLACE VIEW bitcoin_trading_activity AS
SELECT 
    market_id,
    base_asset,
    quote_asset,
    time_utc,
    price
FROM Event
WHERE base_asset = 'BTC'  -- Hard-coded value
   OR quote_asset = 'BTC'; -- Hard-coded value

SELECT * FROM bitcoin_trading_activity;

-- Modify the hard-coded value in the view definition to get a different result:
CREATE OR REPLACE VIEW bitcoin_trading_activity AS
SELECT 
    market_id,
    base_asset,
    quote_asset,
    time_utc,
    price
FROM Event
WHERE base_asset = 'ETH'  -- Changed hard-coded value
   OR quote_asset = 'ETH'; -- Changed hard-coded value

SELECT * FROM bitcoin_trading_activity;

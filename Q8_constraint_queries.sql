--- Overlap Constraint Query ---
-- This query demonstrates assets that overlap in their usage as both base and quote currencies
SELECT 
    s1.base_asset AS asset_id,
    'Used as both base and quote in different pairs' AS constraint_type,
    COUNT(DISTINCT s1.quote_asset) AS trading_paths
FROM Symbol s1
JOIN Symbol s2 ON s1.base_asset = s2.quote_asset
GROUP BY s1.base_asset
ORDER BY trading_paths DESC;

--- Covering Constraint Query ---
-- This query checks if all assets in the system are covered by at least one market
SELECT 
    a.asset_id,
    CASE 
        WHEN COUNT(ma.market_id) = 0 THEN 'Not covered by any market (CONSTRAINT VIOLATION)'
        ELSE 'Covered by ' || COUNT(ma.market_id) || ' market(s)'
    END AS coverage_status
FROM Asset a
LEFT JOIN Market_Asset ma ON a.asset_id = ma.asset_id
GROUP BY a.asset_id
ORDER BY COUNT(ma.market_id);
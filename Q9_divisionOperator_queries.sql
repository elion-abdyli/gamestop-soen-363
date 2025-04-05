--- Two implementations of the division operator ---
-- both quesries for "Find markets that list all available assets"
-- Ex 1 : regular nested query using NOT IN
SELECT 
    m.market_id,
    m.name
FROM Market m
WHERE NOT EXISTS (
    -- For each asset
    SELECT 1
    FROM Asset a
    WHERE NOT EXISTS (
        -- Check if it's associated with this market
        SELECT 1
        FROM Market_Asset ma
        WHERE ma.market_id = m.market_id
        AND ma.asset_id = a.asset_id
    )
);

-- Ex 2 : Implementation using EXCEPT
SELECT 
    m.market_id,
    m.name
FROM Market m
WHERE NOT EXISTS (
    -- Find assets not listed in this market using EXCEPT
    SELECT a.asset_id
    FROM Asset a
    EXCEPT
    SELECT ma.asset_id
    FROM Market_Asset ma
    WHERE ma.market_id = m.market_id
);

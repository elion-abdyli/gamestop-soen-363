-- No negative decimals
CREATE DOMAIN positive_decimal AS DECIMAL
    CHECK (VALUE > 0);


-- Create Asset table
CREATE TABLE Asset (
    asset_id VARCHAR(50) PRIMARY KEY
    
);

-- Create Market table
CREATE TABLE Market (
    market_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    
);

-- Create Symbol table (weak entity dependent on Market and Asset)
CREATE TABLE Symbol (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    PRIMARY KEY (market_id, base_asset, quote_asset),
    FOREIGN KEY (market_id) REFERENCES Market(market_id) ON DELETE CASCADE,
    FOREIGN KEY (base_asset) REFERENCES Asset(asset_id) ON DELETE CASCADE,
    FOREIGN KEY (quote_asset) REFERENCES Asset(asset_id) ON DELETE CASCADE
);

-- Create Event table (weak entity)
CREATE TABLE Event (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    time_utc TIMESTAMP,
    price DECIMAL(18,8),
    PRIMARY KEY (market_id, base_asset, quote_asset, time_utc),
    FOREIGN KEY (market_id, base_asset, quote_asset) REFERENCES Symbol(market_id, base_asset, quote_asset) ON DELETE CASCADE
);

CREATE TABLE "Order" (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    time_utc TIMESTAMP,
    qty positive_decimal,
    type VARCHAR(50),
    price positive_decimal,
    PRIMARY KEY (market_id, base_asset, quote_asset, time_utc),
    FOREIGN KEY (market_id, base_asset, quote_asset, time_utc) REFERENCES Event(market_id, base_asset, quote_asset, time_utc) ON DELETE CASCADE
);

-- Create Trade table (subtype of Event)
CREATE TABLE Trade (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    time_utc TIMESTAMP,
    qty positive_decimal,
    price positive_decimal,
    PRIMARY KEY (market_id, base_asset, quote_asset, time_utc),
    FOREIGN KEY (market_id, base_asset, quote_asset, time_utc) REFERENCES Event(market_id, base_asset, quote_asset, time_utc) ON DELETE CASCADE
);


-- Create Symbol_Event relationship table (many-to-many)
CREATE TABLE Symbol_Event (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    event_time TIMESTAMP,
    PRIMARY KEY (market_id, base_asset, quote_asset, event_time),
    FOREIGN KEY (market_id, base_asset, quote_asset) REFERENCES Symbol(market_id, base_asset, quote_asset) ON DELETE CASCADE,
    FOREIGN KEY (market_id, base_asset, quote_asset, event_time) REFERENCES Event(market_id, base_asset, quote_asset, time_utc) ON DELETE CASCADE
);
-- Create Market_Asset relationship table (many-to-many)
CREATE TABLE Market_Asset (
    market_id VARCHAR(50),
    asset_id VARCHAR(50),
    PRIMARY KEY (market_id, asset_id),
    FOREIGN KEY (market_id) REFERENCES Market(market_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id) ON DELETE CASCADE
);

CREATE TABLE Candlestick (
    market_id VARCHAR(50),
    base_asset VARCHAR(50),
    quote_asset VARCHAR(50),
    time_interval TIMESTAMP,  
    open positive_decimal,      
    close positive_decimal,     
    high positive_decimal,     
    low positive_decimal,      
    volume positive_decimal,    
    PRIMARY KEY (market_id, base_asset, quote_asset, time_interval),
    FOREIGN KEY (market_id, base_asset, quote_asset) REFERENCES Symbol(market_id, base_asset, quote_asset) ON DELETE CASCADE
);

-- Full access
Create VIEW priviledged_view_orders AS SELECT * FROM "Order";
Create VIEW priviledged_view_trades AS SELECT * FROM Trade;
-- Limited access (Let base user view more attributes if needed)
CREATE VIEW user_view_orders AS SELECT market_id, base_asset, quote_asset FROM "Order";
CREATE VIEW user_view_trades AS SELECT market_id, base_asset, quote_asset FROM Trade;
-- ///////////////////////////////////////////////// --

CREATE FUNCTION validate_symbol() 
RETURNS TRIGGER AS $$
BEGIN
 IF NOT EXISTS (
  SELECT 1 FROM Symbol 
  WHERE market_id = NEW.market_id 
  AND base_asset = NEW.base_asset 
  AND quote_asset = NEW.quote_asset)
    THEN
    RAISE EXCEPTION 'Invalid symbol';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_symbol_order
BEFORE INSERT OR UPDATE ON "Order"
FOR EACH ROW EXECUTE FUNCTION validate_symbol();
CREATE TRIGGER validate_symbol_trade
BEFORE INSERT OR UPDATE ON Trade
FOR EACH ROW EXECUTE FUNCTION validate_symbol();



-- Insert Asset data
INSERT INTO Asset (asset_id) VALUES 
('CONCORDIA'), 
('USDT'), 
('BTC'), 
('ETH');

-- Insert Market data
INSERT INTO Market (market_id, name) VALUES 
('CONCORDIA-CRYPTO', 'Concordia Cryptocurrency Exchange');

-- Insert Symbol data
INSERT INTO Symbol (market_id, base_asset, quote_asset) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT'),
('CONCORDIA-CRYPTO', 'BTC', 'USDT'),
('CONCORDIA-CRYPTO', 'ETH', 'USDT');

-- Insert Event data 
INSERT INTO Event (market_id, base_asset, quote_asset, time_utc, price) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:00:00', 10.5),
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:05:00', 10.7),
('CONCORDIA-CRYPTO', 'BTC', 'USDT', '2023-12-01 12:00:00', 42000.50),
('CONCORDIA-CRYPTO', 'ETH', 'USDT', '2023-12-01 12:00:00', 2300.75);


-- Insert Order data

INSERT INTO "Order" (market_id, base_asset, quote_asset, time_utc, qty, type, price) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:00:00', 100.0, 'BUY', 10.5),
('CONCORDIA-CRYPTO', 'BTC', 'USDT', '2023-12-01 12:00:00', 0.5, 'SELL', 42000.50);

-- Insert Trade data
INSERT INTO Trade (market_id, base_asset, quote_asset, time_utc, qty, price) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:05:00', 50.0, 10.7),
('CONCORDIA-CRYPTO', 'ETH', 'USDT', '2023-12-01 12:00:00', 1.5, 2300.75);


-- Insert Symbol_Event relationship
INSERT INTO Symbol_Event (market_id, base_asset, quote_asset, event_time) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:00:00'),
('CONCORDIA-CRYPTO', 'CONCORDIA', 'USDT', '2023-12-01 12:05:00'),
('CONCORDIA-CRYPTO', 'BTC', 'USDT', '2023-12-01 12:00:00'),
('CONCORDIA-CRYPTO', 'ETH', 'USDT', '2023-12-01 12:00:00');


-- Insert Market_Asset relationship
INSERT INTO Market_Asset (market_id, asset_id) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA'),
('CONCORDIA-CRYPTO', 'BTC'),
('CONCORDIA-CRYPTO', 'ETH'),
('CONCORDIA-CRYPTO', 'USDT');


SELECT * FROM Asset;
SELECT * FROM Market;
SELECT * FROM Symbol;
SELECT * FROM Event;
SELECT * FROM "Order";
SELECT * FROM Trade;
SELECT * FROM Symbol_Event;



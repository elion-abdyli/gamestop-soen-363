-- Create Asset table
CREATE TABLE Asset (
    asset_id VARCHAR(50) PRIMARY KEY
    -- Other asset attributes can be added here
);

-- Create Market table
CREATE TABLE Market (
    market_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    -- Other market attributes can be added here
);

-- Create Symbol table (weak entity dependent on Market and Asset)
CREATE TABLE Symbol (
    market_id VARCHAR(50),
    baseasset_quoteasset VARCHAR(50),
    PRIMARY KEY (market_id, baseasset_quoteasset),
    FOREIGN KEY (market_id) REFERENCES Market(market_id) ON DELETE CASCADE,
    FOREIGN KEY (baseasset_quoteasset) REFERENCES Asset(asset_id) ON DELETE CASCADE
);

-- Create Event table (weak entity)
CREATE TABLE Event (
    symbol_id VARCHAR(50),
    time_utc TIMESTAMP,
    price DECIMAL(18,8),
    market_id VARCHAR(50),
    PRIMARY KEY (symbol_id, time_utc),
    FOREIGN KEY (market_id, symbol_id) REFERENCES Symbol(market_id, baseasset_quoteasset) ON DELETE CASCADE,
    FOREIGN KEY (market_id) REFERENCES Market(market_id) ON DELETE CASCADE
);

-- Create Order table (subtype of Event)
CREATE TABLE "Order" (
    symbol_id VARCHAR(50),
    time_utc TIMESTAMP,
    qty DECIMAL(18,8),
    type VARCHAR(50),
    price DECIMAL(18,8),
    PRIMARY KEY (symbol_id, time_utc),
    FOREIGN KEY (symbol_id, time_utc) REFERENCES Event(symbol_id, time_utc) ON DELETE CASCADE
);

-- Create Trade table (subtype of Event)
CREATE TABLE Trade (
    symbol_id VARCHAR(50),
    time_utc TIMESTAMP,
    qty DECIMAL(18,8),
    price DECIMAL(18,8),
    PRIMARY KEY (symbol_id, time_utc),
    FOREIGN KEY (symbol_id, time_utc) REFERENCES Event(symbol_id, time_utc) ON DELETE CASCADE
);

-- Create Symbol_Event relationship table (many-to-many)
CREATE TABLE Symbol_Event (
    market_id VARCHAR(50),
    symbol_id VARCHAR(50),
    event_id VARCHAR(50),
    event_time TIMESTAMP,
    PRIMARY KEY (market_id, symbol_id, event_id, event_time),
    FOREIGN KEY (market_id, symbol_id) REFERENCES Symbol(market_id, baseasset_quoteasset) ON DELETE CASCADE,
    FOREIGN KEY (event_id, event_time) REFERENCES Event(symbol_id, time_utc) ON DELETE CASCADE
);

-- Create Market_Asset relationship table (many-to-many)
CREATE TABLE Market_Asset (
    market_id VARCHAR(50),
    asset_id VARCHAR(50),
    PRIMARY KEY (market_id, asset_id),
    FOREIGN KEY (market_id) REFERENCES Market(market_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id) ON DELETE CASCADE
);

-- ///////////////////////////////////////////////// --


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
INSERT INTO Symbol (market_id, baseasset_quoteasset) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA'),
('CONCORDIA-CRYPTO', 'BTC'),
('CONCORDIA-CRYPTO', 'ETH');

-- Insert Event data 
INSERT INTO Event (market_id, symbol_id, time_utc, price) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', '2023-12-01 12:00:00', 10.5),
('CONCORDIA-CRYPTO', 'CONCORDIA', '2023-12-01 12:05:00', 10.7),
('CONCORDIA-CRYPTO', 'BTC', '2023-12-01 12:00:00', 42000.50),
('CONCORDIA-CRYPTO', 'ETH', '2023-12-01 12:00:00', 2300.75);

-- Insert Order data
INSERT INTO "Order" (symbol_id, time_utc, qty, type, price) VALUES 
('CONCORDIA', '2023-12-01 12:00:00', 100.0, 'BUY', 10.5),
('BTC', '2023-12-01 12:00:00', 0.5, 'SELL', 42000.50);

-- Insert Trade data
INSERT INTO Trade (symbol_id, time_utc, qty, price) VALUES 
('CONCORDIA', '2023-12-01 12:05:00', 50.0, 10.7),
('ETH', '2023-12-01 12:00:00', 1.5, 2300.75);

-- Insert Symbol_Event relationship
INSERT INTO Symbol_Event (market_id, symbol_id, event_id, event_time) VALUES 
('CONCORDIA-CRYPTO', 'CONCORDIA', 'CONCORDIA', '2023-12-01 12:00:00'),
('CONCORDIA-CRYPTO', 'CONCORDIA', 'CONCORDIA', '2023-12-01 12:05:00'),
('CONCORDIA-CRYPTO', 'BTC', 'BTC', '2023-12-01 12:00:00'),
('CONCORDIA-CRYPTO', 'ETH', 'ETH', '2023-12-01 12:00:00');

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
SELECT * FROM Market_Asset;


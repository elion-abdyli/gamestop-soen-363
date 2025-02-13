# Making our candlestick charts from scratch


40132982 Elion Abdyli                 
 
Hanad-Keysse Mohamed H.      
 
40190387 Aman Singh                   

40200175 Boudour Bannouri             

# Abstract
We're gonna collect real-time data streams of cryptocurrency markets with python to populate a Postgres database and a MongoDB database. Preliminary tests resulted in a 2.4 GB json file, from 8 hours of runtime. We will aggregate the data to reproduce the level 1 price and volume data represented by candlestick charts of that respective time period. 

# Background

### Candlesticks & market data
Candlestick charts are Level 1 Market data, the result of the aggregation of lower level trade data. 
Deeper still lies Level 2 trade data known as the order book, this data is not reflected in the previous two datasets.

### Cryptocurrency markets
Cyptocurency markets are open 24/7. Cryptocurrency trading platforms like Binance offer REST APIs for Level 1 market data and Websocket APIs for trades and order book data streams; often free of charge.

### Historical data via REST API
Collecting real-time data or large volumes of data via Rest API requires polling and involves the constraints of rate limiting.

### Data streams via Websockets
Market data streams such as Trades and Orderbook updates are provided via Websockets. This provides a constant flow of unique, real-time data that we can collect for prolonged periods of time with no significant constraints, such the rate limits of polling.

# Proof of concept: minute of collection
Via the  the Binance Websocket Stream, we collected Trade and Orderbook updates of 10 symbols for the duration of 1 minute.
The resulting json file was about 15MB in size. Since this method of data collection is reliable and scalable, we scaled to 8 hours:

| **Platform** | **Description**                  | **Number of Symbols** | **Runtime** | **Experimental Result** |
|--------------|----------------------------------|-----------------------|-------------|-------------------------|
| Binance      | Trade + depth stream             | 10                    | 1 min       | 15 MB                   |
| Binance      | Trade stream only                | 10                    | 8 hours     | 2400 MB                 |

According to these estimates, our current tests allow us to meet the project size requirements within hours. Over a few weeks the acumulated data would grow larger and would quickly exceed system ressources.

### What to do with the data ?
Having some kind of objective may help clarify our scope. Long term collection would require ressource scaling or dropping older data, resulting in a rolling window of the latest data. Another solution is aggregating older data to manage size, which leads us to generating Level 1 market data from Level 2 market data, bringing us full circle. This opens the possibility of comparing our results with the official Level 1 data, using it as a control to measure our accuracy.

# Objectives
1. Reproduce level 1 data often represented by candlestick charts.
2. Reproduce the order book from the update stream.
3. Find patterns between orderbook and trades.
4. Compare trade and order data with a second platform for price inefficiency

# Hypothesis
1. We will approximate the trade price and volume with some minor discrepancies.
2. We will approximate the order book snapshot with missing orders beyond our time scope.
3. We will find some patterns between orderbook and trades. They will have no predictive value.
4. There will be no price ineffiencies sufficient for arbitrage.

# Methods
## Selection Criteria
Some criteria are defined for the selection of the data sources.

| Selection Criteria | Description | Target |
|--------------------|-------------|--------|
| **Dataset Size** | The amount of data available in the dataset. | At least 1 GB. |
| **Documentation** | The quality and availability of API or dataset documentation. | Clear, comprehensive, and up-to-date documentation. |
| **Structure** | The organization and format of the data and entities. | Tabular, relationnal, well-defined, consistent. |
| **Data Types** | Types of data in the dataset that require collection. | Clearly defined and fixed/limited size.|
| **Activity** | The frequency of updates of the dataset or API. | By the minute for streams, by the day for static databases. |
| **Maintenance** | Maintenance frequency of the API | By the month. |
| **Call Rate Limit** | The number of API calls allowed within a given time frame. | 1,000 to 100,000 calls per minute. |
| **Payload Size** | The amount of data that can be retrieved in a single request. | 1 KB to 100 KB. |
| **Throughput** | The speed and efficiency of data retrieval and processing. | 100 MB per minute. |
| **Tools** | Availability of SDKs, libraries, or integrations for easier usage. | Official Python libraries or SDKs. |
| **Cost** | Pricing structure, including free tiers and paid options. | No API key (best), or free API key (good). |



## Software stack
 - PostgreSQL
   - appropriate for data modeling and analysis
 - MongoDB
   - appropriate for json payloads
 - Python
   - appropriate for data
 - Libraries
  - pandas
  - sqlite
  - requests
  - websocket
  - json
 - Colab
   - appropriate for python
 - Postman
   - appropriate for api testing
 - Supabase
  - approriate for postgres



## Database Description
Market data over a continuous time period.

### Scope
- continuous time period of 1-10 hours
- symbols that have trade and depth streams
- symbols that trade versus USD
- no derived values except for the ones we choose for control:
  - order book snapshot
  - price history
  - volume history
  - 1 min, 15 ming, 30min, 1h intervals

### High-level Entities
- symbol (ex: BTC/USDT)
- open, close, low, high, volume, time
- buy, sell, quantity, price, time
- quantity, price, time

### Datasources
- Binance
- Coinbase
- (alternative)
 


## Hardware
Assumed hardware specs for reference. Impacts collection approach and selection criteria.

| **Parameter** | **Value**                | **Considerations**                                                       |
|---------------|--------------------------|--------------------------------------------------------------------------|
| **CPU**       | 8 core                   | Unlikely execution bottlenecks                                           |
| **Memory**    | 16-32 GB                 | A small enough dataset could be manipulated in memory with no swapping   | 
| **Storage**   | 1000 GB                  | A small enough dataset could fit entirely on local disk                  |
| **Bandwidth** | 3750 MB/min ~ 225 GB/h   | Describes the upper limit of throughput                                  |
| **Network**   | Ethernet                 | Stable connection is relevant for websocket                              |
| **Uptime**    | 10-20 hours              | Target uptime required to collect data                                   |

Within our intended data collection scoope our hardware we do not expect hardware bottlenecks to work around.

## Data collection

### Rate limiting
- [Binance Web Socket](https://developers.binance.com/docs/binance-spot-api-docs/web-socket-streams#websocket-limits)
- [Binance REST API](https://developers.binance.com/docs/binance-spot-api-docs/rest-api/limits#ip-limits)
- [Binance REST API](https://api.binance.com/api/v3/exchangeInfo)

The throughput of the api impacts the collection methods.

```
Throughput = payload frequency * payload size
```
| **Throughput**                | **Runtime** | **MB/min**   | **Total Data** |
|--------------------------------|------------|-------------|---------------|
| Minimum Required               | 24h        | 1 MB/min    | 1.44 GB       |
| Ideal                          | 24h        | 100 MB/min  | 144 GB        |
| Maximum (Ethernet Bandwidth)    | 24h        | 3750 MB/min | 5400 GB       |


# Results

| **Platform** | **Description**                  | **Number of Symbols** | **Runtime** | **Experimental Result** |
|--------------|----------------------------------|-----------------------|-------------|-------------------------|
| Binance      | Trade + depth stream             | 10                    | 1 min       | 15 MB                   |
| Binance      | Trade stream only                | 10                    | 8 hours     | 2400 MB                 |



| **Description**                  | **MB/min** | **GB/h** | **GB/8h** | **GB/24h** | **GB/week** | **GB/year** |
|----------------------------------|------------|----------|-----------|------------|-------------|-------------|
| Trade + depth stream             | 15 MB/min  | 0.90 GB/h | 7.2 GB    | 21.6 GB    | 151.2 GB    | 7856.8 GB   |
| Trade stream only                | 5 MB/min   | 0.3 GB/h  | 2.4 GB    | 7.2 GB     | 50.4 GB     | 2611.2 GB   |



![image](https://github.com/user-attachments/assets/729ca639-bae7-4f6a-9e9e-25318b2acc2f)

# Discussion

# Conclusion

# References








# Appendix

### Criteria
Some criteria are defined for the selection of the data sources.

| Selection Criteria | Description | Target |
|--------------------|-------------|--------|
| **Dataset Size** | The amount of data available in the dataset. | At least 1 GB. |
| **Documentation** | The quality and availability of API or dataset documentation. | Clear, comprehensive, and up-to-date documentation. |
| **Structure** | The organization and format of the data and entities. | Tabular, relationnal, well-defined, consistent. |
| **Data Types** | Types of data in the dataset that require collection. | Clearly defined and fixed/limited size.|
| **Activity** | The frequency of updates of the dataset or API. | By the minute for streams, by the day for static databases. |
| **Maintenance** | Maintenance frequency of the API | By the month. |
| **Call Rate Limit** | The number of API calls allowed within a given time frame. | 1,000 to 100,000 calls per minute. |
| **Payload Size** | The amount of data that can be retrieved in a single request. | 1 KB to 100 KB. |
| **Throughput** | The speed and efficiency of data retrieval and processing. | 100 MB per minute. |
| **Tools** | Availability of SDKs, libraries, or integrations for easier usage. | Official Python libraries or SDKs. |
| **Cost** | Pricing structure, including free tiers and paid options. | No API key (best), or free API key (good). |


## Proof of concept
### Trade stream

``` python
import websocket
import json
import time
import threading

# List of symbols to subscribe to
symbols = [
    "btcusdt@trade", "ethusdt@trade", "bnbusdt@trade", 
    "adausdt@trade", "xrpusdt@trade", "dogeusdt@trade", 
    "solusdt@trade", "dotusdt@trade", "linkusdt@trade", 
    "ltcusdt@trade"
]

# File to save the data
output_file = "10-trade_data.json"

# List to store all trade data
trade_data = []

# Function to handle incoming messages
def on_message(ws, message):
    global trade_data
    data = json.loads(message)
    trade_data.append(data)
    print(f"Received data: {data}")

# Function to handle errors
def on_error(ws, error):
    print(f"Error: {error}")

# Function to handle connection close
def on_close(ws, close_status_code, close_msg):
    print("### Connection closed ###")

# Function to handle opening the connection
def on_open(ws):
    print("### Connection opened ###")
    # Subscribe to the trade streams
    subscribe_message = {
        "method": "SUBSCRIBE",
        "params": symbols,
        "id": 1
    }
    ws.send(json.dumps(subscribe_message))

# Function to stop the WebSocket connection after a minute
def stop_after_minute(ws):
    time.sleep(60)  # Wait for 60 seconds
    ws.close()
    print("### Stopping after 1 minute ###")
    # Save the collected data to a file
    with open(output_file, 'w') as f:
        json.dump(trade_data, f, indent=4)
    print(f"Data saved to {output_file}")

# WebSocket URL
websocket_url = "wss://stream.binance.com:9443/stream?streams=" + "/".join(symbols)

# Create a WebSocket connection
ws = websocket.WebSocketApp(websocket_url,
                            on_message=on_message,
                            on_error=on_error,
                            on_close=on_close)

ws.on_open = on_open

# Start a thread to stop the WebSocket after a minute
threading.Thread(target=stop_after_minute, args=(ws,)).start()

# Run the WebSocket connection
ws.run_forever()



```
### Depth stream
``` python
import websocket
import json
import time
import threading

# List of symbols to subscribe to for depth streams
symbols = [
    "btcusdt", "ethusdt", "bnbusdt", 
    "adausdt", "xrpusdt", "dogeusdt", 
    "solusdt", "dotusdt", "linkusdt", 
    "ltcusdt"
]

# Add depth streams for the symbols (using @depth@100ms for 100ms updates)
depth_streams = [f"{symbol}@depth@100ms" for symbol in symbols]

# File to save the data
output_file = "10-depth_data.json"

# List to store all depth data
depth_data = []

# Function to handle incoming messages
def on_message(ws, message):
    global depth_data
    data = json.loads(message)
    depth_data.append(data)
    print(f"Received data: {data}")

# Function to handle errors
def on_error(ws, error):
    print(f"Error: {error}")

# Function to handle connection close
def on_close(ws, close_status_code, close_msg):
    print("### Connection closed ###")

# Function to handle opening the connection
def on_open(ws):
    print("### Connection opened ###")
    # Subscribe to the depth streams
    subscribe_message = {
        "method": "SUBSCRIBE",
        "params": depth_streams,
        "id": 1
    }
    ws.send(json.dumps(subscribe_message))

# Function to stop the WebSocket connection after a minute
def stop_after_minute(ws):
    time.sleep(60)  # Wait for 60 seconds
    ws.close()
    print("### Stopping after 1 minute ###")
    # Save the collected data to a file
    with open(output_file, 'w') as f:
        json.dump(depth_data, f, indent=4)
    print(f"Data saved to {output_file}")

# WebSocket URL
websocket_url = "wss://stream.binance.com:9443/stream?streams=" + "/".join(depth_streams)

# Create a WebSocket connection
ws = websocket.WebSocketApp(websocket_url,
                            on_message=on_message,
                            on_error=on_error,
                            on_close=on_close)

ws.on_open = on_open

# Start a thread to stop the WebSocket after a minute
threading.Thread(target=stop_after_minute, args=(ws,)).start()

# Run the WebSocket connection
ws.run_forever()
```


```python
import requests

def get_trading_symbols():
    url = "https://api.binance.com/api/v3/exchangeInfo"
    response = requests.get(url)
    data = response.json()
    
    trading_symbols = [symbol["symbol"] for symbol in data["symbols"] if symbol["status"] == "TRADING"]
    
    print(f"Number of trading symbols: {len(trading_symbols)}")
    return trading_symbols

if __name__ == "__main__":
    get_trading_symbols()

```

### team members


| #  | Name                        | ID        |
|----|-----------------------------|----------|
| 1  | Elion Abdyli               | 40132982 |
| 2  | Hanad-Keysse Mohamed H.    | 40299566 |
| 3  | Aman Singh                 | 40190387 |
| 4  | Boudour Bannouri           | 40200175 |



## deadline
[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/1KqOh3Q8)



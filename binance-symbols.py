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

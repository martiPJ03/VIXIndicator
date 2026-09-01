import yfinance as yf

vix = yf.Ticker("^VIX")
data = vix.history(period="1d")
print(data['Close'].iloc[-1])
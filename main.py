from fastapi import FastAPI
import yfinance as yf

app = FastAPI()

@app.get("/vix")
def get_vix():
    vix = yf.Ticker("^VIX")
    data = vix.history(period="1d")
    latest = data["Close"].iloc[-1]
    previous = data["Open"].iloc[-1]
    return {
        "value": round(float(latest), 2),
        "previous": round(float(previous), 2)
    }
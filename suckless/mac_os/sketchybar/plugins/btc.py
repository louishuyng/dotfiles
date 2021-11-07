#!/usr/bin/env python3

import requests
import os

response = requests.get('https://api.gemini.com/v1/pricefeed')
jsonResponse = response.json()

for i in jsonResponse:
    if i["pair"] == "BTCUSD":
        percentChange = str(round((float(i["percentChange24h"]) * 100), 2))
        os.system('sketchybar -m set btc label '+ percentChange + '%')
        break

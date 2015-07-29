# BitcoinTrading

Bitcoin trading strategy wiht meXBT Exchange

- *License:* GNU General Public License
- *Guadalajara, México*

**Bitcoin** is more than just an efficient tool of making peer to peer payments, securly and instantly. Like other currencies, trading can be performed for hedging, arbitrage or speculative purposes. This code is shared for showing how to construct a very basic and yet profitable trading strategy, using the **meXBT** Bitcoin Exchange particularly the "BtcMxn" market.

### Used R Packages

In order to list and load or if not install all the required r packages, the following code is used.

```r
Pkg <- c("base","digest","downloader","fBasics","foreach","forecast","grid",
"gridExtra","ggplot2","httr","jsonlite","lubridate","moments",
"orderbook","PerformanceAnalytics","plyr","quantmod",
"Quandl","reshape2","RCurl","stats","scales","tseries","TTR","TSA",
"xts","zoo")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)
```

### Support connections

This trading strategy uses several functions so with the finality to diversify some functions there are used other repositories:

- meXBT Data API for R: [meXBT-data-r](https://raw.githubusercontent.com/IFFranciscoME/mexbt-data-r/clean-master/meXBTRClient.R)
- IF.Francisco.ME Data Processor Bundle: [DataProcessor](https://raw.githubusercontent.com/IFFranciscoME/DataProcessor/master/DataProcessor.R)

- IF.Francisco.ME Data Visualization Bundle: [DataVisualization](https://raw.githubusercontent.com/IFFranciscoME/DataVisualization/master/DataVisualization.R)

- IF.Francisco.ME Data Visualization Bundle: [APIConnector](https://raw.githubusercontent.com/IFFranciscoME/APIConnector/master/APIConnector.R)

### Collect data
To collect data is as simple as one line per request, with the respect parameters to include.

```r
BtcPair  <- OHLC(Instrmt,since,interval)
IPC <- OYStockD1("^IPC","yahoo",Sys.Date()-1000,Sys.Date())
```

### Now we define the following

- Existence: Relative Strength Index (RSI) technical indicator.
- Phenomena: OverBought and OverSold levels/areas.
- Parameter: Amount of historical prices, Back periods for calculation, Upper and Lower limits.
- Variable Type: Endogenous.
- Opportunity: Sell at OverBought / Buy at OverSold.

### The following code

After this all the rest code is globally to calculate and plot the trading signal, then generates the table of strategy parameter and the table of performance summary, next the risk and performance measures are calculated to finally  create the graphical summary and plot it.

Here is the output you should see:
![ArimaForecast](/BitcoinTrading(Example).png?raw=true)

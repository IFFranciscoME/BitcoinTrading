# BitcoinTrading

Bitcoin trading strategy wiht meXBT Exchange

- *License:* GNU General Public License
- *Guadalajara, México*

**Bitcoin** is more than just an efficient tool of making peer to peer payments, securly and instantly. Like other currencies, trading can be performed for hedging, arbitrage or speculative purposes. This code is shared for showing how to construct a very basic and yet profitable trading strategy, using the **meXBT** Bitcoin Exchange particularly the "BtcMxn" market.

### For a general clean start

```r
closeAllConnections() # Close All Connections
rm(list=ls())         # Remove all objects
cat("\014")           # Clear Console
```

### A simple way of load required packages and suppress messages at console

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

### Pre-configuration of the R environment

```r
options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

knit_hooks$set(inline = function(x) {
  prettyNum(round(x,2), big.mark=",")
})
```

### Support connections

In order to diversify code some functions are being called from other repositories, these are the following:

- meXBT Data API for R: [meXBT-data-r](https://raw.githubusercontent.com/IFFranciscoME/mexbt-data-r/clean-master/meXBTRClient.R)
- IF.Francisco.ME Data Processor Bundle: [DataProcessor](https://raw.githubusercontent.com/IFFranciscoME/DataProcessor/master/DataProcessor.R)

- IF.Francisco.ME Data Visualization Bundle: [DataVisualization](https://raw.githubusercontent.com/IFFranciscoME/DataVisualization/master/DataVisualization.R)

- IF.Francisco.ME Data Visualization Bundle: [APIConnector](https://raw.githubusercontent.com/IFFranciscoME/APIConnector/master/APIConnector.R)

### Collect data
To collect data is as simple as one line per request, with the respect parameters to include.

```r
BtcPair  <- OHLC(Instrmt,since,interval)
IPC <- OYStockD1("^IPC","yahoo",Sys.Date()-1000,Sys.Date())                    # BenchMark BtcMxn
```

### Exploratory plot and statistics

An exploratory time series plot and also a statistical transformation to explore the data

```r
PlotM1 <- FSerieM1(DFClose,"steel blue","dark gray",2,"BtcMxn Prices","2 months","red","blue")
...
FACP   <- AutoCorrelation(BtcPair[,4], "partial", "Partial Auto Correlation")
MaxLag <- max(which(FACP$data$Sig_nc == max(FACP$data$Sig_nc)))
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

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

### Brief calculation

```r
HistInfo   <- MaxLag                                 # Historical Lag for calculations
rsi <- RSI(meXBTMxn[,4],HistInfo)                    # RSI Technical Indicator
BuySignal  <- 30                                     # Buy  (Long) Signal
SellSignal <- 70                                     # Sell (Short) Signal

sigup <- ifelse(rsi < BuySignal, 1, 0)
sigdn <- ifelse(rsi > SellSignal, -1, 0)
```

### Trading signal plot

Just for exploring the signal generated to do the trading, the following can be made

```r
PlotM1  <- FSerieM1(DFRSI,"dark red","dark gray",2,"RSI Values","2 months","red","blue")
```
![RSI(Example)](/RSI(Example).png?raw=true)

### Table of strategy parameter

```r
TradeChar <- data.frame(matrix(ncol = 2, nrow = 9))
TradeChar[,1] <- c("Coins per trade","MultiTrade","Price Interval","Max Open Trades",
"Multi Market","Cross Trades","Latency Impact","Max Volume per period","Min Volume per period")
TradeChar[,2] <- c(TradeAmount,MultiTrade,PriceInterv,MaxOpenT,MultiMarket,CrossTrades,LatencyImp,
paste(MaxPeriodV,"Coin(s)",sep=" "),paste(MinPeriodV,"Coin(s)",sep=" "))
TradeChar[,3] <- c("Price Periods","Upper Value","Lower Value","Historic Prices","","","","","")
TradeChar[,4] <- c(HistInfo,SellSignal,BuySignal,length(BtcPair[,1]),"","","","","")
colnames(TradeChar) <- c("Strategy Parameter","Value","Model Parameters","Value")
```

### Table of Performance Summary

```r
PerformanceSummary <- data.frame(matrix(nrow = 8, ncol = 4))
PerformanceSummary[1:5,1] <- c("Max Profit","Max Loss","Sample Length","Short positions",
"Long positions")

PerformanceSummary[1,2] <- paste("$",TradeStrat$PeriodPL[which(TradeStrat$PeriodPL  == 
max(TradeStrat$PeriodPL))],sep=" ")

PerformanceSummary[2,2] <- paste("-$",TradeStrat$PeriodPL[which(TradeStrat$PeriodPL == 
min(TradeStrat$PeriodPL))],sep=" ")

PerformanceSummary[3,2] <- paste(length(TradeStrat$Signal),interval,sep=" ")
PerformanceSummary[4,2] <- length(count(which(TradeStrat$Signal == -1))[,1])
PerformanceSummary[5,2] <- length(count(which(TradeStrat$Signal == +1))[,1])

PerformanceSummary[6:8,1] <- c("Profit Made","Min Balance", "Max Balance")
PerformanceSummary[6,2]  <- paste("$ ",round(TradeStrat$Balance[length(TradeStrat$Balance)] - 
InitialBalance,2),sep="")
PerformanceSummary[7,2]  <- paste("$ ",round(min(TradeStrat$Balance),2),sep="")
PerformanceSummary[8,2]  <- paste("$ ",round(max(TradeStrat$Balance),2),sep="")
```

### Risk and Performance measures

There is a plenty of risk and performance measures one can calculate for evaluate the account balance value through time.


```r
DSR <- round(DownsideDeviation(BalanceRet, MAR = 0),2) # DownSide Deviation.
ADD <- round(AverageDrawdown(BalanceRet),2) # average depth of the observed drawdowns.
ALH <- round(AverageLength(BalanceRet),2)   # average length of the drawdowns observed.
ARY <- round(AverageRecovery(BalanceRet),2) # average recovery period of the drawdowns.

BL <- round(BernardoLedoitRatio(BalanceRet),2)
KR <- round(KellyRatio(BalanceRet, Rf=0.035/255),2)
SR <- round(SortinoRatio(BalanceRet, MAR=0.035/255),2)

PerformanceSummary[,3] <- c("Downside Deviation","Average Drawdown","Average Length",
"Average Recovery","BernardoLedoit Ratio","Kelly Ratio","Sortino Ratio","")
PerformanceSummary[,4] <- c(DSR,ADD,ALH,ARY,BL,KR,SR,"")
colnames(PerformanceSummary) <- c("Trading Parameters","Value", "Risk&Performance","Value")
```

### Graphical summary generation

To generate the ending image which contents the plots and summaries you can use the following

```r
TradePerformancegg <- qplot(1:15, 1:15, geom = "blank") +
theme(panel.background = element_rect(fill="white"),line = element_blank(),text=element_blank()) +
annotation_custom(grob = tableGrob(PerformanceSummary,
gpar.corefill = gpar(fill = "white", col="dark grey"), show.hlines = TRUE,
show.rownames = FALSE, gp = gpar(fontsize=9)))

TradeChargg <- qplot(1:15, 1:15, geom = "blank") +
theme(panel.background = element_rect(fill="white"),line = element_blank(),text = element_blank()) +
annotation_custom(grob = tableGrob(TradeChar,
gpar.corefill = gpar(fill = "white", col="dark grey"), show.hlines = TRUE,
show.rownames = FALSE, gp = gpar(fontsize=9)))

grid.newpage()
pushViewport(viewport(layout = grid.layout(3,4)))
define_region <- function(row, col)
{viewport(layout.pos.row = row, layout.pos.col = col)}

print(gg_ser,vp  = define_region(1,1:3))
print(FACP,vp  = define_region(1,4))
print(TradeChargg,vp = define_region(2,4))
print(gg_ser1,vp = define_region(2,1:3))
print(TradePerformancegg,vp = define_region(3,4))
print(gg_ser2,vp = define_region(3,1:3))
```

### Finally here is the output you should see:
![ArimaForecast](/BitcoinTrading(Example).png?raw=true)


# -- -------------------------------------------------------------------------------------------- #
# -- Bitcoin Trading Strategy ------------------------------------------------------------------- #
# -- License: Public ---------------------------------------------------------------------------- #
# -- -------------------------------------------------------------------------------------------- #

closeAllConnections() # Close All Connections
rm(list=ls())         # Remove all objects
cat("\014")           # Clear Console

# -- ---------------------------------------------------------------------------------------- --- #
# -- Load required packages and suppress messages at console ------------------------------------ #
# -- ---------------------------------------------------------------------------------------- --- #

Pkg <- c("base","digest","downloader","fBasics","foreach","forecast","grid",
         "gridExtra","ggplot2","httr","jsonlite","lubridate","moments",
         "orderbook","PerformanceAnalytics","plyr","quantmod",
         "Quandl","reshape2","RCurl","stats","scales","tseries","TTR","TSA",
         "xts","zoo")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- ---------------------------------------------------------------------------------------- --- #
# -- Pre-configuration of the R environment ------------------------------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

knit_hooks$set(inline = function(x) {
  prettyNum(round(x,2), big.mark=",")
})

# -- ---------------------------------------------------------------------------------------- --- #
# -- Load meXBT-data-r API and Data Procesor codes from GitHub ---------------------------------- #
# -- ---------------------------------------------------------------------------------------- --- #

meXBTAPI <- "https://raw.githubusercontent.com/IFFranciscoME/mexbt-data-r/clean-master/meXBTRClient.R"
downloader::source_url(meXBTAPI,prompt=FALSE,quiet=TRUE)
PRC <- "https://raw.githubusercontent.com/IFFranciscoME/DataProcessor/master/DataProcessor.R"
downloader::source_url(PRC,prompt=FALSE,quiet=TRUE)
DV  <- "https://raw.githubusercontent.com/IFFranciscoME/DataVisualization/master/DataVisualization.R"
downloader::source_url(DV,prompt=FALSE,quiet=TRUE)
ACN <- "https://raw.githubusercontent.com/IFFranciscoME/APIConnector/master/APIConnector.R"
downloader::source_url(ACN,prompt=FALSE,quiet=TRUE)

# -- ---------------------------------------------------------------------------------------- --- #
# -- Download Bitcoin prices from meXBT ----------------------------------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

Instrmt  <- "btcmxn"
interval <- "hours"
since    <- 100
BtcPair  <- OHLC(Instrmt,since,interval)

BtcPair <- BtcPair[-which(BtcPair$High.Price == 100000),]
BtcPair <- BtcPair[-which(BtcPair$High.Price == 9999999.00),]

Count    <- length(BtcPair[,1])
limvald  <- length(BtcPair[,1])
limentd  <- round((length(BtcPair[,1]))*.99,0)
TrainPrices <- data.frame(BtcPair[1:limentd,])                                 # Training Prices
ValPrices   <- data.frame(BtcPair[(limentd+1):limvald,])                       # Validation Prices
meXBTMxn <- xts(TrainPrices[,c(2,3,4,5,9)], order.by = TrainPrices[,1])
colnames(meXBTMxn) <- c("Open","High","Low","Close","Volume")

DFClose <- data.frame(fortify.zoo(BtcPair)$TimeStamp,
fortify.zoo(BtcPair)$Close.Price,fortify.zoo(BtcPair)$Close.Volume)
colnames(DFClose) <- c("TimeStamp","Close","Volume")

IPC <- OYStockD1("^IPC","yahoo",Sys.Date()-1000,Sys.Date())                    # BenchMark BtcMxn
IPC$TimeStamp <- as.POSIXct(IPC$TimeStamp, order.by = "1970-01-01")
IPCRet <- Return.calculate(xts(IPC$Adj.Close, order.by = IPC$TimeStamp))
IPCRet <- IPCRet[-1,]

# -- ---------------------------------------------------------------------------------------- --- #
# -- Exploratory Plot for BtcMxn Prices ----------------------------------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

PlotM1  <- FSerieM1(DFClose,"steel blue","dark gray",2,"BtcMxn Prices","1 months","red","blue")

# -- ---------------------------------------------------------------------------------------- --- #
# -- Partial Auto Correlation Function as trading Parameter --------------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

FACP   <- AutoCorrelation(BtcPair[,4], "partial", "Partial Auto Correlation")
MaxLag <- max(which(FACP$data$Sig_nc == max(FACP$data$Sig_nc)))

# -- ---------------------------------------------------------------------------------------- --- #
# -- Calculate Relative Strenght Index parameter for trading signal ------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

# Existence: Relative Strength Index (RSI) technical indicator.
# Phenomena: OverBought and OverSold levels/areas.
# Parameter: Amount of historical prices, Back periods for calculation, Upper and Lower limits.
# Variable Type: Endogenous.
# Opportunity: Sell at OverBought / Buy at OverSold.

# The RSI calculation is RSI = 100 - 100 / ( 1 + RS ), 
# RS is the smoothed ratio of 'average' periods closed up over 'average' periods closed down.
# The 'averages' are divided by the value of n days.

HistInfo   <- MaxLag                                 # Historical Lag for calculations
rsi <- RSI(meXBTMxn[,4],HistInfo)                    # RSI Technical Indicator
BuySignal  <- 30                                     # Buy  (Long) Signal
SellSignal <- 70                                     # Sell (Short) Signal

sigup <- ifelse(rsi < BuySignal, 1, 0)
sigdn <- ifelse(rsi > SellSignal, -1, 0)

sigup[is.na(sigup)] <- 0                             # Replace missing signals with no position
sigdn[is.na(sigdn)] <- 0                             # Replace missing signals with no position
sig <- sigup + sigdn       

DFRSI <- fortify.zoo(rsi)
DFRSI <- DFRSI[-(1:MaxLag),]
colnames(DFRSI) <- c("TimeStamp","RSI")

# -- ---------------------------------------------------------------------------------------- --- #
# -- Exploratory Plot for RSI Index Values -------------------------------------------------- --- #
# -- ---------------------------------------------------------------------------------------- --- #

PlotM1  <- FSerieM1(DFRSI,"dark red","dark gray",2,"RSI Values","1 months","red","blue")

# ----------------------------------------------------------------------------------------------- #
# -- 4 -- Parameters for Trading Simulation and Back testing ------------------------------------ #
# ----------------------------------------------------------------------------------------------- #

TradeAmount <- 1                                     # Amount of Bitcoins to use in every trade
MultiTrade  <- FALSE                                 # More than 1 trade per period: TRUE/FALSE
PriceInterv <- "H1"                                  # Time interval of the prices
MaxOpenT    <- 1                                     # Max number of open trades 1
MultiMarket <- FALSE                                 # Open trades in other markets: TRUE/FALSE
CrossTrades <- FALSE                                 # Contrary trades in same market: TRUE/FALSE
LatencyImp  <- "very low"                            # Price/Trading Latency Impact on strategy
MaxPeriodV  <- 1                                     # Max Volume traded in one period
MinPeriodV  <- 0                                     # Min Volume traded in one period
Comissions  <- 0.001
TradeAmount <- 1 
InitialBalance <- 10000                              # Initial Balance for test

TradeStrat <- data.frame(fortify.zoo(meXBTMxn)$Index,
                         fortify.zoo(meXBTMxn)$Close,fortify.zoo(meXBTMxn)$Volume,rsi,sig)
colnames(TradeStrat) <- c("TimeStamp","Close","Volume","RSI","Signal")

TradeStrat <- TradeStrat[-c(1:HistInfo),]
TradeStrat$PeriodPL[1]  <- 0
TradeStrat$Comission[1] <- 0

for(i in 2:length(TradeStrat$Signal)-1){
  
  if(TradeStrat$Signal[i] == 1){
    TradeStrat$Comission[i]  <- (round(.001*(TradeStrat$Close[i]),4))*-1         # Buy Conditions
    TradeStrat$PeriodPL[i+1] <- TradeStrat$Close[i+1] - TradeStrat$Close[i] -
      .001*TradeStrat$Close[i]}
  
  if(TradeStrat$Signal[i] == -1){                                                # Sell Conditions
    TradeStrat$Comission[i]  <- (round(.001*(TradeStrat$Close[i]),4))*-1
    TradeStrat$PeriodPL[i+1] <- TradeStrat$Close[i] - TradeStrat$Close[i+1] - 
      .001*TradeStrat$Close[i]}
  
  if(TradeStrat$Signal[i] ==  0){
    TradeStrat$Comission[i] <- 0}}

TradeStrat$Balance <- InitialBalance
for(i in 2:length(TradeStrat$PeriodPL))
TradeStrat$Balance[i] <- TradeStrat$Balance[i-1] + TradeStrat$PeriodPL[i] + 
TradeStrat$Comission[i]
row.names(TradeStrat) <- NULL
TradeStrat$PeriodPL   <- round(TradeStrat$PeriodPL,2)

TradeChar <- data.frame(matrix(ncol = 2, nrow = 9))
TradeChar[,1] <- c("Coins per trade","MultiTrade","Price Interval","Max Open Trades",
"Multi Market","Cross Trades","Latency Impact","Max Volume per period","Min Volume per period")
TradeChar[,2] <- c(TradeAmount,MultiTrade,PriceInterv,MaxOpenT,MultiMarket,CrossTrades,LatencyImp,
paste(MaxPeriodV,"Coin(s)",sep=" "),paste(MinPeriodV,"Coin(s)",sep=" "))
TradeChar[,3] <- c("Price Periods","Upper Value","Lower Value","Historic Prices","","","","","")
TradeChar[,4] <- c(HistInfo,SellSignal,BuySignal,length(BtcPair[,1]),"","","","","")
colnames(TradeChar) <- c("Strategy Parameter","Value","Model Parameters","Value")

# ----------------------------------------------------------------------------------------------- #
# -- 5 -- Preeliminary Results ------------------------------------------------------------------ #
# ----------------------------------------------------------------------------------------------- #

gg_ser  <- FSerieM1(TradeStrat,"royal blue","black",2,"BtcMxn Prices","1 months","red","blue")
gg_ser1 <- FTradingSignal(TradeStrat,"royal blue","black",4,"RSI","1 months","red","blue")
gg_ser2 <- FEquity(TradeStrat,"royal blue","black",8,"Balance","1 months","red","blue")

# ----------------------------------------------------------------------------------------------- #
# -- 6 -- Performance, Risk and Benchmark Measures ---------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

PerformanceSummary <- data.frame(matrix(nrow = 11, ncol = 4))
PerformanceSummary[1:5,1] <- c("Max Profit","Max Loss","Sample Length","Short positions",
"Long positions")

PerformanceSummary[1,2] <- paste("$",TradeStrat$PeriodPL[which(TradeStrat$PeriodPL  == 
max(TradeStrat$PeriodPL))],sep=" ")

PerformanceSummary[2,2] <- paste("-$",TradeStrat$PeriodPL[which(TradeStrat$PeriodPL == 
min(TradeStrat$PeriodPL))],sep=" ")

PerformanceSummary[3,2] <- paste(length(TradeStrat$Signal),interval,sep=" ")
PerformanceSummary[4,2] <- length(count(which(TradeStrat$Signal == -1))[,1])
PerformanceSummary[5,2] <- length(count(which(TradeStrat$Signal == +1))[,1])

PerformanceSummary[6:11,1] <- c("Profit Made","Min Balance", "Max Balance","Coins traded",
"Week Traded Coins","Volume Added")
PerformanceSummary[6,2]  <- paste("$ ",round(TradeStrat$Balance[length(TradeStrat$Balance)] - 
InitialBalance,2),sep="")
PerformanceSummary[7,2]  <- paste("$ ",round(min(TradeStrat$Balance),2),sep="")
PerformanceSummary[8,2]  <- paste("$ ",round(max(TradeStrat$Balance),2),sep="")
PerformanceSummary[9,2]  <- length(count(which(TradeStrat$Signal != 0))[,1])*2
PerformanceSummary[10,2] <- round(length(count(which(TradeStrat$Signal != 0))[,1])/53,4)*2
PerformanceSummary[11,2] <- round(length(count(which(TradeStrat$Signal != 0))[,1])/
length(TradeStrat$Balance),2)*2

TradeStratP <- TradeStrat
TradeStratP$TimeStamp <-as.POSIXct(TradeStratP$TimeStamp)
BalanceRet <- Return.calculate(xts(TradeStratP$Balance, order.by = TradeStratP$TimeStamp))
BalanceRet <- BalanceRet[-1,]
BalanceRet <- BalanceRet[-which(BalanceRet == 0),]

DSR <- round(DownsideDeviation(BalanceRet, MAR = 0),4)
ADD <- round(AverageDrawdown(BalanceRet),4) # average depth of the observed drawdowns
ALH <- round(AverageLength(BalanceRet),4)   # average length of the drawdowns observed.
ARY <- round(AverageRecovery(BalanceRet),4) # average recovery period of the drawdowns

VaR1 <- VaR(BalanceRet, p=0.95, method="historical")*10000

BL <- round(BernardoLedoitRatio(BalanceRet),4)
IR <- 2.22
KR <- round(KellyRatio(BalanceRet, Rf=0.035/255),4)
MG <- round(Modigliani(BalanceRet, IPCRet, Rf=0),4)
SR <- round(SortinoRatio(BalanceRet, MAR=0.035/255),4)
TR <- 2.22

PerformanceSummary[,3] <- c("Downside Deviation","Average Drawdown","Average Length",
"Average Recovery","VaR(Historical)","BernardoLedoit Ratio","ActiveReturn",
"Kelly Ratio","Modigliani Ratio","Sortino Ratio","Treynor Ratio")
PerformanceSummary[,4] <- c(DSR,ADD,ALH,ARY,VaR1,BL,IR,KR,MG,SR,TR)
colnames(PerformanceSummary) <- c("Trading Parameters","Value", "Risk&Performance","Value")

# ----------------------------------------------------------------------------------------------- #
# -- 7 -- Graphical summary generation ---------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

TradePerformancegg <- qplot(1:15, 1:15, geom = "blank") +
theme(panel.background = element_rect(fill="white"),line = element_blank(),text=element_blank()) +
annotation_custom(grob = tableGrob(PerformanceSummary,
gpar.corefill = gpar(fill = "white", col="dark grey"), show.hlines = TRUE,
show.rownames = FALSE, gp = gpar(fontsize=11)))

TradeChargg <- qplot(1:15, 1:15, geom = "blank") +
theme(panel.background = element_rect(fill="white"),line = element_blank(),text = element_blank()) +
annotation_custom(grob = tableGrob(TradeChar,
gpar.corefill = gpar(fill = "white", col="dark grey"), show.hlines = TRUE,
show.rownames = FALSE, gp = gpar(fontsize=11)))

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

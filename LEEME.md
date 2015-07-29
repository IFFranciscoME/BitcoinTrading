# BitcoinTrading

Estrategia de trading utilizando bitcoin a través de meXBT Exchange

- *License:* GNU General Public License
- *Guadalajara, México*

**Bitcoin** es más que una herramienta eficiente para realiar pagos punto a punto, de manera segura e instantánea.
Como cualquier otra moneda, también se puede realizar trading con fines de cobertura, arbitraje o especulativos. Éste 
código fue realizado y es compartido con la finalidad de mostrar un ejemplo de como construir una estratégia bastante
básica y también rentable, realizando esto en **meXBT** el mercado mexicano de bitcoin y particularmente el par de 
"BtcMxn".

### Paquetes de R utilizados

Para poder instalar y/o cargar los paquetes de R necesarios para éste código, se utiliza el siguiente código.

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

### Otras conexiones de soporte

Ésta estrategia de trading utiliza varias funciones para cargar, procesar y visualizar datos y cálculos. Para ésto otros
repositorios son utilizados:

- meXBT Data API for R: [meXBT-data-r](https://raw.githubusercontent.com/IFFranciscoME/mexbt-data-r/clean-master/meXBTRClient.R)
- IF.Francisco.ME Data Processor Bundle: [DataProcessor](https://raw.githubusercontent.com/IFFranciscoME/DataProcessor/master/DataProcessor.R)

- IF.Francisco.ME Data Visualization Bundle: [DataVisualization](https://raw.githubusercontent.com/IFFranciscoME/DataVisualization/master/DataVisualization.R)

- IF.Francisco.ME Data Visualization Bundle: [APIConnector](https://raw.githubusercontent.com/IFFranciscoME/APIConnector/master/APIConnector.R)

### Collect data
Para obtener los datos y guardarlos en la memoria es tan simple como realizarlo con una función de una línea.

```r
BtcPair  <- OHLC(Instrmt,since,interval)
IPC <- OYStockD1("^IPC","yahoo",Sys.Date()-1000,Sys.Date())
```

### Respecto a la estrategia se define lo siguiente

- Existencia: Relative Strength Index (RSI) Indicador Técnico.
- Fenómeno: Niveles/áreas de sobrecompra y sobreventa
- Parametros: Información histórica de datos para el cálculo, dos niveles de ejecución
- Varriable del tipo: Endógena.
- Oportunidad: Vender en SobreCompra / Comprar en SobreVenta

### Continua

Después de definir lo anterior, en el código general lo que sigue es, a grandes rasgos, primeramente calcular y graficar
la señal de trading (RSI Index), después generar una tabla con los parámetros de la estratégia y la información histórica 
de los precios y el RSI Index, después de los parámetros de desempeño y de riesgo para finalmente construir el conjunto de
gráficas de resultado y presentarlas.

### Éste es el resultado que se obtiene con el código

![ArimaForecast](/BitcoinTrading(Example).png?raw=true)

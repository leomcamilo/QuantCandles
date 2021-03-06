Hammer <- function(symbol){ #Código do Instrumento, Dias ...
  library(quantmod)
  library(zoo)
  library(xts)
  days = 5
  # Carrega dados de um dia
  ResultStock <- na.omit(prices(symbol))
  Stock <- data.frame(zoo::coredata(ResultStock))
  #Adicionando a sombra superior e inferior

  #Criando o vetor nulo do tamanho do número de linhas
  SombSup <- vector(length = length(Stock$open))
  SombInf <- vector(length = length(Stock$open))

  #Preenchendo as colunas SombSup e SombInf

  SombSup <- (Stock$high-pmax(Stock$open,Stock$close))/abs(Stock$open-Stock$close)
  SombSup[SombSup==Inf] = 2.5
  SombInf <-  (pmin(Stock$open,Stock$close)-Stock$low)/abs(Stock$open-Stock$close)
  SombInf[SombInf==Inf] = 2.5

  High_Low <- vector(length = length(Stock$open))
  High_Low <- ifelse(Stock$close>Stock$open,1,
                     ifelse(Stock$close<Stock$open,-1,0))
  # Stock <- cbind(Stock,SombSup,SombInf,High_Low)
  #Baixa Anterior
  #Criar vetor nulo Vetor_Soma, que irá somar as linhas no final da iteração
  Vector_Sum_1 <- vector(mode="integer", length = (length(High_Low) - days))
  Vector_Sum_2 <- vector(mode="integer", length = (length(High_Low) - days))
  #Criar 1 vetor que irá se modificar na iteração pros dias anteriores e posteriores
  j <- vector(mode="integer", length = (length(High_Low) - days))
  for(k in 1:days){
    j <- High_Low[k:(length(High_Low)-days+k-1)]
    ifelse(k==1,Vector_Sum_1 <- j,Vector_Sum_1 <- cbind(Vector_Sum_1,j))

    l <- High_Low[(days-k+2):(length(High_Low)-k+1)]
    ifelse(k==1,Vector_Sum_2 <- l,Vector_Sum_2 <- cbind(Vector_Sum_2,l))
  }
  #Comparar o close de days, passado, com o dia atual
  y <- Stock$close
  past <- y[1:(length(y)-days)]
  future <- y[(days+1):length(y)]
  past1 <- c(vector(mode = "integer", length = days),past)
  future1 <- c(vector(mode = "integer", length = days),future)

  #Comparar o close de days, futuro, com o dia atual
  past2 <- c(past,vector(mode = "integer", length = days))
  future2 <- c(future,vector(mode = "integer", length = days))

  #Criando o vetor nulo para botar depois do LBef e antes do bDep
  LBef <- rowSums(Vector_Sum_1)<=-2
  HAft <- rowSums(Vector_Sum_2)>= 2
  LBef <- c(vector(length = days),LBef)
  HAft <- c(HAft,vector(length = days))
  LBef <- LBef & (past1 > future1)
  HAft <- HAft & (past2 < future2)
  # Stock <- cbind(Stock,LBef,HAft)

  #Hammer, Inverted Hammer, Black and White
  isHammer <- SombInf >= 2.5 & SombSup == 0
  isInv_Hammer <- SombInf == 0 & SombSup >= 2.5
  isHammer[is.na(isHammer)] <- 0
  isInv_Hammer[is.na(isInv_Hammer)] <- 0
  isBlack <- (isHammer | isInv_Hammer)&(Stock$open > Stock$close)
  isWhite <- (isHammer | isInv_Hammer)&(Stock$open < Stock$close)
  isBlack[is.na(isBlack)] <- 0
  isWhite[is.na(isWhite)] <- 0

  ResultStock <- cbind(ResultStock,isHammer,isInv_Hammer,isBlack,isWhite)
  names(ResultStock)<- c("open","high","low","close","isHammer","isInv_Hammer","isBlack","isWhite")


  return(ResultStock)
}

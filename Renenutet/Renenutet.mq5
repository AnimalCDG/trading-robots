//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Core/Enums.mqh"
#include "Indicators/MovingAverage.mqh"
#include "Indicators/PriceLevels.mqh"
#include "Indicators/CandleData.mqh"
#include "Trading/Trading.mqh"

MediaMovel ema7 =
{
   "EMA07",
   EMA,
   7
};

MediaMovel ema20 =
{
   "EMA20",
   EMA,
   20
};

/*
MediaMovel sma50 =
{
   "SMA50",
   SMA,
   50
};
*/

ResistenciaSuporte sr37 = {
   "03_07",
   3,
   7,
   true
};

SDadosCandle dados;

double resistencia;
double suporte;

double min03_07 = 0;
double max03_07 = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   
   ChartTemplate();
   
   InicializarMedia(ema7);
   InicializarMedia(ema20);
   
   InicializarNivelPreco(sr37);
   
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
   
   //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //---

   AtualizarNivelPreco(sr37);
   
   PrintPriceLevel(sr37);
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   /*
   if( (ema20.trend.tendencia == FORTE_ALTA) || (ema20.trend.tendencia == ALTA) && (sma20.trend.tendencia == FORTE_ALTA) || (sma20.trend.tendencia == ALTA)) {
      if(bid <= sr37.suporte.valor) {
         Print("OPERAÇÃO DE COMPRA [", bid, "]");
      }
   }
   */
   AtualizarMedia(ema7);
   AtualizarMedia(ema20);
   
   if(ObterDadosCandle(PERIOD_D1, 1, dados))
   {
      PrintFormat("O=%.5f H=%.5f L=%.5f C=%.5f | %%Max=%.3f%% %%Min=%.3f%%",
         dados.abertura, dados.maxima, dados.minima, dados.fechamento,
         dados.percentualMaxima, dados.percentualMinima);
   }
   
   PrintMedia(ema7);
   PrintMedia(ema20);
   
   //---   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Core/ChartRenderer.mqh"
#include "Indicators/MovingAverage.mqh"

MediaMovel ema20 =
{
   "EMA20",
   EMA,
   20
};

MediaMovel sma50 =
{
   "SMA50",
   SMA,
   50
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   
   ChartTemplate();
   
   InicializarMedia(ema20);
   InicializarMedia(sma50);   
   
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
   
   AtualizarMedia(ema20);
   AtualizarMedia(sma50);
   
   PrintMedia(ema20);
   PrintMedia(sma50);
   
   //---   
}
//+------------------------------------------------------------------+

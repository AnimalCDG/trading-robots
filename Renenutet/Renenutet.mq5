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
#include "Indicators/PriceLevels.mqh"

MediaMovel ema20 =
{
   "EMA20",
   EMA,
   20
};

MediaMovel ema50 =
{
   "EMA50",
   EMA,
   50
};

MediaMovel ema100 =
{
   "EMA100",
   EMA,
   100
};

MediaMovel ema200 =
{
   "EMA200",
   EMA,
   200
};

MediaMovel sma50 =
{
   "SMA50",
   SMA,
   50
};

ResistenciaSuporte sr37 = {
   "03_07",
   3,
   7
};

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
   
   InicializarMedia(ema20);
   InicializarMedia(ema50);
   InicializarMedia(ema100);
   InicializarMedia(ema200);
   InicializarMedia(sma50);
   
   InicializarNivelPreco(sr37);
   DrawLine(sr37.suporte.nome, sr37.suporte.cor, sr37.suporte.style, sr37.suporte.valor);
   DrawLine(sr37.resistencia.nome, sr37.resistencia.cor, sr37.resistencia.style, sr37.resistencia.valor);
   
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
   DrawLine(sr37.suporte.nome, sr37.suporte.cor, sr37.suporte.style, sr37.suporte.valor);
   DrawLine(sr37.resistencia.nome, sr37.resistencia.cor, sr37.resistencia.style, sr37.resistencia.valor);
   
   PrintPriceLevel(sr37);
   
   AtualizarMedia(ema20);
   AtualizarMedia(ema50);   
   AtualizarMedia(ema100);
   AtualizarMedia(ema200);
   AtualizarMedia(sma50);
   
   PrintMedia(ema20);
   PrintMedia(ema50);
   PrintMedia(ema100);
   PrintMedia(ema200);
   PrintMedia(sma50);
   
   //---   
}
//+------------------------------------------------------------------+

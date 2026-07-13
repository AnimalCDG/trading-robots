//+------------------------------------------------------------------+
//|                                                   CandleData.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __CANDLE_DATA_MQH__
#define __CANDLE_DATA_MQH__

#include "../Core/Structs.mqh"

//+------------------------------------------------------------------+
//| Retorna abertura, maxima, minima e fechamento de um candle,      |
//| junto com a variacao percentual da maxima e da minima em         |
//| relacao a abertura.                                              |
//|                                                                    |
//| periodo : timeframe do candle (ex: PERIOD_D1, PERIOD_H1, ...)    |
//| indice  : deslocamento a partir do candle atual                  |
//|           0 = candle atual (em formacao)                          |
//|           1 = candle anterior (ultimo fechado)                    |
//|           2 = dois candles atras, e assim por diante              |
//| dados   : struct preenchida com o resultado (passada por          |
//|           referencia)                                             |
//|                                                                    |
//| Retorna true em caso de sucesso, false se os dados nao puderam    |
//| ser obtidos (ex: historico insuficiente).                         |
//+------------------------------------------------------------------+
bool ObterDadosCandle(ENUM_TIMEFRAMES periodo, int indice, SDadosCandle &dados)
{
   double abertura   = iOpen(_Symbol, periodo, indice);
   double maxima     = iHigh(_Symbol, periodo, indice);
   double minima     = iLow(_Symbol, periodo, indice);
   double fechamento = iClose(_Symbol, periodo, indice);

   if(abertura <= 0.0)
   {
      Print("ObterDadosCandle: nao foi possivel obter dados do candle (periodo=",
            EnumToString(periodo), ", indice=", indice, ").");
      return false;
   }

   dados.abertura   = abertura;
   dados.maxima     = maxima;
   dados.minima     = minima;
   dados.fechamento = fechamento;

   dados.percentualMaxima = (maxima - abertura) / abertura * 100.0;
   dados.percentualMinima = MathAbs((minima - abertura) / abertura * 100.0);

   return true;
}

#endif
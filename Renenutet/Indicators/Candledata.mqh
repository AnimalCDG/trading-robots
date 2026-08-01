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
   dados.situacao   = (abertura > fechamento);

   dados.percentualMaxima = (maxima - abertura) / abertura * 100.0;
   dados.percentualMinima = MathAbs((minima - abertura) / abertura * 100.0);

   return true;
}

/**
 * @brief Detecta o fechamento de um candle.
 *
 * Verifica se um novo candle foi iniciado comparando o horário de abertura
 * do candle atual com o da última execução. Quando um novo candle é criado,
 * significa que o candle anterior foi fechado.
 *
 * @param debug Se true, exibe uma mensagem no log quando um novo candle é detectado.
 *
 * @return true  Se um novo candle foi iniciado (candle anterior fechado).
 * @return false Caso contrário.
 */
bool DetectarFechamentoCandle(bool debug = false) {

   static datetime ultimoCandle = 0;
   datetime candleAtual = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(candleAtual != ultimoCandle)
   {
      ultimoCandle = candleAtual;
      if(debug)
         Print("Candle anterior fechado!");
      return true;
   }
   
   return false;
}

bool DetectarOutSiderCandle(bool debug = false) {
   
   static bool retornoOutSider = false;

   static SDadosCandle ultimoCandle;
   static SDadosCandle antePenultimoCandle;
   
   ObterDadosCandle(PERIOD_CURRENT, 1, ultimoCandle);
   ObterDadosCandle(PERIOD_CURRENT, 2, antePenultimoCandle);
   
   retornoOutSider = (ultimoCandle.maxima > antePenultimoCandle.maxima) && (ultimoCandle.minima < antePenultimoCandle.minima);
   
   if(debug);
      PrintFormat(
            "%s=%d|%s",
            "OutSider",
            retornoOutSider,
            retornoOutSider ? "Sim" : "Não"
         );
   
   return retornoOutSider;
}

bool DetectarInSiderCandle(bool debug = false) {
   bool retornoInSider = false;
   
   static SDadosCandle ultimoCandle;
   static SDadosCandle antePenultimoCandle;
   
   ObterDadosCandle(PERIOD_CURRENT, 1, ultimoCandle);
   ObterDadosCandle(PERIOD_CURRENT, 2, antePenultimoCandle);
   
   retornoInSider = (ultimoCandle.maxima < antePenultimoCandle.maxima) && (ultimoCandle.minima > antePenultimoCandle.minima);
   
   if(debug);
      PrintFormat(
            "%s=%d|%s",
            "InSider",
            retornoInSider,
            retornoInSider ? "Sim" : "Não"
         );
   
   return retornoInSider;
}

#endif
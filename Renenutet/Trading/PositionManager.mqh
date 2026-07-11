//+------------------------------------------------------------------+
//|                                             PositionManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#ifndef __POSITION_MANAGER_MQH__
#define __POSITION_MANAGER_MQH__

#include <Trade\Trade.mqh>
#include "OrderManager.mqh"
#include "../Core/Utils.mqh"

//+------------------------------------------------------------------+
//| Move o SL da posicao para o breakeven (preco de entrada) assim   |
//| que o lucro atingir gatilhoPercent. Opcionalmente trava um       |
//| percentual extra de lucro (travaPercent) em vez de zerar exato.  |
//|                                                                    |
//| gatilhoPercent : % de lucro (sobre o preco de entrada) para      |
//|                   disparar o breakeven                            |
//| travaPercent   : % de lucro a travar alem da entrada (0 = so      |
//|                   move o SL para o preco de entrada)              |
//|                                                                    |
//| Retorna true se moveu o SL, false se nao havia gatilho ou falhou.|
//+------------------------------------------------------------------+
bool AplicarBreakEven(long ticket, double gatilhoPercent, double travaPercent = 0.0)
{
   if(!PositionSelectByTicket((ulong)ticket))
   {
      Print("AplicarBreakEven: posicao com ticket ", ticket, " nao encontrada.");
      return false;
   }

   double precoEntrada = PositionGetDouble(POSITION_PRICE_OPEN);
   double slAtual       = PositionGetDouble(POSITION_SL);
   double tpAtual        = PositionGetDouble(POSITION_TP);
   ENUM_POSITION_TYPE tipo = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   double precoAtual = (tipo == POSITION_TYPE_BUY)
                        ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                        : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double lucroPercent = (tipo == POSITION_TYPE_BUY)
                          ? (precoAtual - precoEntrada) / precoEntrada * 100.0
                          : (precoEntrada - precoAtual) / precoEntrada * 100.0;

   if(lucroPercent < gatilhoPercent)
      return false; // ainda nao atingiu o gatilho

   double novoSL = precoEntrada;
   double variacaoTrava = precoEntrada * (travaPercent / 100.0);

   if(tipo == POSITION_TYPE_BUY)
      novoSL = precoEntrada + variacaoTrava;
   else
      novoSL = precoEntrada - variacaoTrava;

   novoSL = NormalizarPreco(novoSL);

   // Evita mover o SL para tras (so avanca a favor da posicao)
   if(slAtual != 0.0)
   {
      if(tipo == POSITION_TYPE_BUY && novoSL <= slAtual)
         return false;
      if(tipo == POSITION_TYPE_SELL && novoSL >= slAtual)
         return false;
   }

   CTrade trade;
   trade.SetExpertMagicNumber((long)PositionGetInteger(POSITION_MAGIC));

   if(!trade.PositionModify((ulong)ticket, novoSL, tpAtual))
   {
      Print("AplicarBreakEven: falha ao mover SL do ticket ", ticket,
            " - erro ", GetLastError(), " (retcode ", trade.ResultRetcode(), ")");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Aplica trailing stop na posicao: mantem o SL a uma distancia     |
//| fixa (distanciaPercent) do preco atual, sempre que o preco       |
//| avancar a favor da posicao.                                      |
//|                                                                    |
//| distanciaPercent : % sobre o preco atual usado como distancia    |
//|                     do SL                                         |
//|                                                                    |
//| Retorna true se moveu o SL, false se nao havia melhora ou falhou.|
//+------------------------------------------------------------------+
bool AplicarTrailingStop(long ticket, double distanciaPercent)
{
   if(!PositionSelectByTicket((ulong)ticket))
   {
      Print("AplicarTrailingStop: posicao com ticket ", ticket, " nao encontrada.");
      return false;
   }

   double slAtual = PositionGetDouble(POSITION_SL);
   double tpAtual  = PositionGetDouble(POSITION_TP);
   ENUM_POSITION_TYPE tipo = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   double precoAtual = (tipo == POSITION_TYPE_BUY)
                        ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                        : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double distancia = precoAtual * (distanciaPercent / 100.0);
   double novoSL;

   if(tipo == POSITION_TYPE_BUY)
      novoSL = precoAtual - distancia;
   else
      novoSL = precoAtual + distancia;

   novoSL = NormalizarPreco(novoSL);

   // So move o SL se for uma melhora (mais perto do lucro) em relacao ao atual
   if(slAtual != 0.0)
   {
      if(tipo == POSITION_TYPE_BUY && novoSL <= slAtual)
         return false;
      if(tipo == POSITION_TYPE_SELL && novoSL >= slAtual)
         return false;
   }

   CTrade trade;
   trade.SetExpertMagicNumber((long)PositionGetInteger(POSITION_MAGIC));

   if(!trade.PositionModify((ulong)ticket, novoSL, tpAtual))
   {
      Print("AplicarTrailingStop: falha ao mover SL do ticket ", ticket,
            " - erro ", GetLastError(), " (retcode ", trade.ResultRetcode(), ")");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Modifica o Stop Loss da posicao, mantendo o Take Profit atual    |
//+------------------------------------------------------------------+
bool ModificarStop(long ticket, double novoSL)
{
   if(!PositionSelectByTicket((ulong)ticket))
   {
      Print("ModificarStop: posicao com ticket ", ticket, " nao encontrada.");
      return false;
   }

   double takeProfitAtual = PositionGetDouble(POSITION_TP);

   CTrade trade;
   trade.SetExpertMagicNumber((long)PositionGetInteger(POSITION_MAGIC));

   if(!trade.PositionModify((ulong)ticket, novoSL, takeProfitAtual))
   {
      Print("ModificarStop: falha ao modificar ticket ", ticket,
            " - erro ", GetLastError(), " (retcode ", trade.ResultRetcode(), ")");
      return false;
   }

   return true;
}

#endif
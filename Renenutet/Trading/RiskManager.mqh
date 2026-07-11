//+------------------------------------------------------------------+
//|                                                 RiskManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include "../Core/Utils.mqh"

//+------------------------------------------------------------------+
//| Calcula o Stop Loss a partir de um percentual sobre o preco de   |
//| entrada, respeitando a direcao da ordem:                         |
//|   - ORDER_TYPE_BUY : SL fica ABAIXO do preco de entrada          |
//|   - ORDER_TYPE_SELL: SL fica ACIMA  do preco de entrada          |
//+------------------------------------------------------------------+
double CalcularStopLoss(double precoEntrada, double slPercent, ENUM_ORDER_TYPE tipo)
{
   if(precoEntrada <= 0.0)
   {
      Print("CalcularStopLoss: precoEntrada invalido (", precoEntrada, ").");
      return 0.0;
   }

   if(tipo == ORDER_TYPE_BUY)
      return PrecoAPartirDePercentual(precoEntrada, slPercent, false);

   if(tipo == ORDER_TYPE_SELL)
      return PrecoAPartirDePercentual(precoEntrada, slPercent, true);

   Print("CalcularStopLoss: tipo de ordem nao suportado (", EnumToString(tipo), ").");
   return 0.0;
}

//+------------------------------------------------------------------+
//| Calcula o Take Profit a partir de um percentual sobre o preco de |
//| entrada, respeitando a direcao da ordem:                         |
//|   - ORDER_TYPE_BUY : TP fica ACIMA  do preco de entrada          |
//|   - ORDER_TYPE_SELL: TP fica ABAIXO do preco de entrada          |
//+------------------------------------------------------------------+
double CalcularTakeProfit(double precoEntrada, double tpPercent, ENUM_ORDER_TYPE tipo)
{
   if(precoEntrada <= 0.0)
   {
      Print("CalcularTakeProfit: precoEntrada invalido (", precoEntrada, ").");
      return 0.0;
   }

   if(tipo == ORDER_TYPE_BUY)
      return PrecoAPartirDePercentual(precoEntrada, tpPercent, true);

   if(tipo == ORDER_TYPE_SELL)
      return PrecoAPartirDePercentual(precoEntrada, tpPercent, false);

   Print("CalcularTakeProfit: tipo de ordem nao suportado (", EnumToString(tipo), ").");
   return 0.0;
}

#endif
//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __UTILS_MQH__
#define __UTILS_MQH__

#include "Enums.mqh"

string TendenciaToString(Tendencia tendencia)
{
   switch(tendencia)
   {
      case FORTE_ALTA:  return "↑↑ Forte Alta";
      case ALTA:        return "↑ Alta";
      case LATERAL:     return "→ Lateral";
      case BAIXA:       return "↓ Baixa";
      case FORTE_BAIXA: return "↓↓ Forte Baixa";
      default:          return "Erro";
   }
}

string TipoMediaToString(TipoMedia tipo)
{
   if(tipo == EMA)
      return "EMA";

   return "SMA";
}

//+------------------------------------------------------------------+
//| Normaliza um preco para o tick size do simbolo atual, evitando   |
//| erros de "invalid price" ao enviar ordens (TRADE_RETCODE_INVALID |
//| _PRICE) por preco fora da grade de ticks permitida.               |
//+------------------------------------------------------------------+
double NormalizarPreco(double preco)
{
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickSize <= 0.0)
      tickSize = _Point;

   double precoNormalizado = MathRound(preco / tickSize) * tickSize;

   return NormalizeDouble(precoNormalizado, _Digits);
}

//+------------------------------------------------------------------+
//| Calcula um preco a partir de um percentual sobre um preco base.  |
//| paraCima = true  -> soma o percentual (precoBase * (1 + %))      |
//| paraCima = false -> subtrai o percentual (precoBase * (1 - %))   |
//| O resultado ja vem normalizado ao tick size do simbolo.          |
//+------------------------------------------------------------------+
double PrecoAPartirDePercentual(double precoBase, double percentual, bool paraCima)
{
   double variacao = precoBase * (percentual / 100.0);
   double resultado = paraCima ? (precoBase + variacao) : (precoBase - variacao);

   return NormalizarPreco(resultado);
}

#endif
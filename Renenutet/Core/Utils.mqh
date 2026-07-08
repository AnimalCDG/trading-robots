//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
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

#endif
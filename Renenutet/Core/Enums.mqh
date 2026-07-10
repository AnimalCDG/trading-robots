//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
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
#ifndef __ENUMS_MQH__
#define __ENUMS_MQH__

enum Tendencia
{
   ERRO = -1,

   FORTE_BAIXA = 0,
   BAIXA,
   LATERAL,
   ALTA,
   FORTE_ALTA
};

enum TipoMedia
{
   SMA = 0,
   EMA
};

enum TipoNivelPreco
{
   HIGH,
   LOW
};

#endif
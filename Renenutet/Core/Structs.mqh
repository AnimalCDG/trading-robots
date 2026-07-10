//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
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
#ifndef __STRUCTS_MQH__
#define __STRUCTS_MQH__

#include "Enums.mqh"

struct IndicadorTrend
{
   double valorAtual;
   double valorAnterior;

   double delta;
   double slope;

   int score;

   double forca;

   bool subindo;
   bool acelerando;

   Tendencia tendencia;
};

struct MediaMovel
{
   string nome;

   TipoMedia tipo;

   int periodo;

   int handle;

   IndicadorTrend trend;
};

struct ValorSuporte
{
   string nome;
   double valor;
   color cor;
   int style;
};

struct ValorResistente
{
   string nome;
   double valor;
   color cor;
   int style;
};

struct ResistenciaSuporte
{
   string nome;
   int min;
   int max;
   ValorSuporte suporte;
   ValorResistente resistencia;
};

#endif
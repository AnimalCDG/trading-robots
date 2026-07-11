//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
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

struct ValorSR
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
   bool exibirObjeto;
   ValorSR suporte;
   ValorSR resistencia;
};

struct SConfigEntrada
{
   double precoGatilho;   // 1.300
   double loteCompra;     // 0.03
   long   magic;
};

struct SConfigVenda
{
   double lote;           // 0.01
   double slPercent;      // 10%
   double tpPercent;      // 0.033% / 0.066% / 0.01%
};

#endif
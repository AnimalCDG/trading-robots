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

struct SDadosCandle
{
   double abertura;
   double maxima;
   double minima;
   double fechamento;

   double percentualMaxima; // variação % da máxima em relação à abertura (positivo)
   double percentualMinima; // variação % da mínima em relação à abertura (sempre positivo/absoluto)
};

struct SParametrosOperacionais
{
   double saldoDisponivel;  // margem livre (ACCOUNT_MARGIN_FREE) atual da conta
   double capitalAlocado;   // saldoDisponivel * percentual configurado
   double loteMaximo;       // lote máximo que o capitalAlocado permite abrir, já normalizado
   bool   podeOperar;       // true se há capital/margem suficiente para abrir ao menos o lote mínimo
};

#endif
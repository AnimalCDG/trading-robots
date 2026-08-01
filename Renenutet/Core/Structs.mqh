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
   bool situacao;

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

//+------------------------------------------------------------------+
//| Ponto de preço (topo ou fundo) usado na detecção de padrões       |
//+------------------------------------------------------------------+
struct SPontoPreco
{
   datetime tempo;
   double   preco;
   int      indiceBar; // shift no momento da detecção (0 = candle atual)
};

//+------------------------------------------------------------------+
//| Resultado da identificação de um Triângulo Simétrico              |
//+------------------------------------------------------------------+
struct STrianguloSimetrico
{
   bool        valido;
   SPontoPreco topos[];          // topos decrescentes (LTB)
   SPontoPreco fundos[];         // fundos crescentes (LTA)
   double      inclinacaoLTB;    // slope da reta superior
   double      interceptoLTB;
   double      inclinacaoLTA;    // slope da reta inferior
   double      interceptoLTA;
   int         totalToques;      // topos.Size() + fundos.Size()
   double      primeiroTopo;     // preço do topo mais antigo da formação
   double      primeiroFundo;    // preço do fundo mais antigo da formação
   double      amplitudeInicial; // |primeiroTopo - primeiroFundo|
};

struct SPontoFractalTA
{
   datetime tempo;
   double   preco;
   int      indiceBar;
};

struct SDadosTrianguloAscendente
{
   bool     valido;
   double   resistenciaHorizontal;   // nível médio dos topos
   double   primeiroTopo;            // topo mais antigo usado na figura
   double   fundoMaisBaixo;          // fundo mais antigo/mais baixo (base da LTA)
   double   amplitudeVertical;       // primeiroTopo - fundoMaisBaixo
   SPontoFractalTA topos[];          // topos no mesmo nível (mín. 2)
   SPontoFractalTA fundos[];         // fundos ascendentes (mín. 3)
   double   coefAngularLTA;          // inclinação da reta de fundos
   double   coefLinearLTA;           // y = coefAngularLTA*x + coefLinearLTA
   int      indiceBarInicioFigura;   // índice da barra mais antiga usada (topo ou fundo)
};

struct SDadosResistenciaSuporte
{
   double resistencia;
   double suporte;
};

#endif
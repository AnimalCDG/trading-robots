//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Core/Enums.mqh"
#include "Core/Constants.mqh"
#include "Indicators/MovingAverage.mqh"
#include "Indicators/PriceLevels.mqh"
#include "Indicators/CandleData.mqh"
#include "Trading/RiskManager.mqh"
#include "Trading/OrderManager.mqh"
#include "Trading/Trading.mqh"

input double PercentualAlocacaoTeste = 30.0;

SParametrosOperacionais parametros;

// Orcamento de lote disponivel para o teste (debitado a cada ordem criada)
double g_loteDisponivel = 0.0;

MediaMovel ema7 =
{
   "EMA07",
   EMA,
   7
};

MediaMovel ema20 =
{
   "EMA20",
   EMA,
   20
};

MediaMovel sma20 =
{
   "SMA20",
   SMA,
   20
};

ResistenciaSuporte sr37 = {
   "03_07",
   3,
   7,
   true
};

SDadosCandle dados;

double resistencia;
double suporte;

double min03_07 = 0;
double max03_07 = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   
   ChartTemplate();
   
   InicializarMedia(ema7);
   InicializarMedia(ema20);
   InicializarMedia(sma20);
   
   InicializarNivelPreco(sr37);
   
   if(ObterParametrosOperacionais(PercentualAlocacaoTeste, ORDER_TYPE_BUY, parametros))
   {
      g_loteDisponivel = parametros.loteMaximo;

      if(parametros.podeOperar)
         PrintFormat("Lote máximo permitido: %.2f (capital: %.2f de saldo: %.2f)",
            parametros.loteMaximo, parametros.capitalAlocado, parametros.saldoDisponivel);
      else
         Print("Sem condições de operar no momento.");
   }
   
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
   
   //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //---

   AtualizarNivelPreco(sr37);
   
   PrintPriceLevel(sr37);
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   AtualizarMedia(ema7);
   AtualizarMedia(ema20);
   AtualizarMedia(sma20);
   
   double entradaUm = 0.0;
   double entradaDois = 0.0;
   
   double saidaUM = 0.0;
   double saidaDois = 0.0;
   
   if(ObterDadosCandle(PERIOD_D1, 1, dados))
   {
      PrintFormat("O=%.5f H=%.5f L=%.5f C=%.5f | %%Max=%.3f%% %%Min=%.3f%%",
         dados.abertura, dados.maxima, dados.minima, dados.fechamento,
         dados.percentualMaxima, dados.percentualMinima);
         
      entradaUm = dados.fechamento - (dados.fechamento * (dados.percentualMinima / 100));
      entradaDois = dados.fechamento - (dados.fechamento * (dados.percentualMaxima / 100));
      
      saidaUM = entradaUm + (entradaUm * (dados.percentualMaxima / 100));
      saidaDois = entradaDois + (entradaDois * (dados.percentualMaxima / 100));
      
      Print("E1 [", entradaUm ,"] | E2 [", entradaDois ,"] S1 [", saidaUM ,"] | S2 [", saidaDois ,"]");

      // --- Teste: cria ordens pendentes de compra quando SMA20 estiver em alta ---
      if(sma20.trend.tendencia == ALTA || sma20.trend.tendencia == FORTE_ALTA)
      {
         if(g_loteDisponivel >= 0.01)
         {
            if(!ExisteOrdemNoPreco(entradaUm, MAGIC_TESTE))
            {
               if(AbrirOrdemPendenteCompra(entradaUm, 0.01, saidaUM, MAGIC_TESTE, "Teste E1") != 0)
                  g_loteDisponivel -= 0.01;
            }
         }

         if(g_loteDisponivel >= 0.01)
         {
            if(!ExisteOrdemNoPreco(entradaDois, MAGIC_TESTE))
            {
               if(AbrirOrdemPendenteCompra(entradaDois, 0.01, saidaDois, MAGIC_TESTE, "Teste E2") != 0)
                  g_loteDisponivel -= 0.01;
            }
         }
      }
   }

   if(parametros.podeOperar)
         PrintFormat("Lote máximo permitido: %.2f (capital: %.2f de saldo: %.2f) | Disponível para novas ordens: %.2f",
            parametros.loteMaximo, parametros.capitalAlocado, parametros.saldoDisponivel, g_loteDisponivel);
      else
         Print("Sem condições de operar no momento.");
   
   PrintMedia(ema7);
   PrintMedia(ema20);
   PrintMedia(sma20);
   
   //---   
}
//+------------------------------------------------------------------+
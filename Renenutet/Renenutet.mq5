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

input double PercentualAlocacaoTeste = 5.0;

#define MAGIC_TRIANGULO_ASCENDENTE 555002  // TODO: mover para Core/Constants.mqh junto de MAGIC_TRIANGULO, com valor definitivo

SParametrosOperacionais parametros;

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

double   DEBUG = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   
   ChartTemplate();
   
   //InicializarMedia(ema7);
   //InicializarMedia(ema20);
   
   //InicializarNivelPreco(sr37);
   
   //if(ObterParametrosOperacionais(PercentualAlocacaoTeste, ORDER_TYPE_BUY, parametros))
   //{
   //   if(parametros.podeOperar)
   //      PrintFormat("Lote máximo permitido: %.2f (capital: %.2f de saldo: %.2f)",
   //         parametros.loteMaximo, parametros.capitalAlocado, parametros.saldoDisponivel);
   //   else
   //      Print("Sem condições de operar no momento.");
   //}
   
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
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if (DetectarFechamentoCandle(DEBUG)) {
      DetectarOutSiderCandle(DEBUG);
      DetectarInSiderCandle(DEBUG);
   }   
   
   //AtualizarNivelPreco(sr37);   
   //PrintPriceLevel(sr37);
   
   //AtualizarMedia(ema7);
   //AtualizarMedia(ema20);
   
   /*
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

      // --- Teste: cria ordens pendentes de compra quando EMA20 estiver em alta ---
      if(ema7.trend.tendencia == ALTA || ema7.trend.tendencia == FORTE_ALTA)
      {
         if(ObterParametrosOperacionais(PercentualAlocacaoTeste, ORDER_TYPE_BUY, parametros) && parametros.podeOperar)
         {
            double loteRestanteTick = parametros.loteMaximo;

            if(loteRestanteTick >= 0.01 && !ExisteOrdemNoPreco(entradaUm, MAGIC_TESTE))
            {
               if(AbrirOrdemPendenteCompra(entradaUm, 0.01, saidaUM, MAGIC_TESTE, "Teste E1") != 0)
                  loteRestanteTick -= 0.01;
            }

            if(loteRestanteTick >= 0.01 && !ExisteOrdemNoPreco(entradaDois, MAGIC_TESTE))
            {
               if(AbrirOrdemPendenteCompra(entradaDois, 0.01, saidaDois, MAGIC_TESTE, "Teste E2") != 0)
                  loteRestanteTick -= 0.01;
            }
         }
      }
   }
   */
   
   //ProcessarTrianguloSimetrico(0.01, MAGIC_TRIANGULO); // lote e magic number a definir
   //ProcessarTrianguloAscendente(0.01, MAGIC_TRIANGULO_ASCENDENTE); // magic distinto do Simetrico p/ nao conflitar checagens de posicao/ordem
   
   //if(parametros.podeOperar)
   //      PrintFormat("Lote máximo permitido: %.2f (capital: %.2f de saldo: %.2f)",
   //         parametros.loteMaximo, parametros.capitalAlocado, parametros.saldoDisponivel);
   //   else
   //      Print("Sem condições de operar no momento.");
   
   //PrintMedia(ema7);
   //PrintMedia(ema20);
   
   //---   
}
//+------------------------------------------------------------------+
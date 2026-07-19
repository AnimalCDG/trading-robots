//+------------------------------------------------------------------+
//|                                                      Trading.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __TRADING_MQH__
#define __TRADING_MQH__

#include "../Core/Structs.mqh"
#include "../Patterns/TrianguloSimetrico.mqh"
#include "../Patterns/TrianguloAscendente.mqh"
#include "OrderManager.mqh"
#include "RiskManager.mqh"
#include "PositionManager.mqh"

void VerificarGatilhoEntrada(SConfigEntrada &config);
void ProcessarComprasPendentes(long magic);           // detecta compra executada
void CriarOrdensVendaMultiplas(double precoEntradaCompra, SConfigVenda &vendas[], long magic);

//+------------------------------------------------------------------+
//| Identifica o Triangulo Simetrico e, se houver rompimento no      |
//| candle fechado mais recente, envia uma ordem Stop (Buy Stop na   |
//| maxima ou Sell Stop na minima do candle de rompimento) com SL no |
//| extremo oposto do mesmo candle e TP pela projecao de Fibonacci   |
//| (100% da amplitude inicial do triangulo).                        |
//+------------------------------------------------------------------+
void ProcessarTrianguloSimetrico(double lote, long magic)
{
   // processa no maximo uma vez por candle novo (evita reavaliar o mesmo
   // rompimento a cada tick enquanto o candle atual ainda esta formando)
   static datetime ultimoCandleSimetrico = 0;
   datetime candleAtualSimetrico = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(candleAtualSimetrico == ultimoCandleSimetrico)
      return;
   ultimoCandleSimetrico = candleAtualSimetrico;

   // ja existe posicao aberta ou ordem pendente para esse magic? nao duplica
   if(ExistePosicaoAberta(magic) || ExisteOrdemPendente(magic))
      return;

   STrianguloSimetrico triangulo;
   if(!IdentificarTrianguloSimetrico(_Symbol, PERIOD_CURRENT, InpBarrasAnaliseTriangulo, triangulo))
      return;

   double entrada = 0.0, stop = 0.0;

   // Rompimento de alta: fechamento acima da LTB -> Buy Stop na maxima do candle
   if(VerificarRompimentoAlta(triangulo, _Symbol, PERIOD_CURRENT, 1, entrada, stop))
   {
      if(!ExisteOrdemNoPreco(entrada, magic))
      {
         double alvo = CalcularAlvoCompra(triangulo, entrada);
         AbrirOrdemPendenteCompraStop(entrada, lote, stop, alvo, magic, "TrianguloSimetrico-Compra");
      }
      return;
   }

   // Rompimento de baixa: fechamento abaixo da LTA -> Sell Stop na minima do candle
   if(VerificarRompimentoBaixa(triangulo, _Symbol, PERIOD_CURRENT, 1, entrada, stop))
   {
      if(!ExisteOrdemNoPreco(entrada, magic))
      {
         double alvo = CalcularAlvoVenda(triangulo, entrada);
         AbrirOrdemPendenteVendaStop(entrada, lote, stop, alvo, magic, "TrianguloSimetrico-Venda");
      }
   }
}

//--- Estado do Triangulo Ascendente (uma figura por vez, mesmo esquema do Simetrico)
int  InpBarrasAnaliseTA = 100;  // janela de busca de fractais; mover para input em Renenutet.mq5 se quiser ajustar via propriedades do EA
SDadosTrianguloAscendente g_trianguloAscendente;
bool g_trianguloAscendenteAtivo = false;

//+------------------------------------------------------------------+
//| Identifica o Triangulo Ascendente e, se houver rompimento no      |
//| candle fechado mais recente, envia uma ordem Stop (Buy Stop na    |
//| maxima ou Sell Stop na minima do candle de rompimento) com SL no  |
//| extremo oposto do mesmo candle e TP pela projecao de Fibonacci    |
//| (100% da amplitude vertical do triangulo).                        |
//+------------------------------------------------------------------+
void ProcessarTrianguloAscendente(double lote, long magic)
{
   // processa no maximo uma vez por candle novo (evita reavaliar o mesmo
   // rompimento a cada tick enquanto o candle atual ainda esta formando)
   static datetime ultimoCandleAscendente = 0;
   datetime candleAtualAscendente = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(candleAtualAscendente == ultimoCandleAscendente)
      return;
   ultimoCandleAscendente = candleAtualAscendente;

   // ja existe posicao aberta ou ordem pendente para esse magic? nao duplica
   if(ExistePosicaoAberta(magic) || ExisteOrdemPendente(magic))
      return;

   // 1) Tenta (re)detectar a figura enquanto nao houver uma valida ativa
   if(!g_trianguloAscendenteAtivo)
   {
      if(DetectarTrianguloAscendente(_Symbol, PERIOD_CURRENT, InpBarrasAnaliseTA, g_trianguloAscendente))
      {
         g_trianguloAscendenteAtivo = true;
         PrintFormat("Triangulo Ascendente detectado | Resistencia=%.5f | FundoBase=%.5f | Amplitude=%.5f",
                     g_trianguloAscendente.resistenciaHorizontal,
                     g_trianguloAscendente.fundoMaisBaixo,
                     g_trianguloAscendente.amplitudeVertical);
      }
      else
      {
         return; // nenhuma figura valida no momento
      }
   }

   // 2) Com figura ativa, verifica rompimento a cada fechamento de candle
   SRompimentoTrianguloAscendente rompimento;
   if(VerificarRompimentoTrianguloAscendente(_Symbol, PERIOD_CURRENT, g_trianguloAscendente, rompimento))
   {
      if(!ExisteOrdemNoPreco(rompimento.precoEntrada, magic))
      {
         if(rompimento.tipo == ROMPIMENTO_RESISTENCIA_ALTA)
         {
            AbrirOrdemPendenteCompraStop(rompimento.precoEntrada, lote, rompimento.precoStop,
                                          rompimento.precoAlvo, magic, "TrianguloAscendente-Compra");
         }
         else if(rompimento.tipo == ROMPIMENTO_LTA_BAIXA)
         {
            AbrirOrdemPendenteVendaStop(rompimento.precoEntrada, lote, rompimento.precoStop,
                                         rompimento.precoAlvo, magic, "TrianguloAscendente-Venda");
         }
      }

      // Apos o rompimento, a figura se encerra: reseta para permitir nova deteccao
      g_trianguloAscendenteAtivo = false;
   }
}

#endif
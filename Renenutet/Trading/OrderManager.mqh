//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __ORDER_MANAGER_MQH__
#define __ORDER_MANAGER_MQH__

#include <Trade\Trade.mqh>

bool ExistePosicaoAberta(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Conta quantas posicoes abertas existem para o simbolo/magic dado |
//+------------------------------------------------------------------+
int ContarPosicoes(long magic)
{
   int total = 0;

   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            total++;
         }
      }
   }

   return total;
}

//+------------------------------------------------------------------+
//| Verifica se existe posicao de COMPRA aberta para o magic dado    |
//+------------------------------------------------------------------+
bool ExisteCompra(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Verifica se existe posicao de VENDA aberta para o magic dado     |
//+------------------------------------------------------------------+
bool ExisteVenda(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Retorna o ticket da primeira posicao encontrada para o magic     |
//| Retorna 0 se nao encontrar nenhuma                                |
//+------------------------------------------------------------------+
ulong ObterTicket(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            return ticket;
         }
      }
   }

   return 0;
}

//+------------------------------------------------------------------+
//| Retorna o preco de entrada da posicao (0.0 se nao encontrar)     |
//+------------------------------------------------------------------+
double ObterPrecoEntrada(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            return PositionGetDouble(POSITION_PRICE_OPEN);
         }
      }
   }

   return 0.0;
}

//+------------------------------------------------------------------+
//| Retorna o Stop Loss da posicao (0.0 se nao encontrar)            |
//+------------------------------------------------------------------+
double ObterStopLoss(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            return PositionGetDouble(POSITION_SL);
         }
      }
   }

   return 0.0;
}

//+------------------------------------------------------------------+
//| Retorna o Take Profit da posicao (0.0 se nao encontrar)          |
//+------------------------------------------------------------------+
double ObterTakeProfit(long magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic)
         {
            return PositionGetDouble(POSITION_TP);
         }
      }
   }

   return 0.0;
}

//+------------------------------------------------------------------+
//| Fecha a posicao pelo ticket informado                            |
//+------------------------------------------------------------------+
bool FecharPosicao(long ticket)
{
   if(!PositionSelectByTicket((ulong)ticket))
   {
      Print("FecharPosicao: posicao com ticket ", ticket, " nao encontrada.");
      return false;
   }

   CTrade trade;
   trade.SetExpertMagicNumber((long)PositionGetInteger(POSITION_MAGIC));

   if(!trade.PositionClose((ulong)ticket))
   {
      Print("FecharPosicao: falha ao fechar ticket ", ticket,
            " - erro ", GetLastError(), " (retcode ", trade.ResultRetcode(), ")");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Abre uma ordem de COMPRA a mercado.                               |
//| Retorna o ticket da posicao criada, ou 0 em caso de falha.        |
//+------------------------------------------------------------------+
ulong AbrirOrdemCompra(double lote, long magic, double sl = 0.0, double tp = 0.0, string comentario = "")
{
   CTrade trade;
   trade.SetExpertMagicNumber(magic);

   double precoAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(!trade.Buy(lote, _Symbol, precoAsk, sl, tp, comentario))
   {
      Print("AbrirOrdemCompra: falha ao enviar ordem de compra - erro ", GetLastError(),
            " (retcode ", trade.ResultRetcode(), ")");
      return 0;
   }

   // Em contas de hedge, o ticket da posicao criada coincide com o ticket
   // da ordem que a originou.
   return trade.ResultOrder();
}

//+------------------------------------------------------------------+
//| Abre uma ordem de VENDA a mercado, com SL e TP definidos.         |
//| Retorna o ticket da posicao criada, ou 0 em caso de falha.        |
//+------------------------------------------------------------------+
ulong AbrirOrdemVenda(double lote, double sl, double tp, long magic, string comentario = "")
{
   CTrade trade;
   trade.SetExpertMagicNumber(magic);

   double precoBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(!trade.Sell(lote, _Symbol, precoBid, sl, tp, comentario))
   {
      Print("AbrirOrdemVenda: falha ao enviar ordem de venda - erro ", GetLastError(),
            " (retcode ", trade.ResultRetcode(), ")");
      return 0;
   }

   // Em contas de hedge, o ticket da posicao criada coincide com o ticket
   // da ordem que a originou.
   return trade.ResultOrder();
}

//+------------------------------------------------------------------+
//| Verifica se ja existe uma ordem pendente OU posicao aberta no    |
//| mesmo preco informado (mesmo simbolo/magic), evitando duplicar   |
//| a mesma entrada.                                                  |
//| tolerancia : distancia maxima (em pontos do simbolo) para        |
//|              considerar "o mesmo preco". Default = 1 tick.        |
//+------------------------------------------------------------------+
bool ExisteOrdemNoPreco(double preco, long magic, double tolerancia = -1.0)
{
   if(tolerancia < 0.0)
   {
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      tolerancia = (tickSize > 0.0) ? tickSize : _Point;
   }

   // Ordens pendentes
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);

      if(OrderSelect(ticket))
      {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_MAGIC) == magic &&
            MathAbs(OrderGetDouble(ORDER_PRICE_OPEN) - preco) <= tolerancia)
         {
            return true;
         }
      }
   }

   // Posicoes ja abertas
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magic &&
            MathAbs(PositionGetDouble(POSITION_PRICE_OPEN) - preco) <= tolerancia)
         {
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Cria uma ordem pendente BUY LIMIT (compra abaixo do preco atual).|
//| Retorna o ticket da ordem pendente, ou 0 em caso de falha.       |
//+------------------------------------------------------------------+
ulong AbrirOrdemPendenteCompra(double preco, double lote, double tp, long magic, string comentario = "")
{
   CTrade trade;
   trade.SetExpertMagicNumber(magic);

   if(!trade.BuyLimit(lote, preco, _Symbol, 0.0, tp, ORDER_TIME_GTC, 0, comentario))
   {
      Print("AbrirOrdemPendenteCompra: falha ao enviar Buy Limit - erro ", GetLastError(),
            " (retcode ", trade.ResultRetcode(), ")");
      return 0;
   }

   return trade.ResultOrder();
}

//+------------------------------------------------------------------+
//| Cria uma ordem pendente BUY STOP (compra acima do preco atual,   |
//| usada para confirmar rompimento de resistencia). SL e TP juntos. |
//| Retorna o ticket da ordem pendente, ou 0 em caso de falha.       |
//+------------------------------------------------------------------+
ulong AbrirOrdemPendenteCompraStop(double preco, double lote, double sl, double tp, long magic, string comentario = "")
{
   CTrade trade;
   trade.SetExpertMagicNumber(magic);

   if(!trade.BuyStop(lote, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario))
   {
      Print("AbrirOrdemPendenteCompraStop: falha ao enviar Buy Stop - erro ", GetLastError(),
            " (retcode ", trade.ResultRetcode(), ")");
      return 0;
   }

   return trade.ResultOrder();
}

//+------------------------------------------------------------------+
//| Cria uma ordem pendente SELL STOP (venda abaixo do preco atual,  |
//| usada para confirmar rompimento de suporte). SL e TP juntos.     |
//| Retorna o ticket da ordem pendente, ou 0 em caso de falha.       |
//+------------------------------------------------------------------+
ulong AbrirOrdemPendenteVendaStop(double preco, double lote, double sl, double tp, long magic, string comentario = "")
{
   CTrade trade;
   trade.SetExpertMagicNumber(magic);

   if(!trade.SellStop(lote, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario))
   {
      Print("AbrirOrdemPendenteVendaStop: falha ao enviar Sell Stop - erro ", GetLastError(),
            " (retcode ", trade.ResultRetcode(), ")");
      return 0;
   }

   return trade.ResultOrder();
}

//+------------------------------------------------------------------+
//| Verifica se existe ordem pendente (qualquer tipo) para o magic   |
//| dado, independente do preco. Usado para nao empilhar varias      |
//| ordens do mesmo padrao enquanto uma ja esta pendente.            |
//+------------------------------------------------------------------+
bool ExisteOrdemPendente(long magic)
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);

      if(OrderSelect(ticket))
      {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_MAGIC) == magic)
         {
            return true;
         }
      }
   }

   return false;
}

#endif
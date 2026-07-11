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
#include "OrderManager.mqh"
#include "RiskManager.mqh"
#include "PositionManager.mqh"

void VerificarGatilhoEntrada(SConfigEntrada &config);
void ProcessarComprasPendentes(long magic);           // detecta compra executada
void CriarOrdensVendaMultiplas(double precoEntradaCompra, SConfigVenda &vendas[], long magic);

#endif
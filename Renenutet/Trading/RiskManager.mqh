//+------------------------------------------------------------------+
//|                                                 RiskManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include "../Core/Utils.mqh"
#include "../Core/Structs.mqh"

//+------------------------------------------------------------------+
//| Calcula o Stop Loss a partir de um percentual sobre o preco de   |
//| entrada, respeitando a direcao da ordem:                         |
//|   - ORDER_TYPE_BUY : SL fica ABAIXO do preco de entrada          |
//|   - ORDER_TYPE_SELL: SL fica ACIMA  do preco de entrada          |
//+------------------------------------------------------------------+
double CalcularStopLoss(double precoEntrada, double slPercent, ENUM_ORDER_TYPE tipo)
{
   if(precoEntrada <= 0.0)
   {
      Print("CalcularStopLoss: precoEntrada invalido (", precoEntrada, ").");
      return 0.0;
   }

   if(tipo == ORDER_TYPE_BUY)
      return PrecoAPartirDePercentual(precoEntrada, slPercent, false);

   if(tipo == ORDER_TYPE_SELL)
      return PrecoAPartirDePercentual(precoEntrada, slPercent, true);

   Print("CalcularStopLoss: tipo de ordem nao suportado (", EnumToString(tipo), ").");
   return 0.0;
}

//+------------------------------------------------------------------+
//| Calcula o Take Profit a partir de um percentual sobre o preco de |
//| entrada, respeitando a direcao da ordem:                         |
//|   - ORDER_TYPE_BUY : TP fica ACIMA  do preco de entrada          |
//|   - ORDER_TYPE_SELL: TP fica ABAIXO do preco de entrada          |
//+------------------------------------------------------------------+
double CalcularTakeProfit(double precoEntrada, double tpPercent, ENUM_ORDER_TYPE tipo)
{
   if(precoEntrada <= 0.0)
   {
      Print("CalcularTakeProfit: precoEntrada invalido (", precoEntrada, ").");
      return 0.0;
   }

   if(tipo == ORDER_TYPE_BUY)
      return PrecoAPartirDePercentual(precoEntrada, tpPercent, true);

   if(tipo == ORDER_TYPE_SELL)
      return PrecoAPartirDePercentual(precoEntrada, tpPercent, false);

   Print("CalcularTakeProfit: tipo de ordem nao suportado (", EnumToString(tipo), ").");
   return 0.0;
}

//+------------------------------------------------------------------+
//| Consolida os parametros operacionais de risco, calculando o      |
//| lote maximo permitido a partir de um percentual do saldo da      |
//| conta.                                                             |
//|                                                                    |
//| percentualAlocacao : % do saldo a ser usado como capital de risco |
//|                       da operacao (ex: 10.0 = 10%)                |
//| tipo                : direcao da futura ordem (BUY/SELL), usada   |
//|                       para calcular a margem exigida por lote      |
//| parametros          : struct preenchida com o resultado           |
//|                       (passada por referencia)                    |
//|                                                                    |
//| Retorna true se conseguiu calcular os parametros (mesmo que       |
//| podeOperar venha false), e false apenas em falha tecnica (ex:      |
//| corretora nao retornou a margem exigida).                         |
//+------------------------------------------------------------------+
bool ObterParametrosOperacionais(double percentualAlocacao, ENUM_ORDER_TYPE tipo, SParametrosOperacionais &parametros)
{
   parametros.saldoDisponivel = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   parametros.capitalAlocado  = parametros.saldoDisponivel * (percentualAlocacao / 100.0);
   parametros.loteMaximo      = 0.0;
   parametros.podeOperar      = false;

   if(parametros.capitalAlocado <= 0.0)
   {
      Print("ObterParametrosOperacionais: capital alocado invalido (", parametros.capitalAlocado, ").");
      return true; // calculo tecnico ok, mas nao ha condicao de operar
   }

   double precoReferencia = (tipo == ORDER_TYPE_SELL)
                             ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                             : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double margemPorLote = 0.0;

   if(!OrderCalcMargin(tipo, _Symbol, 1.0, precoReferencia, margemPorLote) || margemPorLote <= 0.0)
   {
      Print("ObterParametrosOperacionais: falha ao calcular margem por lote - erro ", GetLastError(), ".");
      return false;
   }

   double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double volumeMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volumeMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   if(volumeStep <= 0.0)
      volumeStep = 0.01;

   double loteBruto = parametros.capitalAlocado / margemPorLote;
   double loteAjustado = MathFloor(loteBruto / volumeStep) * volumeStep;

   int digitosVolume = (int)MathRound(-MathLog10(volumeStep));
   loteAjustado = NormalizeDouble(loteAjustado, MathMax(digitosVolume, 0));

   if(loteAjustado > volumeMax)
      loteAjustado = volumeMax;

   if(loteAjustado < volumeMin)
      loteAjustado = 0.0;

   parametros.loteMaximo = loteAjustado;

   parametros.podeOperar = (parametros.loteMaximo >= volumeMin) &&
                            (parametros.saldoDisponivel >= margemPorLote * parametros.loteMaximo);

   return true;
}

#endif
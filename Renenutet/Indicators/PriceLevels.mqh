//+------------------------------------------------------------------+
//|                                                  PriceLevels.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __PRICELEVELS_MQH__
#define __PRICELEVELS_MQH__

#include "../Core/Enums.mqh"
#include "../Core/Structs.mqh"
#include "../Core/Constants.mqh"
#include "../Core/Utils.mqh"
#include "../Core/ChartUtils.mqh"

//+------------------------------------------------------------------+
//| Inicializar uma média.                                           |
//+------------------------------------------------------------------+
bool InicializarNivelPreco(
   ResistenciaSuporte &rs)
{
   AtualizarNivelPreco(rs);
   return true;
}

bool AtualizarNivelPreco(ResistenciaSuporte &rs)
{

   ValorSR valorSuporte = rs.suporte;
   ValorSR valorResistencia = rs.resistencia;

   valorSuporte.nome = "MIN_" + rs.nome;
   valorSuporte.cor = clrRed;
   valorSuporte.valor = ObterMenorMinima(rs.min);
   
   if(rs.exibirObjeto) {
      DrawLine(valorSuporte.nome, valorSuporte.cor, valorSuporte.style, valorSuporte.valor);
   }

   valorResistencia.nome = "MAX_" + rs.nome;
   valorResistencia.cor = clrGreen;
   valorResistencia.valor = ObterMaiorMaxima(rs.max);
   
   if(rs.exibirObjeto) {
      DrawLine(valorResistencia.nome, valorResistencia.cor, valorResistencia.style, valorResistencia.valor);
   }
   
   rs.suporte = valorSuporte;
   rs.resistencia = valorResistencia;
   
   return true;
}

double ObterNivelPreco(TipoNivelPreco tipo, int periodo)
{
   double valores[];

   int lidos;

   if(tipo == HIGH)
      lidos = CopyHigh(_Symbol, _Period, 1, periodo, valores);
   else
      lidos = CopyLow(_Symbol, _Period, 1, periodo, valores);

   if(lidos <= 0)
      return EMPTY_VALUE;

   double nivel = valores[0];

   for(int i = 1; i < ArraySize(valores); i++)
   {
      if(tipo == HIGH)
      {
         if(valores[i] > nivel)
            nivel = valores[i];
      }
      else
      {
         if(valores[i] < nivel)
            nivel = valores[i];
      }
   }

   return nivel;
}

double ObterMaiorMaxima(int periodo)
{
   return ObterNivelPreco(HIGH, periodo);
}

double ObterMenorMinima(int periodo)
{
   return ObterNivelPreco(LOW, periodo);
}

//+------------------------------------------------------------------+
//| Imprimir uma média.                                              |
//+------------------------------------------------------------------+
void PrintPriceLevel(ResistenciaSuporte &rs)
{
   PrintFormat(
      "%s | MIN=%.5f (%d) | MIN=%.5f (%d)",
      rs.nome,
      rs.suporte.valor,
      rs.min,
      rs.resistencia.valor,
      rs.max
   );
}


#endif
//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#ifndef __PRICELEVES_MQH__
#define __PRICELEVES_MQH__

#include "../Core/Enums.mqh"
#include "../Core/Structs.mqh"
#include "../Core/Constants.mqh"
#include "../Core/Utils.mqh"

//+------------------------------------------------------------------+
//| Inicializar uma média.                                           |
//+------------------------------------------------------------------+
bool InicializarNivelPreco(
   ResistenciaSuporte &rs)
{
   /*
   rs.suporte.nome = "MIN_" + rs.nome;
   rs.suporte.cor = clrRed;
   rs.suporte.valor = ObterMenorMinima(rs.min);

   rs.resistencia.nome = "MAX_" + rs.nome;
   rs.resistencia.cor = clrGreen;
   rs.resistencia.valor = ObterMaiorMaxima(rs.max);
   */
   AtualizarNivelPreco(rs);

   /*
   ENUM_MA_METHOD metodo =
      media.tipo == EMA ? MODE_EMA : MODE_SMA;

   media.handle =
      iMA(
         _Symbol,
         PERIOD_CURRENT,
         media.periodo,
         0,
         metodo,
         PRICE_CLOSE);

   return (media.handle != INVALID_HANDLE);
   */
   return true;
}

bool AtualizarNivelPreco(ResistenciaSuporte &rs)
{
   rs.suporte.nome = "MIN_" + rs.nome;
   rs.suporte.cor = clrRed;
   rs.suporte.valor = ObterMenorMinima(rs.min);

   rs.resistencia.nome = "MAX_" + rs.nome;
   rs.resistencia.cor = clrGreen;
   rs.resistencia.valor = ObterMaiorMaxima(rs.max);
   
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
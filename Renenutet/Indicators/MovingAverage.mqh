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
#ifndef __MOVINGAVERAGE_MQH__
#define __MOVINGAVERAGE_MQH__

#include "../Core/Enums.mqh"
#include "../Core/Structs.mqh"
#include "../Core/Constants.mqh"
#include "../Core/Utils.mqh"

//+------------------------------------------------------------------+
//| Inicializar uma média.                                           |
//+------------------------------------------------------------------+
bool InicializarMedia(
   MediaMovel &media)
{
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
}

//+------------------------------------------------------------------+
//| Analisar uma média.                                              |
//| Esse será basicamente o seu ObterTrend(), adaptado para          |
//| receber uma MediaMovel.                                          |
//+------------------------------------------------------------------+
bool AtualizarMedia(
   MediaMovel &media,
   int candles = 20)
{
   double valores[];

   ArrayResize(valores,candles);
   ArraySetAsSeries(valores,true);

   if(CopyBuffer(media.handle,0,0,candles,valores)!=candles)
      return false;

   IndicadorTrend trend;

   trend.valorAtual=valores[0];
   trend.valorAnterior=valores[1];

   trend.subindo=valores[0]>valores[1];

   if(candles>=3)
   {
      trend.acelerando=
         MathAbs(valores[0]-valores[1])>
         MathAbs(valores[1]-valores[2]);
   }

   int score=0;
   int scoreMaximo=0;

   for(int i=0;i<candles-1;i++)
   {
      int peso=candles-1-i;

      scoreMaximo+=peso;

      if(valores[i]>valores[i+1])
         score+=peso;
      else
      if(valores[i]<valores[i+1])
         score-=peso;
   }

   trend.score=score;

   trend.delta=valores[0]-valores[candles-1];

   trend.slope=trend.delta/(candles-1);

   trend.forca=(100.0*score)/scoreMaximo;

   if(trend.forca>=80)
      trend.tendencia=FORTE_ALTA;
   else
   if(trend.forca>=30)
      trend.tendencia=ALTA;
   else
   if(trend.forca<=-80)
      trend.tendencia=FORTE_BAIXA;
   else
   if(trend.forca<=-30)
      trend.tendencia=BAIXA;
   else
      trend.tendencia=LATERAL;

   media.trend=trend;

   return true;
}

//+------------------------------------------------------------------+
//| Imprimir uma média.                                              |
//+------------------------------------------------------------------+
void PrintMedia(MediaMovel &media)
{
   PrintFormat(
      "%s%d %.5f | Score=%d | Slope=%.5f | Força=%.2f | %s",
      TipoMediaToString(media.tipo),
      media.periodo,
      media.trend.valorAtual,
      media.trend.score,
      media.trend.slope,
      media.trend.forca,
      TendenciaToString(media.trend.tendencia)
   );
}

#endif
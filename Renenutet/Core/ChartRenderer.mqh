//+------------------------------------------------------------------+
//|                                                ChartRenderer.mqh |
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
#ifndef __CHART_RENDERER_MQH__
#define __CHART_RENDERER_MQH__

void ChartTemplate() 
{
   ChartSetInteger(NULL, CHART_MODE, CHART_CANDLES);           // Define o gráfico para o modo de velas (CHART_BARS para barras, CHART_LINE para linha)
   ChartSetInteger(0, CHART_SHOW_GRID, false);                 // Remove a grade do gráfico
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);       // Define o fundo do gráfico como preto
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrLightBlue);  // Define a cor do corpo das velas de alta como verde
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrLightBlue);     // Define a cor do contorno das velas de alta como verde
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrPlum);       // Define a cor do corpo das velas de baixa como vermelho
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrPlum);        // Define a cor do contorno das velas de baixa como vermelho
}

#endif
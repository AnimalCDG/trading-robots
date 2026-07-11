//+------------------------------------------------------------------+
//|                                                   ChartUtils.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __CHART_UTILS_MQH__
#define __CHART_UTILS_MQH__

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

void DrawLine(
   string name_line, 
   color color_type,
   int drawing_styles,
   double preco)
{
   // Se a linha não existir, cria
   if(ObjectFind(0, name_line) == -1)
   {
      ObjectCreate(0, name_line, OBJ_HLINE, 0, 0, preco);
      ObjectSetInteger(0, name_line, OBJPROP_COLOR, color_type);
      ObjectSetInteger(0, name_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name_line, OBJPROP_STYLE, drawing_styles);
   }
   else
   {
      // Atualiza preço e cor
      ObjectSetDouble(0, name_line, OBJPROP_PRICE, preco);
      ObjectSetInteger(0, name_line, OBJPROP_COLOR, color_type);
   }
}

#endif
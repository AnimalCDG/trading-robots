//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade trade;

double            _sma                 = 0;
int               handleSMA50          = 0;

double            _ema                 = 0;
int               handleEMA20          = 0;

struct PosicaoTrade
{
   ulong  ticket;
   double precoEntrada;
   double stopLoss;
   double takeProfit;
};

enum Tendencia
{
   FORTE_BAIXA,
   BAIXA,
   LATERAL,
   ALTA,
   FORTE_ALTA,
   ERRO
};

struct IndicadorTrend
{
   double valorAtual;
   double valorAnterior;
   double slope;
   int score;
   Tendencia tendencia;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   ChartTemplate();   
   handleSMA50 = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
   handleEMA20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{


}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);   
   _sma = LerMedia(handleSMA50);
   _ema = LerMedia(handleEMA20);
   /*
   Tendencia _tendencia20 = ObterTendencia(handleSMA50, 6);
   Tendencia _tendencia50 = ObterTendencia(handleEMA20, 6);
   //Print("SMA20: ", sma20, " T[", _tendencia20, "] | EMA50: ", ema50, " T[", _tendencia50, "]");
   PrintFormat(
      "SMA50: %.5f T[%s] | EMA20: %.5f T[%s]",
      _sma,
      TendenciaToString(ObterTendencia(handleSMA50)),
      _ema,
      TendenciaToString(ObterTendencia(handleEMA20))
   );
   */
   IndicadorTrend ema20 = ObterTrend(handleEMA20, 20);
   PrintFormat(
      "EMA20 %.5f | Score=%d | Slope=%.5f | %s",
      ema20.valorAtual,
      ema20.score,
      ema20.slope,
      TendenciaToString(ema20.tendencia)
   );
   /*
   IndicadorTrend sma50 = ObterTrend(handleSMA50, 50);
   PrintFormat(
      "SMA50 %.5f | Score=%d | Slope=%.5f | %s",
      sma50.valorAtual,
      sma50.score,
      sma50.slope,
      TendenciaToString(sma50.tendencia)
   );
   */
}
//+------------------------------------------------------------------+

void ChartTemplate() 
{
   ChartSetInteger(NULL, CHART_MODE, CHART_CANDLES);        // Define o gráfico para o modo de velas (CHART_BARS para barras, CHART_LINE para linha)
   ChartSetInteger(0, CHART_SHOW_GRID, false);              // Remove a grade do gráfico
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);    // Define o fundo do gráfico como preto
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrLightBlue);   // Define a cor do corpo das velas de alta como verde
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrLightBlue);      // Define a cor do contorno das velas de alta como verde
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrPlum);     // Define a cor do corpo das velas de baixa como vermelho
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrPlum);      // Define a cor do contorno das velas de baixa como vermelho
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

double LerMedia(int handle)
{
   double buffer[];

   if(CopyBuffer(handle, 0, 0, 3, buffer) <= 0)
      return EMPTY_VALUE;
   
   //for(int i = 0; i < buffer.Size(); i++)
   //{
   //   PrintFormat("media[%d] = %.5f", i, buffer[i]);
   //}

   return buffer[0];
}

Tendencia ObterTendencia(int handle, int candles = 3)
{
   double media[];

   ArrayResize(media, candles);

   if(CopyBuffer(handle, 0, 0, candles, media) != candles)
      return ERRO;
      
   int score = 0;

   for(int i = 0; i < candles - 1; i++)
   {
      if(media[i] > media[i + 1])
         score++;
      else if(media[i] < media[i + 1])
         score--;
   }

   int maxScore = candles - 1;

   if(score >= maxScore - 1)
      return FORTE_ALTA;

   if(score > 0)
      return ALTA;

   if(score <= -(maxScore - 1))
      return FORTE_BAIXA;

   if(score < 0)
      return BAIXA;

   return LATERAL;
}

string TendenciaToString(Tendencia t)
{
   switch(t)
   {
      case FORTE_BAIXA: return "↓↓ Forte Baixa";
      case BAIXA:       return "↓ Baixa";
      case LATERAL:     return "→ Lateral";
      case ALTA:        return "↑ Alta";
      case FORTE_ALTA:  return "↑↑ Forte Alta";
      case ERRO:        return "Erro";
   }

   return "Desconhecida";
}

IndicadorTrend ObterTrend(int handle, int candles = 6)
{
   IndicadorTrend trend;

   trend.valorAtual    = EMPTY_VALUE;
   trend.valorAnterior = EMPTY_VALUE;
   trend.slope         = 0;
   trend.score         = 0;
   trend.tendencia     = ERRO;

   double media[];

   ArrayResize(media, candles);

   if(CopyBuffer(handle, 0, 0, candles, media) != candles)
      return trend;
      
   Print("----------------------------");

   for(int i = 0; i < candles; i++)
   {
      PrintFormat(
         "media[%02d] = %.5f",
         i,
         media[i]
      );
   }

   trend.valorAtual = media[0];
   trend.valorAnterior = media[1];

   int score = 0;

   for(int i = 0; i < candles - 1; i++)
   {
      if(media[i] > media[i+1])
         score++;
      else if(media[i] < media[i+1])
         score--;
   }

   trend.score = score;

   trend.slope = media[0] - media[candles-1];

   int maxScore = candles - 1;

   if(score >= maxScore - 1)
      trend.tendencia = FORTE_ALTA;
   else
   if(score > 0)
      trend.tendencia = ALTA;
   else
   if(score <= -(maxScore - 1))
      trend.tendencia = FORTE_BAIXA;
   else
   if(score < 0)
      trend.tendencia = BAIXA;
   else
      trend.tendencia = LATERAL;

   return trend;
}
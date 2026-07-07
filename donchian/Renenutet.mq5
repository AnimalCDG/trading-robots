//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Indicadores.mqh>

HandlesIndicadores handles;

CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   ChartTemplate();   
   handles.ema20  = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_EMA,PRICE_CLOSE);
   //handles.ema50  = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
   //handles.ema100 = iMA(_Symbol,PERIOD_CURRENT,100,0,MODE_EMA,PRICE_CLOSE);
   //handles.ema200 = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_CLOSE);
   
   //handles.sma20  = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
   //handles.sma50  = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
   //handles.sma100 = iMA(_Symbol,PERIOD_CURRENT,100,0,MODE_SMA,PRICE_CLOSE);
   //handles.sma200 = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_SMA,PRICE_CLOSE);
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
   //Print("Time atual: ", TimeToString(iTime(_Symbol, PERIOD_CURRENT, 0)));
   
   Indicadores indicadores = ObterIndicadores(handles);

   TendenciaMercado mercado =
      AvaliarMercado(
         indicadores.ema20,
         indicadores.sma50);
   
   if(mercado==MERCADO_FORTE_ALTA)
   {
      Print("Comprar");
   }
   
   if(mercado==MERCADO_FORTE_BAIXA)
   {
      Print("Vender");
   }
   
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

IndicadorTrend ObterTrend(int handle,int candles=20)
{
   IndicadorTrend trend;

   trend.valorAtual=EMPTY_VALUE;
   trend.valorAnterior=EMPTY_VALUE;

   trend.delta=0;
   trend.slope=0;

   trend.score=0;
   trend.forca=0;

   trend.subindo=false;
   trend.acelerando=false;

   trend.tendencia=ERRO;

   double media[];

   ArrayResize(media,candles);
   ArraySetAsSeries(media,true);

   if(CopyBuffer(handle,0,0,candles,media)!=candles)
      return trend;

   trend.valorAtual=media[0];
   trend.valorAnterior=media[1];

   trend.subindo=(media[0]>media[1]);

   if(candles>=3)
   {
      trend.acelerando=
         MathAbs(media[0]-media[1])>
         MathAbs(media[1]-media[2]);
   }

   int score=0;
   int scoreMaximo=0;

   for(int i=0;i<candles-1;i++)
   {
      int peso=candles-1-i;

      scoreMaximo+=peso;

      if(media[i]>media[i+1])
         score+=peso;
      else
      if(media[i]<media[i+1])
         score-=peso;
   }

   trend.score=score;

   trend.delta=media[0]-media[candles-1];

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

   return trend;
}

Indicadores ObterIndicadores(HandlesIndicadores &handles)
{
   Indicadores ind;

   ind.ema20  = ObterTrend(handles.ema20,20);
   ind.ema50  = ObterTrend(handles.ema50,20);
   ind.ema100 = ObterTrend(handles.ema100,20);
   ind.ema200 = ObterTrend(handles.ema200,20);

   ind.sma20  = ObterTrend(handles.sma20,20);
   ind.sma50  = ObterTrend(handles.sma50,20);
   ind.sma100 = ObterTrend(handles.sma100,20);
   ind.sma200 = ObterTrend(handles.sma200,20);

   return ind;
}

TendenciaMercado AvaliarMercado(
   IndicadorTrend &ema20,
   IndicadorTrend &sma50)
{
   int score=0;

   const double LIMIAR=0.00005;

   //-----------------------------
   // EMA20 acima SMA50
   //-----------------------------

   if(ema20.valorAtual>sma50.valorAtual)
      score+=40;
   else
      score-=40;

   //-----------------------------
   // EMA20 inclinada
   //-----------------------------

   if(ema20.slope>LIMIAR)
      score+=30;
   else
   if(ema20.slope<-LIMIAR)
      score-=30;

   //-----------------------------
   // SMA50 inclinada
   //-----------------------------

   if(sma50.slope>LIMIAR)
      score+=20;
   else
   if(sma50.slope<-LIMIAR)
      score-=20;

   //-----------------------------
   // força EMA20
   //-----------------------------

   if(ema20.forca>70)
      score+=10;
   else
   if(ema20.forca<-70)
      score-=10;

   //-----------------------------

   if(score>=80)
      return MERCADO_FORTE_ALTA;

   if(score>=30)
      return MERCADO_ALTA;

   if(score<=-80)
      return MERCADO_FORTE_BAIXA;

   if(score<=-30)
      return MERCADO_BAIXA;

   return MERCADO_LATERAL;
}
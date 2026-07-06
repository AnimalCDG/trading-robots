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

enum TendenciaMercado
{
   MERCADO_FORTE_BAIXA,
   MERCADO_BAIXA,
   MERCADO_LATERAL,
   MERCADO_ALTA,
   MERCADO_FORTE_ALTA
};

struct IndicadorTrend
{
   double      valorAtual;
   double      valorAnterior;
   double      delta;
   double      slope;
   int         score;
   double      forca;   // -100% a +100%
   bool        subindo;
   bool        acelerando;
   Tendencia   tendencia;
};

double            _sma                 = 0;
int               handleSMA50          = 0;

double            _ema                 = 0;
int               handleEMA20          = 0;

int               InpMagicMethodOne    = 10001; /* Número mágico */

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
   Print("Time atual: ", TimeToString(iTime(_Symbol, PERIOD_CURRENT, 0)));
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
      "EMA20 %.5f | Score=%d | Slope=%.5f | Delta=%.5f | Força=%.5f | %s",
      ema20.valorAtual,
      ema20.score,
      ema20.slope,
      ema20.delta,
      ema20.forca,
      TendenciaToString(ema20.tendencia)
   );
   
   IndicadorTrend sma50 = ObterTrend(handleSMA50, 50);
   PrintFormat(
      "SMA50 %.5f | Score=%d | Slope=%.5f | Delta=%.5f | Força=%.5f | %s",
      sma50.valorAtual,
      sma50.score,
      sma50.slope,
      sma50.delta,
      sma50.forca,
      TendenciaToString(sma50.tendencia)
   );
   
   NegociacaoMetodoUm(ema20, sma50);
   
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

IndicadorTrend ObterTrendOld(int handle, int candles = 6)
{
   IndicadorTrend trend;

   trend.valorAtual    = EMPTY_VALUE;
   trend.valorAnterior = EMPTY_VALUE;
   trend.delta         = 0;
   trend.slope         = 0;
   trend.score         = 0;
   trend.tendencia     = ERRO;

   double media[];

   ArrayResize(media, candles);
   ArraySetAsSeries(media, true);

   if(CopyBuffer(handle, 0, 0, candles, media) != candles)
      return trend;
   /*   
   Print("----------------------------");

   for(int i = 0; i < candles; i++)
   {
      PrintFormat(
         "media[%02d] = %.5f",
         i,
         media[i]
      );
   }
   */
   trend.valorAtual = media[0];
   trend.valorAnterior = media[1];

   int score = 0;
   int scoreMaximo = 0;
   
   for (int i = 0; i < candles - 1; i++)
   {
      scoreMaximo += (candles - i);
       int peso = candles - 1 - i; // mais recente = maior peso
   
       if (media[i] > media[i + 1])
           score += peso;
       else if (media[i] < media[i + 1])
           score -= peso;
   }
   
   /* INVERTIDO
   for (int i = 0; i < candles - 1; i++)
   {
      scoreMaximo += (candles - i);
       int peso = candles - 1 - i; // mais recente = maior peso
   
       if (media[i] < media[i + 1])
           score += peso;
       else if (media[i] > media[i + 1])
           score -= peso;
   }
   */
   trend.score = score;

   trend.delta = media[0] - media[candles-1];
   //trend.delta = media[candles - 1] - media[0]; //INVERTIDO

   trend.slope = trend.delta / (candles-1);
   
   trend.forca = (100.0 * score) / scoreMaximo;

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

IndicadorTrend ObterTrend(int handle, int candles = 20)
{
   IndicadorTrend trend;

   trend.valorAtual    = EMPTY_VALUE;
   trend.valorAnterior = EMPTY_VALUE;
   trend.delta         = 0;
   trend.slope         = 0;
   trend.score         = 0;
   trend.forca         = 0;
   trend.tendencia     = ERRO;
   trend.subindo       = false;
   trend.acelerando    = false;

   double media[];

   ArrayResize(media, candles);
   ArraySetAsSeries(media, true);

   if(CopyBuffer(handle, 0, 0, candles, media) != candles)
      return trend;

   trend.valorAtual    = media[0];
   trend.valorAnterior = media[1];

   trend.subindo = media[0] > media[1];

   if(candles >= 3)
      trend.acelerando =
         MathAbs(media[0]-media[1]) >
         MathAbs(media[1]-media[2]);

   int score = 0;
   int scoreMaximo = 0;

   for(int i=0;i<candles-1;i++)
   {
      int peso = candles-1-i;

      scoreMaximo += peso;

      if(media[i] > media[i+1])
         score += peso;
      else
      if(media[i] < media[i+1])
         score -= peso;
   }

   trend.score = score;

   trend.delta = media[0] - media[candles-1];

   trend.slope = trend.delta / (candles-1);

   trend.forca = (100.0 * score) / scoreMaximo;

   if(trend.forca >= 80)
      trend.tendencia = FORTE_ALTA;
   else
   if(trend.forca >= 30)
      trend.tendencia = ALTA;
   else
   if(trend.forca <= -80)
      trend.tendencia = FORTE_BAIXA;
   else
   if(trend.forca <= -30)
      trend.tendencia = BAIXA;
   else
      trend.tendencia = LATERAL;

   return trend;
}

TendenciaMercado AvaliarMercado(const IndicadorTrend &ema20, const IndicadorTrend &sma50)
{
   int score = 0;

   //-------------------------
   // EMA20 x SMA50
   //-------------------------
   if(ema20.valorAtual > sma50.valorAtual)
      score += 40;
   else
      score -= 40;

   //-------------------------
   // Inclinação EMA20
   //-------------------------
   const double LIMIAR = 0.00005;

   if(ema20.slope > LIMIAR)
      score += 30;
   else
   if(ema20.slope < -LIMIAR)
      score -= 30;

   //-------------------------
   // Inclinação SMA50
   //-------------------------
   if(sma50.slope > LIMIAR)
      score += 20;
   else
   if(sma50.slope < -LIMIAR)
      score -= 20;

   //-------------------------
   // Força da EMA20
   //-------------------------
   if(ema20.forca > 70)
      score += 10;
   else
   if(ema20.forca < -70)
      score -= 10;

   //-------------------------
   // Classificação
   //-------------------------
   if(score >= 80)
      return MERCADO_FORTE_ALTA;

   if(score >= 30)
      return MERCADO_ALTA;

   if(score <= -80)
      return MERCADO_FORTE_BAIXA;

   if(score <= -30)
      return MERCADO_BAIXA;

   return MERCADO_LATERAL;
}

void NegociacaoMetodoUm(const IndicadorTrend &ema20, const IndicadorTrend &sma50)
{
   double takeProfit = 0.0;
   //TESTE
      double takeProfit1 = 0.0;
      double takeProfit2 = 0.0;
      double takeProfit3 = 0.0;
   double gainTwoThirds = 0.0;
   double gainThreeThirds = 0.0;
   double stopLoss = 0.0;
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
   //Print("sma50.tendencia: ", sma50.tendencia, "ema20.tendencia: ", ema20.tendencia);
   if((ema20.tendencia == BAIXA && (sma50.tendencia == FORTE_ALTA || sma50.tendencia == ALTA)) && (ema20.valorAtual < sma50.valorAtual)) 
   {
      if(IsOrderOpen(InpMagicMethodOne) == false)
      {
         Print("OPERAR VENDIDO USANDO EMA20");
         stopLoss = bid + (bid * 0.02);
         takeProfit1 = bid - (bid * 0.0066);
         takeProfit2 = bid - (bid * 0.0133);
         takeProfit3 = bid - (bid * 0.0198);
         
         takeProfit = bid - (bid * 0.0066);
         PlaceOrder(ORDER_TYPE_SELL, 0.01, bid, stopLoss, takeProfit, InpMagicMethodOne, "Estratégia Método 01 1/3");
         
         takeProfit = bid - (bid * 0.0133);
         PlaceOrder(ORDER_TYPE_SELL, 0.01, bid, stopLoss, takeProfit, InpMagicMethodOne, "Estratégia Método 01 2/3");
         
         takeProfit = bid - (bid * 0.02);
         PlaceOrder(ORDER_TYPE_SELL, 0.01, bid, stopLoss, takeProfit, InpMagicMethodOne, "Estratégia Método 01 3/3");
         
         PrintFormat(
            "BID %.5f | SL=%.5f | TP1=%.5f | TP2=%.5f | TP3=%.5f",
            bid,
            stopLoss,
            takeProfit1,
            takeProfit2,
            takeProfit3
         );
      }
   }
   
   if(IsOrderOpen(InpMagicMethodOne) == true) 
   {
      //ApplyTrailingStop(InpMagicMethodOne, sma50.valorAtual);
   }   
   
   //Teste
   if(sma50.tendencia == 4) {
      //Print("OPERAR COMPRA USANDO SMA50");
   }
   
   //Teste
   if(sma50.valorAtual == ema20.valorAtual) {
      //Print("Operar");
   }
}

//+------------------------------------------------------+
//|  Função que verifica se já existe uma ordem aberta   |
//+------------------------------------------------------+
bool IsOrderOpen(int numberMagic)
{
   for (int i = 0; i < PositionsTotal(); i++)
   {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == numberMagic) // Verifica se já existe uma posição no ativo atual
      {
         return true; // Já há uma posição aberta, não devemos abrir outra
      }
   }
   return false; // Nenhuma posição aberta, pode abrir uma nova
}

//+------------------------------------------+
//|  Função para enviar a ordem ao mercado   |
//+------------------------------------------+
bool PlaceOrder(int type, double lotSize, double entryPrice, double stopLoss, double takeProfit, int numberMagic, string strategyType)
{
   
   double volume = lotSize; // Defina o volume da ordem

   double margemLivre = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double margemNecessaria = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL) * volume;
   
   if (margemLivre < margemNecessaria) 
   {
      Print("Margem insuficiente para abrir a ordem. Livre: ", margemLivre, " Necessária: ", margemNecessaria);
      return true;
   }

   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;                                    // Executar ordem de mercado
   request.type = type;                                                   // Compra ou Venda
   request.symbol = _Symbol;                                              // Pega o ativo atual
   request.volume = lotSize;                                              // Tamanho do lote
   request.price = entryPrice;//(type == ORDER_TYPE_BUY) ? Ask : Bid;     // Preço atual
   request.sl = NormalizeDouble(stopLoss, _Digits);                       // Define Stop Loss em PIPs
   request.tp = NormalizeDouble(takeProfit, _Digits);                     // Usamos TP fixo, pois não temos o Trailing Stop
   request.deviation = 10;
   request.magic = numberMagic;                                           // Diferenciar ordens
   //request.comment = strategyType+" ("+IntegerToString(numberMagic)+")";  // Para identificar
   request.comment = strategyType;  // Para identificar
   //request.type_filling = ORDER_FILLING_FOK;
   request.type_filling = ORDER_FILLING_IOC;
   request.type_time = ORDER_TIME_GTC;

   if (!OrderSend(request, result))
   {
       Print("Erro ao abrir ordem: ", result.comment);
       return true;
   }
   else
   {
       Print("Ordem criada | Price [", entryPrice,"]; SL [", stopLoss,"]; TP [", takeProfit,"]; ");
       return false;
   }
}

//+------------------------------------------+
//|  Função para aplicar o trailing stop     |
//+------------------------------------------+
void ApplyTrailingStop(int numberMagic, double newStopLoss)
{   
   if (PositionsTotal() == 0) return;
   
   for (int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);

      if (PositionSelectByTicket(ticket) && (PositionGetInteger(POSITION_MAGIC) == numberMagic))
      {         
         //ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         //double stopLoss = PositionGetDouble(POSITION_SL);
         //double newStopLoss = 0;
         //double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         //double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         //double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
                           
         ModifyStopLoss(ticket, newStopLoss);
      }
   }
}

//+------------------------------------------+
//|  Função para modificar o stop loss       |
//+------------------------------------------+
void ModifyStopLoss(ulong ticket, double newStopLoss)
{

   double currentSL = PositionGetDouble(POSITION_SL);

    // Evita enviar order se o SL é igual
    if(NormalizeDouble(currentSL, _Digits) == NormalizeDouble(newStopLoss, _Digits))
    {
        Print("SL já está no valor correto. Nenhuma modificação necessária.");
        return;
    }

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);

    request.action = TRADE_ACTION_SLTP;
    request.position = ticket;
    request.sl = NormalizeDouble(newStopLoss, _Digits);
    request.tp = PositionGetDouble(POSITION_TP);

    if (!OrderSend(request, result))
    {
        Print("Erro ao modificar Stop Loss: ", result.comment);
    }
}
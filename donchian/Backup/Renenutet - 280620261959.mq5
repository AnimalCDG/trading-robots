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

double            sma20                = 0;
int               handleSMA20          = 0;

int               InpMagicTP           = 2706262249;
double            g_maiorPreco         = 0.0;

double qtd3_7     = 0.03;
double qtd10_20   = 0.03;
double qtd20_55   = 0.03;
double            lots                    = 0.03;

double            minShort                = 0.0;
double            maxShort                = 0.0;
double            minShortPrevious        = 0.0;
double            maxShortPrevious        = 0.0;
bool              openShort               = false;
int               InpMagicShort           = 0307;

double            minMedium               = 0.0;
double            maxMedium               = 0.0;
bool              openMedium              = false;
int               InpMagicMedium          = 1020;

double            minLong                 = 0.0;
double            maxLong                 = 0.0;
bool              openLong                = false;
int               InpMagicLong            = 1020;

// INICIO 3 DE 7
double            askShortLast            = 0;
bool              block3_7                = false;
int               InpMagic3_7_1           = 030701; /* Número mágico */
int               InpMagic3_7_2           = 030702; /* Número mágico */
int               InpMagic3_7_3           = 030703; /* Número mágico */

double stop1_3_7  = 0.0;
double stop2_3_7  = 0.0;
double stop3_3_7  = 0.0;

double gain1_3_7  = 0.0;
double gain2_3_7  = 0.0;
double gain3_3_7  = 0.0;
//FIM 3 DE 7

// INICIO 10/20
double            min10_20                = 0.0;
double            max10_20                = 0.0;
bool              block10_20              = false;
int               InpMagic10_20           = 1020; /* Número mágico */

double stop1_10_20  = 0.0;
double stop2_10_20  = 0.0;
double stop3_10_20  = 0.0;

double gain1_10_20  = 0.0;
double gain2_10_20  = 0.0;
double gain3_10_20  = 0.0;
//FIM 10/20

// INICIO 20/55
double            min20_55                = 0.0;
double            max20_55                = 0.0;
bool              block20_55              = false;
int               InpMagic20_55           = 2055; /* Número mágico */

double stop1_20_55  = 0.0;
double stop2_20_55  = 0.0;
double stop3_20_55  = 0.0;

double gain1_20_55  = 0.0;
double gain2_20_55  = 0.0;
double gain3_20_55  = 0.0;
//FIM 20/22

struct PosicaoTrade
{
   ulong  ticket;
   double precoEntrada;
   double stopLoss;
   double takeProfit;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   ChartTemplate();
   /*
   maxShort = MaxHigh(3);   
   minShort = MinLow(7);
   DrawLine("max 3/7", clrGreen, STYLE_SOLID, maxShort);
   DrawLine("min 3/7", clrRed, STYLE_SOLID, minShort);
   
   maxMedium = MaxHigh(20);   
   minMedium = MinLow(10);
   DrawLine("max 10/20", clrGreen, STYLE_SOLID, maxMedium);
   DrawLine("min 10/20", clrRed, STYLE_SOLID, minMedium);
   
   maxLong = MaxHigh(55);   
   minLong = MinLow(20);
   DrawLine("max 20/55", clrGreen, STYLE_SOLID, maxLong);
   DrawLine("min 20/55", clrRed, STYLE_SOLID, minLong);
   */
   
   handleSMA20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
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
   double takeProfit = 0.0;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   TakeProfit();
   
   /*
   maxShort = MaxHigh(3);   
   minShort = MinLow(7);
   
   DrawLine("max 3/7", clrGreen, STYLE_SOLID, maxShort);
   DrawLine("min 3/7", clrRed, STYLE_SOLID, minShort);
   
   bool hasMaximumBrokenShort = ask >= maxShort ? true : false;
   bool hasMinimumBrokenShort = bid <= minShort ? true : false;
   */
   
   //------------
   /*
   maxMedium = MaxHigh(10);   
   minMedium = MinLow(20);
   
   DrawLine("max 10/20", clrGreen, STYLE_SOLID, maxMedium);
   DrawLine("min 10/20", clrRed, STYLE_SOLID, minMedium);
   */
   
   //------------
   /*
   maxLong = MaxHigh(20);   
   minLong = MinLow(55);
   
   DrawLine("max 20/55", clrGreen, STYLE_SOLID, maxLong);
   DrawLine("min 20/55", clrRed, STYLE_SOLID, minLong);  
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

void TakeProfit() 
{
   sma20 = LerMedia(handleSMA20);
   //Print("SMA(20): ", sma20);
   
   double takeProfit = 0.0;
   double askPrevius = 0.0;
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //if( IsOrderOpen(InpMagicShort) == true )
   //   return; // Já operou, não faz nada
      
   if( IsOrderExecutedToday(InpMagicTP, PERIOD_CURRENT) == true )
      return; // Já operou, não faz nada
   
   if(ask >= sma20)
   {
      if( IsOrderOpen(InpMagicTP) == false ) 
      {
         double marginFree = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
         double stopLoss = ask * (1.0 - 0.03);
         //double stopLoss = ask - (marginFree * 0.03);
         //double stopLoss = sma20;
         g_maiorPreco = PositionGetDouble(POSITION_PRICE_OPEN);
         PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, 0, InpMagicTP, "Estratégia 03/07");
         Print("SMA(20): ", sma20, " OPEN: ", ask, " MARGIN: ", marginFree, " SL: ", stopLoss);
      }
      else 
      {
         ApplyTrailingStop(InpMagicTP, sma20);
         /*
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(bid > g_maiorPreco)
         {
            g_maiorPreco = bid;
            ApplyTrailingStop(InpMagicTP, sma20);
            Print("Atualizar o SL: ", sma20);
         }
         */
      }
   }
}

void versionZero() {
   double takeProfit = 0.0;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   maxShort = MaxHigh(3);   
   minShort = MinLow(7);

   bool hasMaximumBrokenShort = ask >= maxShort ? true : false;
   bool hasMinimumBrokenShort = bid <= minShort ? true : false;
   
   DrawLine("max 3/7", clrGreen, STYLE_SOLID, maxShort);
   DrawLine("min 3/7", clrRed, STYLE_SOLID, minShort);
   /*
   //if( IsOrderOpen(InpMagicShort) == false ) {
      if(bid < maxShort && openShort == false) {
         openShort = true;
         Print("Operar 3/7");
      } else if(bid >= maxShort  && openShort == true && maxShortPrevious != maxShort) {
         double stopLoss = ask * (1.0 - 0.0005);
         double risk = ask - stopLoss;
         double takeProfit = ask + (risk * 2.0);
         PlaceOrder(ORDER_TYPE_BUY, 0.01, bid, stopLoss, takeProfit, InpMagicShort, "Estratégia 03/07");
         openShort = false;
         maxShortPrevious = maxShort;
         Print("Comprei:");
      }
   //}
   */
   
   if( IsOrderOpen(InpMagicShort) == false ) {
      if(hasMinimumBrokenShort == true && openShort == false) {
         openShort = true;
      } else if((hasMaximumBrokenShort == true && openShort == true)) {
         
         //double risk = ask - minShort;
         //double takeProfit = ask + risk;
         //PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, minShort, takeProfit, InpMagicShort, "Estratégia 03/07");
         
         double stopLoss = bid * (1.0 - 0.0010);
         double risk = bid - stopLoss;
         double takeProfit = bid + (risk * 2.0);
         PlaceOrder(ORDER_TYPE_BUY, 0.01, bid, stopLoss, takeProfit, InpMagicShort, "Estratégia 03/07");
         openShort = false;
      }
   }
   
   maxMedium = MaxHigh(10);   
   minMedium = MinLow(20);

   bool hasMaximumBrokenMedium = ask >= maxMedium ? true : false;
   bool hasMinimumBrokenMedium = bid <= minMedium ? true : false;
   
   DrawLine("max 10/20", clrGreen, STYLE_SOLID, maxMedium);
   DrawLine("min 10/20", clrRed, STYLE_SOLID, minMedium);
   
   if( IsOrderOpen(InpMagicMedium) == false ) {
      if(hasMinimumBrokenMedium == true && openMedium == false) {
         openMedium = true;
      } else if((hasMaximumBrokenMedium == true && openMedium == true)) {
         double stopLoss = bid * (1.0 - 0.0010);
         double risk = bid - stopLoss;
         double takeProfit = bid + (risk * 2.0);
         PlaceOrder(ORDER_TYPE_BUY, 0.01, bid, stopLoss, takeProfit, InpMagicMedium, "Estratégia 10/20");
         openMedium = false;
      }
   }
   
   maxLong = MaxHigh(20);   
   minLong = MinLow(55);

   bool hasMaximumBrokenLong = ask >= maxLong ? true : false;
   bool hasMinimumBrokenLong = bid <= minLong ? true : false;
   
   DrawLine("max 20/55", clrGreen, STYLE_SOLID, maxLong);
   DrawLine("min 20/55", clrRed, STYLE_SOLID, minLong);
   
   if( IsOrderOpen(InpMagicLong) == false ) {
      if(hasMinimumBrokenLong == true && openLong == false) {
         openLong = true;
      } else if((hasMaximumBrokenLong == true && openLong == true)) {
         double stopLoss = bid * (1.0 - 0.0010);
         double risk = bid - stopLoss;
         double takeProfit = bid + (risk * 2.0);
         PlaceOrder(ORDER_TYPE_BUY, 0.01, bid, stopLoss, takeProfit, InpMagicLong, "Estratégia 20/55");
         openLong = false;
      }
   }
   
   /*
   maxMedium = MaxHigh(10);   
   minMedium = MinLow(20);

   bool hasMaximumBrokenMedium = ask >= maxMedium ? true : false;
   bool hasMinimumBrokenMedium = bid <= minMedium ? true : false;
   
   DrawLine("max 10/20", clrGreen, STYLE_SOLID, maxMedium);
   DrawLine("min 10/20", clrRed, STYLE_SOLID, minMedium);
   
   if( IsOrderOpen(InpMagicMedium) == false ) {
      if(hasMinimumBrokenMedium == true && openMedium == false) {
         openMedium = true;
      } else if((hasMaximumBrokenMedium == true && openMedium == true)) {
         double risc = ask - minMedium;
         double takeProfit = ask + risc;
         PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, minMedium, takeProfit, InpMagicMedium, "Estratégia 10/20");
         openMedium = false;
      }
   }
   
   maxLong = MaxHigh(20);   
   minLong = MinLow(55);

   bool hasMaximumBrokenLong = ask >= maxLong ? true : false;
   bool hasMinimumBrokenLong = bid <= minLong ? true : false;
   
   DrawLine("max 20/55", clrGreen, STYLE_SOLID, maxLong);
   DrawLine("min 20/55", clrRed, STYLE_SOLID, minLong);
   
   if( IsOrderOpen(InpMagicLong) == false ) {
      if(hasMinimumBrokenLong == true && openLong == false) {
         openLong = true;
      } else if((hasMaximumBrokenLong == true && openLong == true)) {
         double risc = ask - minLong;
         double takeProfit = ask + risc;
         PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, minLong, takeProfit, InpMagicLong, "Estratégia 20/55");
         openLong = false;
      }
   }
   */
   
   /*
   if( IsOrderOpen(InpMagicShort) == false && hasMaximumBroken3_7 == true && (askShortLast != maxShort))
   {
      double takeProfit = 0.0;
      double gainTwoThirds = 0.0;
      double gainThreeThirds = 0.0;
      double stopLoss = 0.0;
      
      askShortLast = maxShort;
      //Print("askShortLast != max3_7 ", askShortLast, " : ", max3_7, " : ", (askShortLast != max3_7));
         
      stopLoss = ask - (ask * 0.001);
      
      //Print("EXECUTOU COMPRA: ", ask);
      //Print("STOP: ", stopLoss);
      
      takeProfit = ask + (ask * 0.0004);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, InpMagicShort, "Estratégia 03/07 0,04%");
      
      takeProfit = ask + (ask * 0.0006);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, InpMagicShort, "Estratégia 03/07 0,06%");
      
      takeProfit = ask + (ask * 0.001);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, InpMagicShort, "Estratégia 03/07 0,10%");

   }
   
   bool hasMaximumBroken10_20 = ask > max10_20 ? true : false;
   bool hasMinimumBroken10_20 = bid < min10_20 ? true : false;
   if(block10_20 == false) { 
      max10_20 = MaxHigh(20);   
      min10_20 = MinLow(10);
      
      DrawLine("max10_20", clrGreen, STYLE_SOLID, max10_20);
      DrawLine("min10_20", clrRed, STYLE_SOLID, min10_20);
   }
   
   bool hasMaximumBroken20_55 = ask > max20_55 ? true : false;
   bool hasMinimumBroken20_55 = bid < min20_55 ? true : false;
   if(block20_55 == false) { 
      max20_55 = MaxHigh(55);   
      min20_55 = MinLow(20);
      
      DrawLine("max20_55", clrGreen, STYLE_SOLID, max20_55);
      DrawLine("min20_55", clrRed, STYLE_SOLID, min20_55);
   }
   */
}

double MaxHigh(int targetPeriod) {
   double highs[];
   if (CopyHigh(_Symbol, _Period, 1, targetPeriod, highs) <= 0)
      return -1;

   double max = highs[0];
   for (int i = 1; i < ArraySize(highs); i++) {
      if (highs[i] > max)
         max = highs[i];
   }
   return max;
}

double MinLow(int targetPeriod) {
   double lows[];
   if (CopyLow(_Symbol, _Period, 1, targetPeriod, lows) <= 0)
      return -1; // erro na leitura

   double min = lows[0];
   for (int i = 1; i < ArraySize(lows); i++) {
      if (lows[i] < min)
         min = lows[i];
   }
   return min;
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

//+---------------------------------------------------------------------------+
//|  Função que verifica se o período informado já teve uma ordem executada   |
//+---------------------------------------------------------------------------+
bool IsOrderExecutedToday(int magicNumber, ENUM_TIMEFRAMES timeFrame)
{
    datetime periodStart = iTime(_Symbol, timeFrame, 0); // Obtém o horário inicial do período especificado

    // 🔹 Verifica ordens abertas
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionSelect(i))
        {
            if (PositionGetInteger(POSITION_MAGIC) == magicNumber)
            {
                datetime openTime = PositionGetInteger(POSITION_TIME);
                if (openTime >= periodStart) return true; // Já tem ordem aberta no período especificado
            }
        }
    }

    // 🔹 Verifica histórico de negociações executadas
    if (HistorySelect(periodStart, TimeCurrent())) // Seleciona todas as negociações do período até agora
    {
        for (int i = 0; i < HistoryDealsTotal(); i++)
        {
            ulong dealTicket = HistoryDealGetTicket(i);
            if (HistoryDealSelect(dealTicket))
            {
                long dealMagicNumber = HistoryDealGetInteger(dealTicket, DEAL_MAGIC); // Pegamos o número mágico
                datetime dealTime = HistoryDealGetInteger(dealTicket, DEAL_TIME);     // Pegamos a data da negociação
    
                if (dealMagicNumber == magicNumber && dealTime >= periodStart) 
                {
                    return true; // Ordem foi executada no período especificado
                }
            }
        }
    }

    return false; // Nenhuma ordem encontrada no período especificado
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
   request.action = TRADE_ACTION_DEAL;                                     // Executar ordem de mercado
   request.type = type;                                                    // Compra ou Venda
   request.symbol = _Symbol;                                               // Pega o ativo atual
   request.volume = lotSize;                                               // Tamanho do lote
   request.price = entryPrice;//(type == ORDER_TYPE_BUY) ? Ask : Bid;      // Preço atual
   request.sl = NormalizeDouble(stopLoss, _Digits);                        // Define Stop Loss em PIPs
   request.tp = NormalizeDouble(takeProfit, _Digits);                      // Usamos TP fixo, pois não temos o Trailing Stop
   request.deviation = 10;
   request.magic = numberMagic;                                            // Diferenciar ordens
   request.comment = strategyType;                                         // Para identificar
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
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         double stopLoss = PositionGetDouble(POSITION_SL);
         //double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         //double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         //double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

         if(newStopLoss > stopLoss)
         {
            ModifyStopLoss(ticket, newStopLoss);
         }
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
        //Print("SL já está no valor correto. Nenhuma modificação necessária.");
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

//-- Nova implementação

double LerMedia(int handle)
{
   double buffer[];

   if(CopyBuffer(handle, 0, 0, 1, buffer) <= 0)
      return EMPTY_VALUE;

   return buffer[0];
}
//+------------------------------------------------------------------+
//|                                                    Renenutet.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


double qtd3_7     = 0.03;
double qtd10_20   = 0.03;
double qtd20_55   = 0.03;
double            lots                    = 0.03;

// INICIO 3 DE 7
double            askShortLast            = 0;
double            min3_7                  = 0.0;
double            max3_7                  = 0.0;
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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   ChartTemplate();
   
   max3_7 = MaxHigh(3);   
   min3_7 = MinLow(7);
   
   DrawLine("max3_7", clrGreen, STYLE_SOLID, max3_7);
   DrawLine("min3_7", clrRed, STYLE_SOLID, min3_7);
   
   max10_20 = MaxHigh(20);   
   min10_20 = MinLow(10);
   
   DrawLine("max10_20", clrGreen, STYLE_SOLID, max10_20);
   DrawLine("min10_20", clrRed, STYLE_SOLID, min10_20);
   
   max20_55 = MaxHigh(55);   
   min20_55 = MinLow(20);
   
   DrawLine("max20_55", clrGreen, STYLE_SOLID, max20_55);
   DrawLine("min20_55", clrRed, STYLE_SOLID, min20_55);
   
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
void OnTick()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   max3_7 = MaxHigh(3);   
   min3_7 = MinLow(7);

   bool hasMaximumBroken3_7 = ask > max3_7 ? true : false;
   bool hasMinimumBroken3_7 = bid < min3_7 ? true : false;
   
   DrawLine("max3_7", clrGreen, STYLE_SOLID, max3_7);
   DrawLine("min3_7", clrRed, STYLE_SOLID, min3_7);

   //if( (IsOrderOpen(InpMagic3_7_1) == false && IsOrderOpen(InpMagic3_7_2) == false && IsOrderOpen(InpMagic3_7_3) == false) && hasMaximumBroken3_7 == true)
   if( IsOrderOpen(0307) == false && hasMaximumBroken3_7 == true && (askShortLast != max3_7))
   {
      double takeProfit = 0.0;
      double gainTwoThirds = 0.0;
      double gainThreeThirds = 0.0;
      double stopLoss = 0.0;
      
      askShortLast = max3_7;
      Print("askShortLast != max3_7 ", askShortLast, " : ", max3_7, " : ", (askShortLast != max3_7));
         
      stopLoss = ask - (ask * 0.001);
      
      Print("EXECUTOU COMPRA: ", ask);
      Print("STOP: ", stopLoss);
      
      takeProfit = ask + (ask * 0.0004);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, 0307, "Estratégia 03/07 0,04%");
      
      takeProfit = ask + (ask * 0.0006);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, 0307, "Estratégia 03/07 0,06%");
      
      takeProfit = ask + (ask * 0.001);
      PlaceOrder(ORDER_TYPE_BUY, 0.01, ask, stopLoss, takeProfit, 0307, "Estratégia 03/07 0,10%");


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
   request.tp = NormalizeDouble(takeProfit, _Digits);                     // Não usamos TP fixo, pois temos o Trailing Stop
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
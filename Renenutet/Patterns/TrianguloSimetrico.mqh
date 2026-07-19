#include "..\Core\Structs.mqh"
#include "..\Indicators\FractalDetector.mqh"

#define TS_MIN_TOQUES_FUNDO 3   // toques mínimos na LTA (fundo)
#define TS_MIN_TOQUES_TOPO  2   // toques mínimos na LTB (topo)
#define TS_MIN_TOQUES_TOTAL (TS_MIN_TOQUES_FUNDO + TS_MIN_TOQUES_TOPO) // 5

input int InpBarrasAnaliseTriangulo = 100; // Janela de busca do Triângulo Simétrico (candles)

//+------------------------------------------------------------------+
//| Mantém apenas os "qtd" pontos mais recentes (final do array)      |
//+------------------------------------------------------------------+
void FiltrarMaisRecentes(SPontoPreco &pontos[], int qtd)
{
   int n = ArraySize(pontos);
   if(n <= qtd) return;

   int descarte = n - qtd;
   for(int i = 0; i < qtd; i++)
      pontos[i] = pontos[i + descarte];

   ArrayResize(pontos, qtd);
}

//+------------------------------------------------------------------+
//| Regressão linear simples (y = a*x + b) usando indiceBar como x    |
//+------------------------------------------------------------------+
void CalcularRegressaoLinear(SPontoPreco &pontos[], double &inclinacao, double &intercepto)
{
   int n = ArraySize(pontos);
   inclinacao = 0.0;
   intercepto = 0.0;
   if(n < 2) return;

   double somaX = 0, somaY = 0, somaXY = 0, somaX2 = 0;
   for(int i = 0; i < n; i++)
   {
      double x = (double)pontos[i].indiceBar;
      double y = pontos[i].preco;
      somaX  += x;
      somaY  += y;
      somaXY += x * y;
      somaX2 += x * x;
   }

   double denom = (n * somaX2 - somaX * somaX);
   if(denom == 0.0) return;

   inclinacao = (n * somaXY - somaX * somaY) / denom;
   intercepto = (somaY - inclinacao * somaX) / n;
}

//+------------------------------------------------------------------+
//| Tenta identificar um Triângulo Simétrico válido                   |
//+------------------------------------------------------------------+
bool IdentificarTrianguloSimetrico(string symbol, ENUM_TIMEFRAMES timeframe,
                                    int barrasAnalise, STrianguloSimetrico &padrao)
{
   padrao.valido = false;

   DetectarFractais(symbol, timeframe, barrasAnalise, padrao.topos, padrao.fundos);

   // se veio mais fractal que o necessário, fica só com os mais recentes
   FiltrarMaisRecentes(padrao.fundos, TS_MIN_TOQUES_FUNDO);
   FiltrarMaisRecentes(padrao.topos, TS_MIN_TOQUES_TOPO);

   int nTopos  = ArraySize(padrao.topos);
   int nFundos = ArraySize(padrao.fundos);
   padrao.totalToques = nTopos + nFundos;

   if(nFundos < TS_MIN_TOQUES_FUNDO || nTopos < TS_MIN_TOQUES_TOPO) return false;
   if(padrao.totalToques < TS_MIN_TOQUES_TOTAL) return false;

   CalcularRegressaoLinear(padrao.topos, padrao.inclinacaoLTB, padrao.interceptoLTB);
   CalcularRegressaoLinear(padrao.fundos, padrao.inclinacaoLTA, padrao.interceptoLTA);

   bool toposDescendo = padrao.inclinacaoLTB < 0;
   bool fundosSubindo  = padrao.inclinacaoLTA > 0;
   bool convergindo    = (padrao.inclinacaoLTB - padrao.inclinacaoLTA) < 0;

   if(!toposDescendo || !fundosSubindo || !convergindo) return false;

   padrao.primeiroTopo     = padrao.topos[0].preco;
   padrao.primeiroFundo    = padrao.fundos[0].preco;
   padrao.amplitudeInicial = MathAbs(padrao.primeiroTopo - padrao.primeiroFundo);

   padrao.valido = true;
   return true;
}

//+------------------------------------------------------------------+
double ValorLTB(STrianguloSimetrico &padrao, int indiceBar)
{
   return padrao.inclinacaoLTB * indiceBar + padrao.interceptoLTB;
}

double ValorLTA(STrianguloSimetrico &padrao, int indiceBar)
{
   return padrao.inclinacaoLTA * indiceBar + padrao.interceptoLTA;
}

//+------------------------------------------------------------------+
//| Rompimento de alta: fechamento acima da LTB (candle fechado)      |
//+------------------------------------------------------------------+
bool VerificarRompimentoAlta(STrianguloSimetrico &padrao, string symbol, ENUM_TIMEFRAMES timeframe,
                              int indiceBar, double &precoEntrada, double &precoStop)
{
   if(!padrao.valido) return false;

   double close = iClose(symbol, timeframe, indiceBar);
   double high  = iHigh(symbol, timeframe, indiceBar);
   double low   = iLow(symbol, timeframe, indiceBar);
   double ltb   = ValorLTB(padrao, indiceBar);

   if(close > ltb)
   {
      precoEntrada = high;
      precoStop    = low;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Rompimento de baixa: fechamento abaixo da LTA (candle fechado)    |
//+------------------------------------------------------------------+
bool VerificarRompimentoBaixa(STrianguloSimetrico &padrao, string symbol, ENUM_TIMEFRAMES timeframe,
                               int indiceBar, double &precoEntrada, double &precoStop)
{
   if(!padrao.valido) return false;

   double close = iClose(symbol, timeframe, indiceBar);
   double high  = iHigh(symbol, timeframe, indiceBar);
   double low   = iLow(symbol, timeframe, indiceBar);
   double lta   = ValorLTA(padrao, indiceBar);

   if(close < lta)
   {
      precoEntrada = low;
      precoStop    = high;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Alvo projetado: 100% da amplitude inicial a partir do rompimento  |
//+------------------------------------------------------------------+
double CalcularAlvoCompra(STrianguloSimetrico &padrao, double precoRompimento)
{
   return precoRompimento + padrao.amplitudeInicial;
}

double CalcularAlvoVenda(STrianguloSimetrico &padrao, double precoRompimento)
{
   return precoRompimento - padrao.amplitudeInicial;
}
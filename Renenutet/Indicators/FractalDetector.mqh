#include "..\Core\Structs.mqh"

//+------------------------------------------------------------------+
//| Detecta fractais de topo e fundo dentro de um range de barras     |
//| barrasAnalise: quantas barras (fechadas) olhar para trás          |
//+------------------------------------------------------------------+
void DetectarFractais(string symbol, ENUM_TIMEFRAMES timeframe, int barrasAnalise,
                       SPontoPreco &topos[], SPontoPreco &fundos[])
{
   ArrayResize(topos, 0);
   ArrayResize(fundos, 0);

   int total = barrasAnalise + 4;
   double highs[], lows[];
   datetime times[];

   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(times, true);

   if(CopyHigh(symbol, timeframe, 0, total, highs) <= 0) return;
   if(CopyLow(symbol, timeframe, 0, total, lows) <= 0) return;
   if(CopyTime(symbol, timeframe, 0, total, times) <= 0) return;

   // shift 2 até barrasAnalise-2 (ignora candle 0 e 1, que ainda podem
   // não ter os 2 candles seguintes fechados para confirmar o fractal)
   for(int i = 2; i < barrasAnalise; i++)
   {
      // Fractal de topo: máxima central > 2 anteriores e > 2 posteriores
      if(highs[i] > highs[i-1] && highs[i] > highs[i-2] &&
         highs[i] > highs[i+1] && highs[i] > highs[i+2])
      {
         int n = ArraySize(topos);
         ArrayResize(topos, n + 1);
         topos[n].tempo     = times[i];
         topos[n].preco     = highs[i];
         topos[n].indiceBar = i;
      }

      // Fractal de fundo: mínima central < 2 anteriores e < 2 posteriores
      if(lows[i] < lows[i-1] && lows[i] < lows[i-2] &&
         lows[i] < lows[i+1] && lows[i] < lows[i+2])
      {
         int n = ArraySize(fundos);
         ArrayResize(fundos, n + 1);
         fundos[n].tempo     = times[i];
         fundos[n].preco     = lows[i];
         fundos[n].indiceBar = i;
      }
   }

   // reordena do mais antigo para o mais recente (útil pra regressão e "primeiro topo/fundo")
   InverterOrdem(topos);
   InverterOrdem(fundos);
}

//+------------------------------------------------------------------+
void InverterOrdem(SPontoPreco &pontos[])
{
   int n = ArraySize(pontos);
   for(int i = 0; i < n / 2; i++)
   {
      SPontoPreco tmp     = pontos[i];
      pontos[i]           = pontos[n - 1 - i];
      pontos[n - 1 - i]    = tmp;
   }
}
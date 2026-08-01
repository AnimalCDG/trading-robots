// Indicators/Ichimoku.mqh
#include "../Core/Structs.mqh"
#include "../Core/Enums.mqh"

int g_handleIchimoku = INVALID_HANDLE;

bool InicializarIchimoku(int tenkan = 9, int kijun = 26, int senkouB = 52, bool debug = false)
{
   g_handleIchimoku = iIchimoku(_Symbol, PERIOD_CURRENT, tenkan, kijun, senkouB);
   return (g_handleIchimoku != INVALID_HANDLE);
}

void DescarregarIchimoku(bool debug = false)
   {
      if(g_handleIchimoku != INVALID_HANDLE)
      {
         IndicatorRelease(g_handleIchimoku);
         g_handleIchimoku = INVALID_HANDLE;
   
         if(debug)
            Print("Ichimoku descarregado.");
      }
   }

bool ObterDadosIchimoku(SDadosIchimoku &dados, int kijunPeriodo, int shift = 1)
{
   double tenkanBuf[], kijunBuf[], senkouABuf[], senkouBBuf[], chikouBuf[];

   if(CopyBuffer(g_handleIchimoku, 0, shift, 2, tenkanBuf) < 2) return false;
   if(CopyBuffer(g_handleIchimoku, 1, shift, 2, kijunBuf)  < 2) return false;
   if(CopyBuffer(g_handleIchimoku, 2, shift, 1, senkouABuf) < 1) return false;
   if(CopyBuffer(g_handleIchimoku, 3, shift, 1, senkouBBuf) < 1) return false;
   if(CopyBuffer(g_handleIchimoku, 4, shift + kijunPeriodo, 1, chikouBuf) < 1) return false;

   dados.tenkan  = tenkanBuf[1];
   dados.kijun   = kijunBuf[1];
   dados.senkouA = senkouABuf[0];
   dados.senkouB = senkouBBuf[0];
   dados.chikou  = chikouBuf[0];

   double precoFechamento = iClose(_Symbol, PERIOD_CURRENT, shift);
   double kumoTopo   = MathMax(dados.senkouA, dados.senkouB);
   double kumoFundo   = MathMin(dados.senkouA, dados.senkouB);

   dados.precoAcimaKumo = precoFechamento > kumoTopo;
   dados.precoAbaixoKumo = precoFechamento < kumoFundo;

   dados.tenkanCruzouKijunAlta = (tenkanBuf[1] > kijunBuf[1] && tenkanBuf[0] <= kijunBuf[0]);
   dados.tenkanCruzouKijunBaixa = (tenkanBuf[1] < kijunBuf[1] && tenkanBuf[0] >= kijunBuf[0]);

   double precoPassado = iClose(_Symbol, PERIOD_CURRENT, shift + kijunPeriodo);
   dados.chikouLivre = (dados.chikou > precoPassado) || (dados.chikou < precoPassado);

   // classificação da tendência
   if(dados.precoAcimaKumo && dados.tenkanCruzouKijunAlta)
      dados.tendencia = ICHIMOKU_ALTA_FORTE;
   else if(dados.precoAcimaKumo)
      dados.tendencia = ICHIMOKU_ALTA;
   else if(dados.precoAbaixoKumo && dados.tenkanCruzouKijunBaixa)
      dados.tendencia = ICHIMOKU_BAIXA_FORTE;
   else if(dados.precoAbaixoKumo)
      dados.tendencia = ICHIMOKU_BAIXA;
   else
      dados.tendencia = ICHIMOKU_INDEFINIDA;

   return true;
}
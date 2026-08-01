   //+------------------------------------------------------------------+
   //|                                                 TrendManager.mqh |
   //|                                  Copyright 2024, MetaQuotes Ltd. |
   //|                                             https://www.mql5.com |
   //+------------------------------------------------------------------+
   #property copyright "Copyright 2024, MetaQuotes Ltd."
   #property link      "https://www.mql5.com"
   
   #include "../Indicators/Ichimoku.mqh"
   
   #ifndef __TREND_MANAGER_MQH__
   #define __TREND_MANAGER_MQH__
   
   int   fractalHandle     = INVALID_HANDLE;
   int   framaHandle       = INVALID_HANDLE;
   int   adxHandle         = INVALID_HANDLE;
   int   envelopesHandle   = INVALID_HANDLE;
   //int   ichimokuHandle    = INVALID_HANDLE;
   
   bool InicializarFractal(bool debug = false)
   {
      fractalHandle = iFractals(_Symbol, PERIOD_CURRENT);
   
      if(fractalHandle == INVALID_HANDLE)
      {
         Print("Erro ao criar indicador Fractals.");
         return false;
      }
      
      if(debug)
         Print("Fractals inicializado com sucesso.");
   
      return true;
   }
   
   void DescarregarFractal(bool debug = false)
   {
      if(fractalHandle != INVALID_HANDLE)
      {
         IndicatorRelease(fractalHandle);
         fractalHandle = INVALID_HANDLE;
   
         if(debug)
            Print("Handle do Fractal liberado.");
      }
   }
   
   bool InicializarFRAMA(int periodo = 20, bool debug = false)
   {
      int framaHandle = iFrAMA(
         _Symbol,
         PERIOD_CURRENT,
         periodo,      // período
         0,            // shift
         PRICE_CLOSE   // preço aplicado
      );
      
      if(framaHandle == INVALID_HANDLE)
      {
         Print("Erro ao criar indicador Fractal Adaptive Moving Average.");
         return false;
      }
      
      if(debug)
         Print("Fractal Adaptive Moving Average inicializado com sucesso.");
   
      return (framaHandle != INVALID_HANDLE);
   }
   
   void DescarregarFRAMA(bool debug = false)
   {
      if(framaHandle != INVALID_HANDLE)
      {
         IndicatorRelease(framaHandle);
         framaHandle = INVALID_HANDLE;
   
         if(debug)
            Print("Fractal Adaptive Moving Average liberado.");
      }
   }
   
   bool InicializarADX(int periodo = 20, bool debug = false)
   {
      adxHandle = iADX(_Symbol, PERIOD_CURRENT, periodo);
   
      if(adxHandle == INVALID_HANDLE)
      {
         Print("Erro ao criar o indicador ADX.");
         return false;
      }
   
      if(debug)
         Print("ADX inicializado com sucesso.");
   
      return true;
   }
   
   void DescarregarADX(bool debug = false)
   {
      if(adxHandle != INVALID_HANDLE)
      {
         IndicatorRelease(adxHandle);
         adxHandle = INVALID_HANDLE;
   
         if(debug)
            Print("ADX descarregado.");
      }
   }
   
   bool InicializarEnvelopes(
      int periodo = 20,
      int deslocamento = 0,
      ENUM_MA_METHOD metodo = MODE_SMA,
      ENUM_APPLIED_PRICE preco = PRICE_CLOSE,
      double desvio = 0.10,
      bool debug = false)
   {
      envelopesHandle = iEnvelopes(
         _Symbol,
         PERIOD_CURRENT,
         periodo,
         deslocamento,
         metodo,
         preco,
         desvio);
   
      if(envelopesHandle == INVALID_HANDLE)
      {
         Print("Erro ao criar o indicador Envelopes.");
         return false;
      }
   
      if(debug)
         Print("Envelopes inicializado.");
   
      return true;
   }
   
   void DescarregarEnvelopes(bool debug = false)
   {
      if(envelopesHandle != INVALID_HANDLE)
      {
         IndicatorRelease(envelopesHandle);
         envelopesHandle = INVALID_HANDLE;
   
         if(debug)
            Print("Envelopes descarregado.");
      }
   }

   /*
   bool InicializarIchimoku(
      int tenkan = 9,
      int kijun = 26,
      int senkouB = 52,
      bool debug = false)
   {
      ichimokuHandle = iIchimoku(
         _Symbol,
         PERIOD_CURRENT,
         tenkan,
         kijun,
         senkouB);
   
      if(ichimokuHandle == INVALID_HANDLE)
      {
         Print("Erro ao criar o indicador Ichimoku.");
         return false;
      }
   
      if(debug)
         Print("Ichimoku inicializado.");
   
      return true;
   }
   
   void DescarregarIchimoku(bool debug = false)
   {
      if(ichimokuHandle != INVALID_HANDLE)
      {
         IndicatorRelease(ichimokuHandle);
         ichimokuHandle = INVALID_HANDLE;
   
         if(debug)
            Print("Ichimoku descarregado.");
      }
   }
   */
      
   ETendenciaIchimoku ObterTendenciaAtual(int tenkan, int kijun, int senkouB)
   {
      SDadosIchimoku dados;
      if(!ObterDadosIchimoku(dados, kijun))
         return ICHIMOKU_INDEFINIDA;
   
      return dados.tendencia;
   }
   
   bool TendenciaPermiteCompra(int tenkan, int kijun, int senkouB)
   {
      ETendenciaIchimoku t = ObterTendenciaAtual(tenkan, kijun, senkouB);
      return (t == ICHIMOKU_ALTA || t == ICHIMOKU_ALTA_FORTE);
   }
   
   bool TendenciaPermiteVenda(int tenkan, int kijun, int senkouB)
   {
      ETendenciaIchimoku t = ObterTendenciaAtual(tenkan, kijun, senkouB);
      return (t == ICHIMOKU_BAIXA || t == ICHIMOKU_BAIXA_FORTE);
   }
   
   #endif

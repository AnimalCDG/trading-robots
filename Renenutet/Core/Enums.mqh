//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __ENUMS_MQH__
#define __ENUMS_MQH__

enum Tendencia
{
   ERRO = -1,

   FORTE_BAIXA = 0,
   BAIXA,
   LATERAL,
   ALTA,
   FORTE_ALTA
};

enum TipoMedia
{
   SMA = 0,
   EMA
};

enum TipoNivelPreco
{
   HIGH,
   LOW
};

enum ENUM_ESTADO_ESTRATEGIA
{
   ESTADO_AGUARDANDO_GATILHO,
   ESTADO_COMPRA_ENVIADA,
   ESTADO_VENDAS_CRIADAS
};

#endif
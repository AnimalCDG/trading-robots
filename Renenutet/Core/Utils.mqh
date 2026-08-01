//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __UTILS_MQH__
#define __UTILS_MQH__

#include "Enums.mqh"
#include "Structs.mqh"
#include "Constants.mqh"

//double filaResistencia[];
double filaSuporte[];

SDadosResistenciaSuporte filaResistencia[];

string TendenciaToString(Tendencia tendencia)
{
   switch(tendencia)
   {
      case FORTE_ALTA:  return "↑↑ Forte Alta";
      case ALTA:        return "↑ Alta";
      case LATERAL:     return "→ Lateral";
      case BAIXA:       return "↓ Baixa";
      case FORTE_BAIXA: return "↓↓ Forte Baixa";
      default:          return "Erro";
   }
}

string TipoMediaToString(TipoMedia tipo)
{
   if(tipo == EMA)
      return "EMA";

   return "SMA";
}

//+------------------------------------------------------------------+
//| Normaliza um preco para o tick size do simbolo atual, evitando   |
//| erros de "invalid price" ao enviar ordens (TRADE_RETCODE_INVALID |
//| _PRICE) por preco fora da grade de ticks permitida.               |
//+------------------------------------------------------------------+
double NormalizarPreco(double preco)
{
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickSize <= 0.0)
      tickSize = _Point;

   double precoNormalizado = MathRound(preco / tickSize) * tickSize;

   return NormalizeDouble(precoNormalizado, _Digits);
}

//+------------------------------------------------------------------+
//| Calcula um preco a partir de um percentual sobre um preco base.  |
//| paraCima = true  -> soma o percentual (precoBase * (1 + %))      |
//| paraCima = false -> subtrai o percentual (precoBase * (1 - %))   |
//| O resultado ja vem normalizado ao tick size do simbolo.          |
//+------------------------------------------------------------------+
double PrecoAPartirDePercentual(double precoBase, double percentual, bool paraCima)
{
   double variacao = precoBase * (percentual / 100.0);
   double resultado = paraCima ? (precoBase + variacao) : (precoBase - variacao);

   return NormalizarPreco(resultado);
}

/*
void InserirResistencia(double valor)
{
   int tamanho = ArraySize(filaResistencia);

   if(tamanho < LIMITE_ARRAY)
   {
      ArrayResize(filaResistencia, tamanho + 1);
      filaResistencia[tamanho] = valor;
   }
   else
   {
      // Desloca todos os elementos para a esquerda
      for(int i = 1; i < LIMITE_ARRAY; i++)
         filaResistencia[i - 1] = filaResistencia[i];

      // Insere o novo no final
      filaResistencia[LIMITE_ARRAY - 1] = valor;
   }
}
*/

void InserirResistencia(double maxima, double minima)
{
   int tamanho = ArraySize(filaResistencia);
   
   static SDadosResistenciaSuporte tempResistencia;
   tempResistencia.resistencia     = maxima;
   tempResistencia.suporte         = minima;
   
   if(tamanho < LIMITE_ARRAY)
   {
      if(tamanho > 0) {
         if(tempResistencia.resistencia > filaResistencia[tamanho - 1].resistencia)
            return;
      }
      ArrayResize(filaResistencia, tamanho + 1);
      filaResistencia[tamanho] = tempResistencia;
   }
   else
   {
      // Desloca todos os elementos para a esquerda
      for(int i = 1; i < LIMITE_ARRAY; i++)
         filaResistencia[i - 1] = filaResistencia[i];

      // Insere o novo no final
      filaResistencia[LIMITE_ARRAY - 1] = tempResistencia;
   }
}

/**
 * @brief Remove o registro mais antigo da fila.
 *
 * Remove o primeiro elemento (posição 0), deslocando os demais
 * elementos uma posição para a esquerda.
 *
 * @return true  Se um elemento foi removido.
 * @return false Se a fila estiver vazia.
 */
bool RemoverResistencia()
{
   int tamanho = ArraySize(filaResistencia);

   if(tamanho == 0)
      return false;

   // Desloca os elementos para a esquerda
   for(int i = 1; i < tamanho; i++)
      filaResistencia[i - 1] = filaResistencia[i];

   // Reduz o tamanho do array
   ArrayResize(filaResistencia, tamanho - 1);

   return true;
}

#endif
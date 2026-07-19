//+------------------------------------------------------------------+
//|                                        TrianguloAscendente.mqh     |
//|  Deteccao do padrao grafico "Triangulo Ascendente"                 |
//|  - Topos horizontais (resistencia) + Fundos ascendentes (LTA)      |
//|  - Rompimento classico: acima da resistencia horizontal            |
//|  - Rompimento alternativo: abaixo da LTA (conforme tendencia previa)|
//|  Baseado na mesma abordagem de fractais/pivots do Triangulo         |
//|  Simetrico ja definida no projeto Renenutet.                       |
//+------------------------------------------------------------------+
#property strict

#include "../Core/Structs.mqh"   // ja traz Enums.mqh (ETipoRompimentoAscendente) e as structs
                                  // SPontoFractalTA / SDadosTrianguloAscendente

//+------------------------------------------------------------------+
//| Struct: resultado da verificacao de rompimento                    |
//| (unica coisa nova aqui, nao existe em Structs.mqh ainda)          |
//+------------------------------------------------------------------+
struct SRompimentoTrianguloAscendente
{
   bool     detectado;
   ETipoRompimentoAscendente tipo;
   double   precoEntrada;      // maxima (compra) ou minima (venda) do candle de rompimento
   double   precoStop;         // lado oposto do mesmo candle
   double   precoAlvo;         // projecao Fibonacci 100%
   datetime tempoCandleRompimento;
};

//--- Parametros de deteccao (ajustar via input no EA)
#define TA_TOLERANCIA_TOPO_PERCENT   0.10   // tolerancia % entre topos p/ considerar "mesmo nivel"
#define TA_MIN_TOPOS                 2
#define TA_MIN_FUNDOS                3

//+------------------------------------------------------------------+
//| Identifica fractais de topo (5 barras: maxima central > 2 de cada  |
//| lado) dentro da janela de analise                                  |
//+------------------------------------------------------------------+
int ColetarFractaisTopo(string symbolName, ENUM_TIMEFRAMES tf, int barrasAnalise,
                         SPontoFractalTA &topos[])
{
   ArrayResize(topos, 0);
   int total = 0;

   for(int i = 2; i < barrasAnalise - 2; i++)
   {
      double centro = iHigh(symbolName, tf, i);
      double esq2   = iHigh(symbolName, tf, i + 2);
      double esq1   = iHigh(symbolName, tf, i + 1);
      double dir1   = iHigh(symbolName, tf, i - 1);
      double dir2   = iHigh(symbolName, tf, i - 2);

      if(centro > esq2 && centro > esq1 && centro > dir1 && centro > dir2)
      {
         total++;
         ArrayResize(topos, total);
         topos[total - 1].tempo     = iTime(symbolName, tf, i);
         topos[total - 1].preco     = centro;
         topos[total - 1].indiceBar = i;
      }
   }
   return total;
}

//+------------------------------------------------------------------+
//| Identifica fractais de fundo (5 barras: minima central < 2 de cada |
//| lado) dentro da janela de analise                                  |
//+------------------------------------------------------------------+
int ColetarFractaisFundo(string symbolName, ENUM_TIMEFRAMES tf, int barrasAnalise,
                          SPontoFractalTA &fundos[])
{
   ArrayResize(fundos, 0);
   int total = 0;

   for(int i = 2; i < barrasAnalise - 2; i++)
   {
      double centro = iLow(symbolName, tf, i);
      double esq2   = iLow(symbolName, tf, i + 2);
      double esq1   = iLow(symbolName, tf, i + 1);
      double dir1   = iLow(symbolName, tf, i - 1);
      double dir2   = iLow(symbolName, tf, i - 2);

      if(centro < esq2 && centro < esq1 && centro < dir1 && centro < dir2)
      {
         total++;
         ArrayResize(fundos, total);
         fundos[total - 1].tempo     = iTime(symbolName, tf, i);
         fundos[total - 1].preco     = centro;
         fundos[total - 1].indiceBar = i;
      }
   }
   return total;
}

//+------------------------------------------------------------------+
//| Verifica se um conjunto de topos esta dentro da tolerancia         |
//| percentual (mesmo nivel horizontal)                                |
//+------------------------------------------------------------------+
bool ToposNoMesmoNivel(const SPontoFractalTA &topos[], int qtde, double &nivelMedio)
{
   if(qtde < TA_MIN_TOPOS) return false;

   double soma = 0;
   double maxPreco = topos[0].preco;
   double minPreco = topos[0].preco;

   for(int i = 0; i < qtde; i++)
   {
      soma += topos[i].preco;
      if(topos[i].preco > maxPreco) maxPreco = topos[i].preco;
      if(topos[i].preco < minPreco) minPreco = topos[i].preco;
   }

   nivelMedio = soma / qtde;
   double variacaoPercent = (maxPreco - minPreco) / nivelMedio * 100.0;

   return (variacaoPercent <= TA_TOLERANCIA_TOPO_PERCENT);
}

//+------------------------------------------------------------------+
//| Verifica se os fundos sao estritamente ascendentes (do mais antigo |
//| para o mais recente) e calcula regressao linear da LTA             |
//+------------------------------------------------------------------+
bool FundosAscendentes(const SPontoFractalTA &fundos[], int qtde,
                        double &coefAngular, double &coefLinear)
{
   if(qtde < TA_MIN_FUNDOS) return false;

   // fundos[] vem do mais recente (indice 0) para o mais antigo;
   // percorre do mais antigo para o mais recente checando ascensao
   for(int i = qtde - 1; i > 0; i--)
   {
      if(fundos[i - 1].preco <= fundos[i].preco)
         return false; // nao esta ascendente
   }

   // Regressao linear simples (minimos quadrados) sobre indiceBar x preco
   double somaX = 0, somaY = 0, somaXY = 0, somaX2 = 0;
   for(int i = 0; i < qtde; i++)
   {
      double x = fundos[i].indiceBar;
      double y = fundos[i].preco;
      somaX  += x;
      somaY  += y;
      somaXY += x * y;
      somaX2 += x * x;
   }

   double n = qtde;
   double denominador = (n * somaX2 - somaX * somaX);
   if(denominador == 0) return false;

   coefAngular = (n * somaXY - somaX * somaY) / denominador;
   coefLinear  = (somaY - coefAngular * somaX) / n;

   // indiceBar decresce do passado (maior) para o presente (menor),
   // entao LTA ascendente no tempo = coeficiente angular NEGATIVO em relacao a indiceBar
   return (coefAngular < 0);
}

//+------------------------------------------------------------------+
//| Funcao principal: detecta o Triangulo Ascendente                  |
//+------------------------------------------------------------------+
bool DetectarTrianguloAscendente(string symbolName, ENUM_TIMEFRAMES tf, int barrasAnalise,
                                  SDadosTrianguloAscendente &resultado)
{
   resultado.valido = false;

   SPontoFractalTA todosTopos[];
   SPontoFractalTA todosFundos[];

   int qtdTopos  = ColetarFractaisTopo(symbolName, tf, barrasAnalise, todosTopos);
   int qtdFundos = ColetarFractaisFundo(symbolName, tf, barrasAnalise, todosFundos);

   if(qtdTopos < TA_MIN_TOPOS || qtdFundos < TA_MIN_FUNDOS)
      return false;

   // Usa apenas os topos e fundos mais recentes (indice 0 = mais novo,
   // pois o loop de coleta percorre de i=2 crescente, ou seja, do mais
   // recente ao mais antigo dentro da janela)
   SPontoFractalTA toposRecentes[];
   ArrayResize(toposRecentes, MathMin(qtdTopos, TA_MIN_TOPOS));
   for(int i = 0; i < ArraySize(toposRecentes); i++)
      toposRecentes[i] = todosTopos[i];

   SPontoFractalTA fundosRecentes[];
   ArrayResize(fundosRecentes, MathMin(qtdFundos, TA_MIN_FUNDOS));
   for(int i = 0; i < ArraySize(fundosRecentes); i++)
      fundosRecentes[i] = todosFundos[i];

   double nivelResistencia = 0;
   if(!ToposNoMesmoNivel(toposRecentes, ArraySize(toposRecentes), nivelResistencia))
      return false;

   double coefAngular = 0, coefLinear = 0;
   if(!FundosAscendentes(fundosRecentes, ArraySize(fundosRecentes), coefAngular, coefLinear))
      return false;

   // Monta resultado
   resultado.valido                = true;
   resultado.resistenciaHorizontal = nivelResistencia;
   resultado.coefAngularLTA        = coefAngular;
   resultado.coefLinearLTA         = coefLinear;

   ArrayResize(resultado.topos, ArraySize(toposRecentes));
   for(int i = 0; i < ArraySize(toposRecentes); i++)
      resultado.topos[i] = toposRecentes[i];

   ArrayResize(resultado.fundos, ArraySize(fundosRecentes));
   for(int i = 0; i < ArraySize(fundosRecentes); i++)
      resultado.fundos[i] = fundosRecentes[i];

   // primeiroTopo = topo mais antigo do conjunto usado
   resultado.primeiroTopo = toposRecentes[ArraySize(toposRecentes) - 1].preco;

   // fundoMaisBaixo = fundo mais antigo (base da LTA), tipicamente o mais baixo
   resultado.fundoMaisBaixo = fundosRecentes[ArraySize(fundosRecentes) - 1].preco;

   resultado.amplitudeVertical = resultado.primeiroTopo - resultado.fundoMaisBaixo;

   int idxTopoMaisAntigo  = toposRecentes[ArraySize(toposRecentes) - 1].indiceBar;
   int idxFundoMaisAntigo = fundosRecentes[ArraySize(fundosRecentes) - 1].indiceBar;
   resultado.indiceBarInicioFigura = MathMax(idxTopoMaisAntigo, idxFundoMaisAntigo);

   return true;
}

//+------------------------------------------------------------------+
//| Calcula o valor da LTA (reta de fundos) no indice de barra dado    |
//+------------------------------------------------------------------+
double ValorLTA(const SDadosTrianguloAscendente &triangulo, int indiceBar)
{
   return triangulo.coefAngularLTA * indiceBar + triangulo.coefLinearLTA;
}

//+------------------------------------------------------------------+
//| Verifica rompimento no FECHAMENTO do candle (indice 1 = ultimo     |
//| candle fechado). Retorna tipo de rompimento e dados para entrada,  |
//| stop e alvo (projecao de Fibonacci 100% da amplitude vertical).    |
//+------------------------------------------------------------------+
bool VerificarRompimentoTrianguloAscendente(string symbolName, ENUM_TIMEFRAMES tf,
                                             const SDadosTrianguloAscendente &triangulo,
                                             SRompimentoTrianguloAscendente &rompimento)
{
   rompimento.detectado = false;
   rompimento.tipo = ROMPIMENTO_NENHUM;

   if(!triangulo.valido) return false;

   int idxCandleFechado = 1; // ultimo candle fechado
   double fechamento = iClose(symbolName, tf, idxCandleFechado);
   double maxima     = iHigh(symbolName, tf, idxCandleFechado);
   double minima     = iLow(symbolName, tf, idxCandleFechado);
   datetime tempoCandle = iTime(symbolName, tf, idxCandleFechado);

   double valorLTAAtual = ValorLTA(triangulo, idxCandleFechado);

   // Rompimento classico: fecha acima da resistencia horizontal
   if(fechamento > triangulo.resistenciaHorizontal)
   {
      rompimento.detectado           = true;
      rompimento.tipo                = ROMPIMENTO_RESISTENCIA_ALTA;
      rompimento.precoEntrada        = maxima;   // entrada na violacao da maxima
      rompimento.precoStop           = minima;   // stop na minima do mesmo candle
      rompimento.precoAlvo           = rompimento.precoEntrada + triangulo.amplitudeVertical;
      rompimento.tempoCandleRompimento = tempoCandle;
      return true;
   }

   // Rompimento alternativo: fecha abaixo da LTA
   if(fechamento < valorLTAAtual)
   {
      rompimento.detectado           = true;
      rompimento.tipo                = ROMPIMENTO_LTA_BAIXA;
      rompimento.precoEntrada        = minima;   // entrada na perda da minima
      rompimento.precoStop           = maxima;   // stop na maxima do mesmo candle
      rompimento.precoAlvo           = rompimento.precoEntrada - triangulo.amplitudeVertical;
      rompimento.tempoCandleRompimento = tempoCandle;
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
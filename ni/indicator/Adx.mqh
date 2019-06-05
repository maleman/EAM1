//+------------------------------------------------------------------+
//|                                                          Adx.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Indicator.mqh"
#include "..\enum\Enums.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Adx : public Indicator
  {
private:

   int               adxPeriod;

   //--- búfers indicadores
   double            ADXBuffer[];
   double            DI_plusBuffer[];
   double            DI_minusBuffer[];

   double            value;
   double            plus;
   double            min;

   string            symbol;
   ENUM_TIMEFRAMES   period;

   MarketTrend       strengthTrend;

protected:
   int               handle;
   int               lastBars;

   AdxSignals        signals[];

   virtual int       copyValues();
   virtual void      lookforsigns();
   virtual void      lookforTrend();

   void              addSignal(AdxSignals sig);

public:
                     Adx();
                    ~Adx();
                     Adx(string symbol,ENUM_TIMEFRAMES timeFrames,int adxp);
   virtual int       init(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
   virtual int getHandle(){return handle;}

   void              toInfo();

   AdxSignals        getLastSignal();
   MarketTrend       getAdxTrend(){return strengthTrend;}

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Adx::Adx(string psymbol,ENUM_TIMEFRAMES ptimeFrames,int adxp)
  {

//symbol   = psymbol;
//period   = ptimeFrames; 

   strengthTrend=NO_TREND;

   adxPeriod=adxp;

   init(symbol,period);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Adx::Adx()
  {
   strengthTrend  = NO_TREND;
   adxPeriod      = 24;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Adx::~Adx()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Adx::init(string psymbol,ENUM_TIMEFRAMES ptimeFrames)
  {

   symbol   = psymbol;
   period   = ptimeFrames;
   adxPeriod= 24;

   handle=iADX(symbol,period,adxPeriod);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Fallo al crear el manejador del indicador Adx ");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Adx::copyValues()
  {

   if(CopyBuffer(handle,0,0,adxPeriod,ADXBuffer)<0)       return -1;
   if(CopyBuffer(handle,1,0,adxPeriod,DI_plusBuffer)<0)    return -1;
   if(CopyBuffer(handle,2,0,adxPeriod,DI_minusBuffer)<0)   return -1;

   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Adx::onTick(void)
  {

   int bars=Bars(symbol,period);

   if(lastBars!=bars) lastBars=bars;
   else                  return -1;

   copyValues();
   lookforsigns();

   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Adx::lookforsigns()
  {

   int adxSize    = ArraySize(ADXBuffer)-1;
   int plusSize   = ArraySize(DI_plusBuffer)-1;
   int minSize    = ArraySize(DI_minusBuffer)-1;

   value   = ADXBuffer[adxSize];
   plus    = DI_plusBuffer[plusSize];
   min     = DI_minusBuffer[minSize];

   if(value<25 && plus>min)
      strengthTrend=WEAK_UPTREND;
   else if(value<25 && plus<=min)
                             strengthTrend=WEAK_DOWNTREND;
   if(value>=25 && value<50 && plus>min)
      strengthTrend=NEUTRAL_UPTREND;
   else if(value>=25 && value<50 && plus<=min)
                  strengthTrend=NEUTRAL_DOWNTREND;
   if(value>=50 && value<75 && plus>min)
      strengthTrend=STRONG_UPTREND;
   else if(value>=50 && value<75 && plus<=min)
                  strengthTrend=STRONG_DOWNTREND;
   if(value>=75 && value<100 && plus>min)
      strengthTrend=VERY_STRONG_UPTREND;
   else if(value>=75 && value<100 && plus<=min)
                  strengthTrend=VERY_STRONG_DOWNTREND;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Adx::addSignal(AdxSignals sig)
  {
   int signalSize=ArraySize(signals);
   ArrayResize(signals,signalSize+1);
   signals[signalSize]=sig;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AdxSignals Adx::getLastSignal()
  {
   if(ArraySize(signals)-1<0)
      return NULL;

   return signals[ArraySize(signals)-1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Adx::toInfo()
  {

   Comment("Fuerza de la tendencia (ADX) : ",marketTrendToString(strengthTrend),"\n"
           "Valor (ADX)  :",value,"\n"
           "Valor (ADX+) : ",plus,"\n"
           "Valor (ADX-) : ",min,"\n");
  }
//+------------------------------------------------------------------+

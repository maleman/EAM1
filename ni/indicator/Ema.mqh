//+------------------------------------------------------------------+
//|                                                          Ema.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "Indicator.mqh"
#include "..\enum\Enums.mqh"
#include "..\dataset\signal\EmaDataSet.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Ema: public Indicator
  {
private:
   int               handle2;

   int               shift;

   double            iMABuffer[];
   double            iMABuffer2[];

   virtual int       copyValues();
   virtual void      lookforsigns();
   virtual void      lookforTrend();

   void              addSignal(EmaSignals sig);

   string            symbol;
   ENUM_TIMEFRAMES   period;

   int               period_1;
   int               period_2;
   int               shift_1;
   int               shift_2;
   ENUM_MA_METHOD    method_1;
   ENUM_MA_METHOD    method_2;
   ENUM_APPLIED_PRICE app_price_1;
   ENUM_APPLIED_PRICE app_price_2;

   EmaSignals        signals[];
   EmaDataSet       *signalsSet[];

public:
                     Ema();
                    ~Ema();

   virtual int       init(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
   virtual int getHandle(){return handle;}

   EmaSignals        getLastSignal();
   EmaDataSet       *getLastSigDs();
   void              toInfo();
   void              deInit();

   void setIndicatorData(int ma_period_1,
                         int ma_period_2,
                         int ma_shift_1 = 0,
                         int ma_shift_2 = 0,
                         ENUM_MA_METHOD ma_method_1=MODE_EMA,
                         ENUM_MA_METHOD ma_method_2=MODE_EMA,
                         ENUM_APPLIED_PRICE applied_price_1=PRICE_CLOSE,
                         ENUM_APPLIED_PRICE applied_price_2=PRICE_CLOSE)
     {

      period_1 = ma_period_1;
      period_2 = ma_period_2;
      shift_1  = ma_shift_1;
      shift_2=ma_shift_2;
      method_1 = ma_method_1;
      method_2 = ma_method_2;
      app_price_1 = applied_price_1;
      app_price_2 = applied_price_2;
     }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::Ema()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::~Ema()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ema::init(string psymbol,ENUM_TIMEFRAMES timeFrames)
  {

   symbol = psymbol;
   period = timeFrames;

//if(emaPeriod==0 || emaPeriod2==0)
//   return INIT_FAILED;

   handle   = iMA(Symbol(),period,period_1,shift_1,method_1,app_price_1);
   handle2  = iMA(Symbol(),period,period_2,shift_2,method_2,app_price_2);

   if(handle==INVALID_HANDLE || handle2==INVALID_HANDLE)
     {
      PrintFormat("Fallo al crear el manejador del indicador EMA ");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ema::copyValues()
  {
   if(CopyBuffer(handle,0,-shift,period_1,iMABuffer)<0)       return -1;
   if(CopyBuffer(handle2,0,-shift,period_2,iMABuffer2)<0)    return -1;

   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ema::onTick(void)
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
Ema::lookforsigns(void)
  {

   int f = ArraySize(iMABuffer)-1;
   int a = ArraySize(iMABuffer2)-1;


   if(iMABuffer[f-2]<iMABuffer2[a-2]
      && iMABuffer[f]>iMABuffer2[a])
      addSignal(BUY);
   else  if(iMABuffer[f-2]>iMABuffer2[a-2]
      && iMABuffer[f]<iMABuffer2[a])
      addSignal(SELL);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::addSignal(EmaSignals sig)
  {
//int signalSize=ArraySize(signals);
//ArrayResize(signals,signalSize+1);
//signals[signalSize]=sig;

   int signalSize=ArraySize(signalsSet);
   ArrayResize(signalsSet,signalSize+1);
   signalsSet[signalSize]=new EmaDataSet(sig,false);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaSignals Ema::getLastSignal()
  {
   EmaDataSet ds=getLastSigDs();
   if(!ds.isProcessed())
      return ds.getSignal();
   else
      return NA;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaDataSet *Ema::getLastSigDs()
  {
   int i=ArraySize(signalsSet)-1;
   if(i>=0)
      return signalsSet[i];

   return NULL;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::deInit()
  {
   //delete signalsSet;
  }
//+------------------------------------------------------------------+

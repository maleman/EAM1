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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Ema: public Indicator
  {
private:
   
   int      emaPeriod;
   int      emaPeriod2;
   int      handle2;
   
   int      shift;
   
   double   iMABuffer[];
   double   iMABuffer2[];
   
   virtual int copyValues();
   virtual void lookforsigns();
   virtual void lookforTrend();
   
   void addSignal(EmaSignals sig);
   
   string            symbol;
   ENUM_TIMEFRAMES   period;
   
   EmaSignals signals[];

public:
   Ema();
   ~Ema();
   
   virtual int init(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int onTick();
   virtual int getHandle(){return handle;}
   
   
   EmaSignals     getLastSignal();
   
   void           toInfo();
   
   void setEmaPeriod(int period, int period2){
      if(emaPeriod == 0)
         emaPeriod = period;
         
       if(emaPeriod2 == 0)
         emaPeriod2 = period2;
    }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::Ema(){
      emaPeriod   = 0;
      emaPeriod2  = 0;
      shift       = 0; 
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
int Ema::init(string psymbol,ENUM_TIMEFRAMES timeFrames){
   
   symbol = psymbol;
   period = timeFrames;
   
   if(emaPeriod == 0 || emaPeriod2 == 0)
      return INIT_FAILED;
      
   handle   = iMA(Symbol(),period,emaPeriod,shift,MODE_EMA,PRICE_CLOSE);
   handle2  = iMA(Symbol(),period,emaPeriod2,shift,MODE_EMA,PRICE_CLOSE);
   
   if(handle==INVALID_HANDLE || handle2==INVALID_HANDLE){
         PrintFormat("Fallo al crear el manejador del indicador EMA ");
         return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ema::copyValues(){
   if(CopyBuffer(handle,0,-shift,emaPeriod,iMABuffer)<0)       return -1;
   if(CopyBuffer(handle2,0,-shift,emaPeriod2,iMABuffer2)<0)    return -1;
   
   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ema::onTick(void){
   
   int bars = Bars(symbol,period);
	
	if (lastBars != bars) lastBars = bars;
	else                  return -1;
	
	copyValues();
	lookforsigns();
	
	return 1;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::lookforsigns(void){
   
   int f = ArraySize(iMABuffer)-1;
   int a = ArraySize(iMABuffer2)-1;
   
   if(iMABuffer[f-2] < iMABuffer2[a-2] 
      && iMABuffer[f] > iMABuffer2[a])
         addSignal(BUY);
   else  if(iMABuffer[f-2] > iMABuffer2[a-2] 
      && iMABuffer[f] < iMABuffer2[a])
         addSignal(SELL);
   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ema::addSignal(EmaSignals sig){
   int signalSize  = ArraySize(signals);
   ArrayResize(signals,signalSize+1);
   signals[signalSize] = sig;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaSignals Ema::getLastSignal(){
      int i = ArraySize(signals)-1;
      
      if(i>=0)
         return signals[i];
     
     return NO_SIGNAL;
   }

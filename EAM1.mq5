//+------------------------------------------------------------------+
//|                                                       EAM1LY.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//#include "ni.clasess\AccountInfo.mqh"

#include "ni\tradesignal\IchimukuSignal.mqh"


//+------------------------------------------------------------------+

// Main input parameters
input int Tenkan = 9; // Tenkan line period. The fast "moving average".
input int Kijun = 26; // Kijun line period. The slow "moving average".
input int Senkou = 52; // Senkou period. Used for Kumo (Cloud) spans.

// Class Signals

IchimukuSignal *ichimukuSignal;


// Indicator handles
int IchimokuHandle;
int ATRHandle;

//BUFER
MqlRates rates[];
double Tenkan_sen_Buffer[];
double Kijun_sen_Buffer[];
double Senkou_Span_A_Buffer[];
double Senkou_Span_B_Buffer[];
double Chinkou_Span_Buffer[];

ulong LastBars = 0;


int OnInit()  {
//---
  initIchimoku();
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete ichimukuSignal;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(copyIchimokuBuffer())
      findIchimokuSignals();
      
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Init Ichimoku Indicator                                            |
//+------------------------------------------------------------------+
int initIchimoku(){
   IchimokuHandle = iIchimoku(_Symbol, _Period, Tenkan, Kijun, Senkou);
   
   //--- vinculación de los arrays a los búfers indicadores
   SetIndexBuffer(0,Tenkan_sen_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Kijun_sen_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Senkou_Span_A_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Senkou_Span_B_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Chinkou_Span_Buffer,INDICATOR_DATA);
   
    if(IchimokuHandle==INVALID_HANDLE)
   {
      //--- avisaremos sobre el fallo y mostraremos el número del error
         PrintFormat("Fallo al crear el manejador del indicador iIchimoku ");
         //--- el trabajo del indicador se finaliza anticipadamente
         return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);

}

bool copyIchimokuBuffer(){
   int bars = Bars(_Symbol, _Period);
	
	// Trade only if new bar has arrived
	//printf("Bars:%d | LastBars:%d",bars,LastBars );
	if (LastBars != bars) LastBars = bars;
	else return (false);
	
	int calculated=BarsCalculated(IchimokuHandle);
	
	if(calculated >= Tenkan)
	   calculated = Tenkan;

      if (CopyRates(NULL, 0, 1, Kijun + 2, rates) <= 0){ 
         Print("Error copying price data ", GetLastError());
         return (false);
   }
      
   if (CopyBuffer(IchimokuHandle, 0, 0,calculated, Tenkan_sen_Buffer) < 0 )   return (false);
   if (CopyBuffer(IchimokuHandle, 1, 0,calculated, Kijun_sen_Buffer) < 0 )    return (false);
   if (CopyBuffer(IchimokuHandle, 2, 0,Kijun+1, Senkou_Span_A_Buffer) < 0 ) return (false);
   if (CopyBuffer(IchimokuHandle, 3, 0,Kijun+1, Senkou_Span_B_Buffer) < 0 ) return (false);
   if (CopyBuffer(IchimokuHandle, 4, 0,Senkou, Chinkou_Span_Buffer) < 0 ) return (false);
   
    //printf("----------------------------------");
    //printf("Informacion del indicador Ichimoku");
    //printf("Tekan Sen       =  %d",Tenkan_sen_Buffer[0]);
    //printf("Kijun Sen       =  %d",Kijun_sen_Buffer[0]);
    //printf("Senkou Span A   =  %d",Senkou_Span_A_Buffer[0]);
    //printf("Senkou Span B   =  %d",Senkou_Span_B_Buffer[0]);
    //printf("Chinkou Span    =  %d",Chinkou_Span_Buffer[0]);
    
    return (true);
}

void findIchimokuSignals(){

   if(ichimukuSignal == NULL)
      ichimukuSignal = new IchimukuSignal();
      
   ichimukuSignal.search(Tenkan_sen_Buffer,Kijun_sen_Buffer,Senkou_Span_A_Buffer,Senkou_Span_B_Buffer,Chinkou_Span_Buffer,rates);
   ichimukuSignal.toInfo();  
   
}



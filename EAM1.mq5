//+------------------------------------------------------------------+
//|                                                       EAM1LY.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//#include "ni.clasess\AccountInfo.mqh"

#include "ni\tradesignal\IchimukuSignal.mqh"
#include "ni\strategy\IchimokuStrategy.mqh"

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

//+------------------------------------------------------------------+

//Strategy
input StrategyMode strategyMode = WISE_MODE;

// Main input parameters
input int Tenkan = 9; // Tenkan line period. The fast "moving average".
input int Kijun = 26; // Kijun line period. The slow "moving average".
input int Senkou = 52; // Senkou period. Used for Kumo (Cloud) spans.

// Money management
input double Lots = 0.1; 		// Basic lot size.
input bool MM  = false;  	// MM - If true - ATR-based position sizing.
input int ATR_Period = 20;
input double ATR_Multiplier = 1;
input double Risk = 2; // Risk - Risk tolerance in percentage points.
input double FixedBalance = 0; // FixedBalance - If greater than 0, position size calculator will use it instead of actual account balance.
input double MoneyRisk = 0; // MoneyRisk - Risk tolerance in base currency.
input bool UseMoneyInsteadOfPercentage = false;
input bool UseEquityInsteadOfBalance = false;
input int LotDigits = 2; // LotDigits - How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.
input int Slippage = 100; 	// Tolerated slippage in brokers' pips.

//Class
CTrade *trade;
IchimukuSignal *ichimukuSignal; // Class Signals
IchimokuStrategy *strategy;


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


// Global variables
// Common
ulong LastBars = 0;
bool HaveLongPosition;
bool HaveShortPosition;
double StopLoss; // Not actual stop-loss - just a potential loss of MM estimation.



int OnInit()  {
//---
   trade = new CTrade;
	trade.SetDeviationInPoints(Slippage);
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
   delete trade;
   delete strategy;
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
   return (true);
}

void findIchimokuSignals(){

   if(ichimukuSignal == NULL)
      ichimukuSignal = new IchimukuSignal();
      
    if(strategy == NULL)
      strategy = new IchimokuStrategy(GetPointer(ichimukuSignal),strategyMode);  
      
   ichimukuSignal.search(Tenkan_sen_Buffer,Kijun_sen_Buffer,Senkou_Span_A_Buffer,Senkou_Span_B_Buffer,Chinkou_Span_Buffer,rates);
   ichimukuSignal.toInfo();  
   
}


//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void buy(string orderComent)
{
	double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
	trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, LotsOptimized(), Ask, 0, 0, orderComent);
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void sell(string orderComent)
{
	double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
	trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, LotsOptimized(), Bid, 0, 0, orderComent);
}


//+------------------------------------------------------------------+
//| Calculate position size depending on money management parameters.|
//+------------------------------------------------------------------+
double LotsOptimized()
{
	if (!MM) return (Lots);
	
   double Size, RiskMoney, PositionSize = 0;

   // If could not find account currency, probably not connected.
   if (AccountInfoString(ACCOUNT_CURRENCY) == "") return(-1);

   if (FixedBalance > 0)
      Size = FixedBalance;
   else if (UseEquityInsteadOfBalance)
      Size = AccountInfoDouble(ACCOUNT_EQUITY);
   else
      Size = AccountInfoDouble(ACCOUNT_BALANCE);
 
   
   if (!UseMoneyInsteadOfPercentage) 
      RiskMoney = Size * Risk / 100;
   else 
      RiskMoney = MoneyRisk;

   double UnitCost = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double TickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = NormalizeDouble(RiskMoney / (StopLoss * UnitCost / TickSize), LotDigits);

   if (PositionSize < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) PositionSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   else if (PositionSize > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)) PositionSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   return(PositionSize);
} 

//+------------------------------------------------------------------+
//| Close open position																|
//+------------------------------------------------------------------+
void ClosePrevious()
{
	for (int i = 0; i < 10; i++)
	{
		trade.PositionClose(_Symbol, Slippage);
		if ((trade.ResultRetcode() != 10008) && (trade.ResultRetcode() != 10009) && (trade.ResultRetcode() != 10010))
			Print("Position Close Return Code: ", trade.ResultRetcodeDescription());
		else return;
	}
}
//+------------------------------------------------------------------+

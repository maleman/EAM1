//+------------------------------------------------------------------+
//|                                                       EAM1LY.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//#include "ni.clasess\AccountInfo.mqh"


#include "ni\strategy\StrategyFactory.mqh"
#include "ni\strategy\EmaStrategy.mqh"
#include "ni\enum\Enums.mqh"


//+------------------------------------------------------------------+

//Strategy
//input StrategyMode strategyMode = WISE_MODE;


/*
// Main input parameters
input int Tenkan = 9; // Tenkan line period. The fast "moving average".
input int Kijun = 26; // Kijun line period. The slow "moving average".
input int Senkou = 52; // Senkou period. Used for Kumo (Cloud) spans.

// Money management
input double Lots = 0.1; 		// Basic lot size.
input bool MM  = true;  	// MM - If true - ATR-based position sizing.
input int ATR_Period = 20;
input double ATR_Multiplier = 1;
input double Risk = 2; // Risk - Risk tolerance in percentage points.
input double FixedBalance = 0; // FixedBalance - If greater than 0, position size calculator will use it instead of actual account balance.
input double MoneyRisk = 0; // MoneyRisk - Risk tolerance in base currency.
input bool UseMoneyInsteadOfPercentage = false;
input bool UseEquityInsteadOfBalance = false;
input int LotDigits = 2; // LotDigits - How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.
input int Slippage = 100; 	// Tolerated slippage in brokers' pips.

input int operationBySignal = 1;

//Class
CTrade *trade;
CPositionInfo positionInfo;
IchimukuSignal *ichimukuSignal; // Class Signals
IchimokuStrategy *strategy;
Ichimoku *ichimoku;
Adx *adx;


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

*/

input double stop_lost     = 0.0015;
input double take_profit   = 0.0015;
input double volume        = 0.10;

input ENUM_TIMEFRAMES period = PERIOD_M15;
      

EmaStrategy *emaStrategy;

int OnInit(){

   StrategyFactory sFactory = new StrategyFactory();
   emaStrategy = sFactory.getStrategy(0);
   emaStrategy.setValuesTrade(volume,stop_lost,take_profit);
   return emaStrategy.start(_Symbol,period);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   emaStrategy.onTick();
  }
//+------------------------------------------------------------------+

/*

//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void buy(string orderComent)
{
	double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
	trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, LotsOptimized(), Ask, Ask - StopLoss, Ask + StopLoss, orderComent);
	//trade.PositionModify(_Symbol, Ask - StopLoss, Ask + StopLoss);
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void sell(string orderComent)
{
	double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
	trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, LotsOptimized(), Bid, Bid + StopLoss, Bid - StopLoss, orderComent);
	//trade.PositionModify(_Symbol, Bid + StopLoss, Bid - StopLoss);

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
void closePrevious()
{
   uint total=PositionsTotal();
	for (int i = 0; i<total; i++)
	{
		trade.PositionClose(_Symbol, Slippage);
		if ((trade.ResultRetcode() != 10008) && (trade.ResultRetcode() != 10009) && (trade.ResultRetcode() != 10010))
			Print("Position Close Return Code: ", trade.ResultRetcodeDescription());
		else return;
	}
	
}
//+------------------------------------------------------------------+


*/





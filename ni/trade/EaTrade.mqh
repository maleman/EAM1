//+------------------------------------------------------------------+
//|                                                      EaTrade.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

class EaTrade
  {
private:

   CTrade *trade;
   CPositionInfo positionInfo;

public:
   EaTrade();
   ~EaTrade();
   
   void  buy(string orderComent, double vol, double sl, double tp);
   void  sell(string orderComent, double vol, double sl, double tp);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EaTrade::EaTrade(){
    if(trade == NULL)
      trade = new CTrade();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EaTrade::~EaTrade()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
EaTrade::buy(string orderComent, double vol, double sl, double tp){

   if(trade == NULL)
      trade = new CTrade();
   
	double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
	trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, vol, Ask, Ask - sl, Ask + tp, orderComent);
	//trade.PositionModify(_Symbol, Ask - StopLoss, Ask + StopLoss);
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
EaTrade::sell(string orderComent, double vol, double sl, double tp){

   if(trade == NULL)
      trade = new CTrade();
      
	double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
	trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, vol, Bid, Bid + sl, Bid - tp, orderComent);
	//trade.PositionModify(_Symbol, Bid + StopLoss, Bid - StopLoss);

}

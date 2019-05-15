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
#include "TrailingStop.mqh"
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EaTrade
  {
private:

   CTrade           *trade;
   CPositionInfo    *positionInfo;
   CSymbolInfo      *m_symbol;
   TrailingStop     *trStop;

public:
                     EaTrade();
                    ~EaTrade();

   void              buy(string symbol,string orderComent,double vol,double sl,double tp);
   void              sell(string symbol,string orderComent,double vol,double sl,double tp);

   void              traillingStop();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EaTrade::EaTrade()
  {
   if(trade== NULL)
      trade= new CTrade();

   trade.SetMarginMode();
//trade.SetTypeFillingBySymbol(m_symbol.Name());
   trade.SetDeviationInPoints(10);
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
EaTrade::buy(string symbol,string orderComent,double vol,double sl,double tp)
  {

   if(trade == NULL)
      trade = new CTrade();

   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,vol,Ask,Ask-sl,Ask+tp,orderComent);
//trade.PositionModify(_Symbol, Ask - StopLoss, Ask + StopLoss);
  }
//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
EaTrade::sell(string symbol,string orderComent,double vol,double sl,double tp)
  {

   if(trade == NULL)
      trade = new CTrade();

   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   trade.PositionOpen(symbol,ORDER_TYPE_SELL,vol,Bid,Bid+sl,Bid-tp,orderComent);
//trade.PositionModify(_Symbol, Bid + StopLoss, Bid - StopLoss);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
EaTrade::traillingStop(void)
  {
      if(m_symbol == NULL)
         m_symbol = new CSymbolInfo;
         
      if(trStop == NULL)
         trStop = new  TrailingStop(m_symbol,trade,0,0,5,5,1);
      
      trStop.onCalculate();  
  }
//+------------------------------------------------------------------+

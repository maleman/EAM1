//+------------------------------------------------------------------+
//|                                                  IchiDataSet.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\..\enum\Enums.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchiDataSet
  {
private:
   IchimokuSignals   signal;
   bool              processed;

public:
                     IchiDataSet();
                     IchiDataSet(IchimokuSignals sig,bool proc);
                    ~IchiDataSet();

   string            toString();

   IchimokuSignals getSignal(){return signal;}
   bool isProcessed(){return processed;}

   void Processed(bool proc)
     {
      if(processed!=proc)
         processed=proc;
     }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiDataSet::IchiDataSet()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiDataSet::IchiDataSet(IchimokuSignals sig,bool proc)
  {
   signal=sig;
   processed=proc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiDataSet::~IchiDataSet()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IchiDataSet::toString()
  {
   string proc=(processed)?" : TRUE ":" : FALSE ";
   return ichimokuSignalsToString(signal)+proc;
  }
//+------------------------------------------------------------------+

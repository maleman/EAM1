//+------------------------------------------------------------------+
//|                                                   EmaDataSet.mqh |
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
class EmaDataSet
  {
private:
   EmaSignals        signal;
   bool              processed;
public:
                     EmaDataSet();
                     EmaDataSet(EmaSignals sig,bool proc);
                    ~EmaDataSet();
   EmaSignals getSignal(){return signal;}
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
EmaDataSet::EmaDataSet()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaDataSet::EmaDataSet(EmaSignals sig,bool proc)
  {
   signal=sig;
   processed=proc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaDataSet::~EmaDataSet()
  {
  }
//+------------------------------------------------------------------+

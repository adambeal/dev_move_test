public without sharing class LicenseHelper {
      
      @future
      public static void SetOpportunityToSync(Id opportunityId, Id quoteId)
      {
           Opportunity opp = [Select Id, Name from Opportunity Where Id =: opportunityId];
           opp.SyncedQuoteId = quoteId;
           update opp;
      }    
}
trigger LeadToLicense on Lead (after update) {
 
  // prevent bulk processing only execute if done from the ui
  if (Trigger.new.size() == 1) 
  { 
    if (Trigger.new[0].isConverted == true && Trigger.old[0].isConverted == false) 
    {
          // if a new contact was created
          if (Trigger.new[0].ConvertedContactId != null && Trigger.new[0].ConvertedAccountId != null) 
          { 
            // insert the base license
            License__c lic = new License__c();
            lic.Name = Trigger.new[0].Company;
            lic.Account__c = Trigger.new[0].ConvertedAccountId;
            lic.Non_Profit__c = Trigger.new[0].Non_Profit__c;
            if(Trigger.new[0].License_Type__c == 'Purchase')
            {
                 lic.Purchased_Seats__c = Trigger.new[0].Number_of_Users__c;
            }           
            insert lic;     
            
            // update the license on the new account
            Account a = [Select a.Id, a.Description From Account a Where a.Id = :Trigger.new[0].ConvertedAccountId];
            a.License__c = lic.Id;
            update a;       
            
            //Fetch the standard price book
            PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :'01sd0000000Y0GgAAK' AND Product2.ProductCode = 'CCUS1'];
            
            //Get the base quote info via soql
            Opportunity opp = [SELECT Id, AccountId, Name FROM Opportunity WHERE Opportunity.Id = :trigger.new[0].ConvertedOpportunityId];
            
            //build a quote for sales
            Quote licenseQuote = new Quote();  
            licenseQuote.Name = 'QUOTE-' + opp.Name;
            licenseQuote.Opportunity = opp;
            licenseQuote.OpportunityId = opp.Id;
            licenseQuote.Non_Profit__c = Trigger.new[0].Non_Profit__c;
            licenseQuote.ContactId = Trigger.new[0].ConvertedContactId;
            licenseQuote.Pricebook2Id = '01sd0000000Y0GgAAK';
            insert licenseQuote;                 
                   
            //Build quote line item matching number of users requested
            QuoteLineItem[] quoteLineItems = new QuoteLineItem[0];            
            quoteLineItems.add(new QuoteLineItem(QuoteId = licenseQuote.Id, PricebookEntryId=priceBookEntry.Id,  UnitPrice=priceBookEntry.UnitPrice, Quantity=Trigger.new[0].Number_of_Users__c));
            insert quoteLineItems;   
   
            if(Trigger.new[0].License_Type__c == 'Purchase')
            {
                opp.StageName = 'Upsell';
            }
            update opp;
            
            LicenseHelper.SetOpportunityToSync(opp.Id, licenseQuote.Id);
             
            // get the contact to set the license user with
            Contact c = [Select c.Id, c.Description, c.Name, c.AccountId From Contact c Where c.Id = :Trigger.new[0].ConvertedContactId];           
            
            //create the license user join object
            License_Users__c licenseUser = new License_Users__c();
            licenseUser.License__c = lic.Id;
            licenseUser.Contact__c = c.Id;
            
            if(Trigger.new[0].License_Type__c == 'Purchase')
            {
                 licenseUser.Seat_Status__c = 'Active';
            }
            else
            {
                licenseUser.Seat_Status__c = 'Trial';
                licenseUser.Expiration_Date__c = date.today() + 30;
            }
            insert licenseUser;            
          } 
    }
  }    
}
@isTest (SeeAllData=false)
private class CardControllerTest 
{            
    static testMethod void SetStatusTest () 
    {  
         //create a product manager contact
         Contact pm = new Contact();
         pm.LastName = 'Broome';
         pm.FirstName = 'Harvey';
         pm.Phone = '1112223333';
         insert pm;
         
         //create test cases for each status
         Case testingCase = new Case();
         testingCase.Product_Manager__c = pm.Id;
         testingCase.Status = 'Testing';
         insert testingCase;
         
         Case roadblockedCase = new Case();
         roadblockedCase.Product_Manager__c = pm.Id;
         roadblockedCase.Status = 'Roadblocked';
         insert roadblockedCase;
         
         Case doneCase = new Case();
         doneCase.Product_Manager__c = pm.Id;
         doneCase.Status = 'Done';
         insert doneCase;
         
         Case c = new Case();
         c.Subject = 'CaseCardNotificationsTestA';
         c.Product_Manager__c = pm.Id;
         c.Status = 'Development';
         insert c;
         
         //call setStatus and change status from Development to Done
         CardController.setStatus(c.Id, 'Done');       
         
         //pull the case to assert
         List<Case> queryCase = [SELECT Id, Status from Case where Id =: c.Id];
         
         System.Debug('queryCase[0].Status:' + queryCase[0].Status);
         System.assertEquals(1, queryCase.size());
         System.assertEquals('Done', queryCase[0].Status); 
    }
    
    static testMethod void getCasesMapException () 
    {  
         //create a product manager contact
         Contact pm = new Contact();
         pm.LastName = 'Broome';
         pm.FirstName = 'Harvey';
         pm.Phone = '1112223333';
         insert pm;
         
         try
         {
             //create test case for Development status      
             Case c = new Case();
             c.Subject = 'CaseCardNotificationsTestA';
             c.Product_Manager__c = pm.Id;
             c.Status = 'Development';
             insert c;
         
        
             c.Status = 'Failure'; 
             update c;
             
             CardController.getCasesMap();
         }
         catch(Exception e)
         {
            System.debug(e.getMessage());
            Boolean exceptionThrown = e.getMessage().contains('Error') ? true : false;
            System.AssertEquals(exceptionThrown , true);
         }      
    }
}
@isTest (SeeAllData=false)
private class CaseCardNotificationsTest 
{            
    static testMethod void CaseCardNotificationsTest () 
    { 
         Test.StartTest(); 
         //create a product manager contact
         Contact pm = new Contact();
         pm.LastName = 'Broome';
         pm.FirstName = 'Harvey';
         pm.Phone = '1112223333';
         insert pm;
         
         //create test case
         Case c = new Case();
         c.Subject = 'CaseCardNotificationsTest';
         c.Product_Manager__c = pm.Id;
         c.Status = 'Testing';
         insert c;
         
         //update status to roadblocked which will fire CaseCardNotifyTrigger
         c.Status = 'Roadblocked';
         update c;
         Test.StopTest();
         
         //query for the case comment and assert that there was an error published
         List<CaseComment> caseCommentList = [SELECT Id, IsPublished, CommentBody FROM CaseComment where ParentId =: c.id];
         System.assertEquals(1, caseCommentList .size());
         System.assert(caseCommentList[0].CommentBody.Contains('Twilio notification sent'));                    
    }

     static testMethod void CaseCardNotificationsExceptionTest () 
     {
         Test.StartTest(); 
         //create test case
         Case c = new Case();
         c.Subject = 'CaseCardNotificationsTest';
         c.Status = 'Testing';
         insert c;
         
         //update status to roadblocked which will fire CaseCardNotifyTrigger
         c.Status = 'Roadblocked';
         update c;
         Test.StopTest();         
         
         //query for the case comment and assert that there was an error published
         List<CaseComment> caseCommentList = [SELECT Id, IsPublished, CommentBody FROM CaseComment where ParentId =: c.id];
         System.assertEquals(1, caseCommentList .size());
         System.assert(caseCommentList[0].CommentBody.Contains('Error')); 
    }
}
trigger CaseCardNotifyTrigger on Case (after update) {        
     for (Case caseItem : Trigger.new)
     {       
            //get the previous case values
            Case oldCase = Trigger.oldMap.get(caseItem.Id);    
            //make sure to only notify if the case has just been set to Roadblocked
            if(caseItem.Status == 'Roadblocked' && oldCase.Status != 'Roadblocked')
            {  
                CaseCardNotifications.SendAlert(caseItem.Product_Manager__c, caseItem.Id,'Case ' + caseItem.CaseNumber + ' has been changed to a status of Roadblocked');
            }
     }  
}
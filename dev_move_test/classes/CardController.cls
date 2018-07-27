public class CardController
{    
    public string messageString { get; set;}
    //Get all cases and build lists per case status then put each list in a map with status as the key
    public static Map<String, List<Case>> getCasesMap()
    {
        Map<String, List<Case>> casesMap = new Map<String, List<Case>>();
        try    
        {        
            List<Case> developmentCases = new List<Case>(); 
            List<Case> testingCases = new List<Case>(); 
            List<Case> roadblockedCases = new List<Case>(); 
            List<Case> doneCases = new List<Case>(); 
            for(Case caseItem : [select Id, Subject, Description, Status, CaseNumber from Case])
            {
                if(caseItem.Status == 'Development')
                {
                    developmentCases.add(caseItem);
                }
                if(caseItem.Status == 'Testing')
                {
                    testingCases.add(caseItem);
                }
                if(caseItem.Status == 'Roadblocked')
                {
                    roadblockedCases.add(caseItem);
                }
                if(caseItem.Status == 'Done')
                {
                    doneCases.add(caseItem);
                }       
                if(caseItem.Status == 'Failure')
                {               
                    throw new CaseCardsException('Error');
                }     
                
                System.debug('status:' + caseItem.Status + ' Id:' + caseItem.Id);
            }  
            casesMap.put('Development', developmentCases);        
            casesMap.put('Testing', testingCases); 
            casesMap.put('Roadblocked', roadblockedCases);
            casesMap.put('Done', doneCases);  
        } 
        catch(Exception e)
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are very sorry, an unexpected ' +
           ' error ocurred loading your case cards. Please ' + 
           'contact your administrator for help.'));
        }
        return casesMap;
    }
     
    //Method called by jquery drop event when card is dropped
    @remoteAction
    public static PageReference setStatus(string id, string newStatus) {
    //messageString = '2222';
        Case caseToUpdate = [select Id from Case where id =: id];        
        caseToUpdate.Status = newStatus;
        update caseToUpdate;        
        
        //iterate through all cases pulling each status key list set
        Map<String, List<Case>> caseMap = getCasesMap();
        for(String key : caseMap.keySet())
        { 
            System.debug('caseMap.keySet: ' + caseMap.keySet());
            
            //iterate through mapped caseList and find case to update
            List<Case> casesList = caseMap.get(key);  
            for(Case caseToSet : casesList)
            {
                System.debug('caseToSet: ' + caseToSet.Subject);
                if(caseToSet.Id == id)
                {                
                    //update the existing status to the new one
                    caseToSet.Status = newStatus;
                    update caseToSet;
                    System.debug('caseToSet Subject: ' + caseToSet.Subject);
                }
            }            
        }
        
         PageReference cardPage = NEW Pagereference('/apex/cards');
         cardPage.setRedirect(true);
         return cardPage;
    }     
}
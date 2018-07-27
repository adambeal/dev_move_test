public class CaseCardNotifications 
{
    @future (callout=true)
    public static void SendAlert(Id contactId, Id caseId, string message)
    {
        try
        {
            //Get phone number of user we need to notify 
            Contact caseProductManager = [Select Id, Phone from Contact where Id =: contactId];
            
            if(!String.IsBlank(caseProductManager.Phone))
            {
                //Twilio login information needed by case card project
                String account = 'AC9f86d3e6d8ecad471859a1f59c093452';
                String token = '9c8eeb92ceee8ccb2e584110a1fb66d7';
                
                TwilioRestClient client = new TwilioRestClient(account, token);
                
                //Twillio markup and params for sending the case card notification via voice
                Map<String,String> voiceParams = new Map<String,String> 
                {
                    'To'   => '+1' + caseProductManager.Phone,
                    'From' => '+18659739894',
                    'Url'  => 'http://twimlets.com/message?Message%5B0%5D=' + message.replace(' ', '%20')               
                };
          
                    
                //Twillio markup and params for sending the case card notification via sms    
                Map<String, String> smsParams = new Map<String, String>  
                { 
                   'To' => '+1' + caseProductManager.Phone,
                   'From' =>  '+18659739894',
                   'Body' => message 
                };                         
                
                if (!Test.isRunningTest()) 
                {
                    TwilioCall call = client.getAccount().getCalls().create(voiceParams);
                    TwilioSMS sms = client.getAccount().getSMSMessages().create(smsParams);                    
                }
                                
                //Log that notifications were sent
                InsertCaseComment(caseId, 'Twilio notification sent: ' + message);
            }
        }
        catch(Exception e)
        {
            //log the error in the case comment field
            InsertCaseComment(caseId, 'Error:' + e.getMessage());
        }
    }    
    
    private static void InsertCaseComment(Id caseId, string comment)
    {
        CaseComment c = new CaseComment(ParentId = caseId); 
        c.CommentBody = comment; 
        c.IsPublished = true;
        
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.EmailHeader.triggerAutoResponseEmail = false;
        dmlOptions.EmailHeader.triggerOtherEmail = false;
        dmlOptions.EmailHeader.triggerUserEmail = false; 

        database.insert(c, dmlOptions ); //insert the case comment
    }    
}
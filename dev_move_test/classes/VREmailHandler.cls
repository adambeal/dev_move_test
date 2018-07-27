global class VREmailHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
    // Create an InboundEmailResult object for returning the result of the  
    // Apex Email Service 
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String myPlainText= '';

    // Add the email plain text into the local variable  
    myPlainText = email.plainTextBody;

    // Check for existing leads with this email address   
    Lead[] leads = [SELECT Id, Name, Email
      FROM Lead
      WHERE Email = :email.fromAddress];

    if (leads.size() == 0) {
      // New Lead object to be created - set LastName and Company to
      // dummy values for simplicity
      Lead newLead = new Lead(Email = email.fromAddress, 
        LastName = 'From Email', 
        Company = 'From Email');

      // Insert a new lead
      insert newLead;    

      System.debug('New Lead record: ' + newLead );   
    } else {
      System.debug('Incoming email duplicates existing Lead record(s): ' + leads );    
    }

    // Set the result to true. No need to send an email back to the user      
    // with an error message   
    result.success = true;

    // Return the result for the Apex Email Service 
    return result;
  }
}
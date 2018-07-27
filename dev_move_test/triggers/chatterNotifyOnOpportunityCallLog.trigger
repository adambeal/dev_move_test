trigger chatterNotifyOnOpportunityCallLog on Task (before insert, before update) {

    String desiredNewLeadStatus = 'Working';

    List<Id> opportunityIds=new List<Id>();
    
    for(Task t:trigger.new){
     
            //check if the task is associated with an opportunity
            if(t.Status=='Completed' && t.Subject == 'Call' && String.valueOf(t.whatId).startsWith('006')==TRUE){
            
                opportunityIds.add(t.whatId);
            }
    }//for
    //get opportunities list to create chatter feed items for
    List<Opportunity> opportunitiesToUpdate = [SELECT Id, OwnerId FROM Opportunity WHERE Id IN:opportunityIds];    
    
    try{
          For (Opportunity o:opportunitiesToUpdate){
          
                 //post to chatter
                 List<FeedItem> posts = new List<FeedItem>();
                 String status = 'Test chatter post version 1';//opp.Owner.Name + ' just won ' + opp.Account.Name + ' for ' + opp.Amount + '!';
 
                 FeedItem post = new FeedItem(
                 ParentId = o.Id,
                 Title = o.Name,
                 Body = status
                 );
                 posts.add(post);
          }//for
            //update leadsToUpdate;
    }catch(DMLException e){
        system.debug('Chatter was not updated.  Error: '+e);
    }

}
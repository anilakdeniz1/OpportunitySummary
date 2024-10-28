/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 26/10/2024
* @description Controller Class for Opportunity Summary LWC. 
*              Fetches the sObject records and sends to the LWC in an ordered way
* Test Class : OpportunitySummaryControllerTest
* Test Class Coverage : %100
*/
public with sharing class OpportunitySummaryController {
   
    /** 
     * @descritpion Gets all the opportunity and related sObject records
     * @param opportunityId Id
     */ 
    @AuraEnabled(cacheable=true)
    public static List<SObject> getOpportunityAndRelatedObjects(Id opportunityId){

        Opportunity opportunityWithRelatedObjects = [SELECT Id ,  
                                                    (SELECT Id, CreatedDate, InsertedBy.Name, Body FROM feeds), 
                                                    (SELECT Id, CreatedDate, Incoming, IsOpened ,Subject FROM Emails), 
                                                    (SELECT Id, CreatedDate, CreatedBy.Name, StageName FROM OpportunityHistories),
                                                    (SELECT Id, SystemModstamp, ContentDocument.CreatedBy.Name, ContentDocument.Title, ContentDocument.FileType FROM ContentDocumentLinks), 
                                                    (SELECT Id, CreatedDate, Status, Owner.Name, Subject, ActivityDate FROM Tasks WHERE TaskSubType != 'Email') 
                                                    FROM Opportunity 
                                                    WHERE Id = :opportunityId];
        
        Map<DateTime, SObject> SObjectsByCreatedDates = createSObjectsByCreatedDate(opportunityWithRelatedObjects);

        return sortSObjectsByCreatedDate(SObjectsByCreatedDates);
    }

    /** 
     * @descritpion gets created dates of sObjects
     * @param relatedSObjects List<SObject>
     */ 
    private static Map<DateTime, SObject> getSObjectsMapByCreatedDates(List<SObject> relatedSObjects) {

        Map<DateTime, SObject> sObjectsMapByCreatedDates = new Map<DateTime, SObject>();

        for (SObject sObj : relatedSObjects) {
            String objectIdentifier = (String)sObj.get('Id');
            objectIdentifier = objectIdentifier.substring(0,3);
            if (objectIdentifier == '06A') { // ContentDocumentLink
                sObjectsMapByCreatedDates.put((DateTime)sObj.get('SystemModstamp'), sObj);
            } else {
                sObjectsMapByCreatedDates.put((DateTime)sObj.get('CreatedDate'), sObj);
            }    
        }

        return sObjectsMapByCreatedDates;
    }

     /** 
     * @descritpion Stores sObject records by their created dates in a map 
     * @param relatedSObjects List<SObject>
     */ 
    private static Map<DateTime, SObject> createSObjectsByCreatedDate(Opportunity opportunity) {
        Map<Datetime, SObject> relatedObjectsByCreatedDates = new Map<Datetime, SObject>();
        
        relatedObjectsByCreatedDates.putAll(getSObjectsMapByCreatedDates(getFeedItemsWithBodies(opportunity.feeds)));
        relatedObjectsByCreatedDates.putAll(getSObjectsMapByCreatedDates(opportunity.Emails));
        relatedObjectsByCreatedDates.putAll(getSObjectsMapByCreatedDates(getContentDocumentsWithoutSNote(opportunity.ContentDocumentLinks)));
        relatedObjectsByCreatedDates.putAll(getSObjectsMapByCreatedDates(opportunity.OpportunityHistories));
        relatedObjectsByCreatedDates.putAll(getSObjectsMapByCreatedDates(opportunity.Tasks));

        return relatedObjectsByCreatedDates;
    }

     /** 
     * @descritpion gets the chatter feed item if body is not null
     * @param relatedSObjects List<SObject>
     */ 
    private static List<OpportunityFeed> getFeedItemsWithBodies(List<OpportunityFeed> opportunutiyFeeds) {

        List<OpportunityFeed> validOpportunityFeedItems = new List<OpportunityFeed>();

        for (OpportunityFeed feedItem : opportunutiyFeeds) {
            if (feedItem.Body != null) {
                validOpportunityFeedItems.add(feedItem);
            }
        }

        return validOpportunityFeedItems;
    }

     /** 
     * @descritpion gets all content documents execpt SNote
     * @param relatedSObjects List<SObject>
     */ 
    private static List<ContentDocumentLink> getContentDocumentsWithoutSNote(List<ContentDocumentLink> contentDocumentLinks){

        List<ContentDocumentLink> validContentDocumentLinkItems = new List<ContentDocumentLink>();

        for (ContentDocumentLink cdl : contentDocumentLinks) {
            if (cdl.ContentDocument.FileType != 'SNOTE') {
                validContentDocumentLinkItems.add(cdl);
            }
        }
        return validContentDocumentLinkItems;
    }

     /** 
     * @descritpion sorts sObject records by their created dates
     * @param relatedSObjects List<SObject>
     */ 
    private static List<SObject> sortSObjectsByCreatedDate(Map<DateTime, SObject> SObjectsByDateTime) {

        List<DateTime> reversedCreatedDates = new List<DateTime>();

        List<DateTime> createdDateTimes = new List<DateTime>(SObjectsByDateTime.keySet());
        
        createdDateTimes.sort();

        for (integer I= createdDateTimes.size()-1; i>=0; i--){

	    	reversedCreatedDates.add(createdDateTimes.get(I));

	    }

        List<SObject> sObjects = new List<SObject>();

        for (DateTime createdDate : reversedCreatedDates) {
            sObjects.add(SObjectsByDateTime.get(createdDate));
        }

        return sObjects;
    }
}
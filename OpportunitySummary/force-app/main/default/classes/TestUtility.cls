/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 26/10/2024
* @description Contains 
*              
*/
@isTest
public class TestUtility {

    public static Opportunity createOpportunity(Id accountId) {

        Opportunity anOpportunity = new Opportunity(
            AccountId = accountId,
            Name = 'Test Opportunity ' + i,
            StageName = 'Open',
            Amount = 10000 + (i * 10000),
            CloseDate = Date.today().addDays(i),
            Probability = 75,
            LeadSource = 'Web',
            Type = 'New Business'
        );

        insert anOpportunity;

        return anOpportunity;
    }

    public static ContentDocumentLink createContentDocumentLink(Id relatedToId, Id documentId) {
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = relatedToId,    
            ContentDocumentId = documentId
        );
        insert cdl;

        return cdl;
    }

    public static ContentVersion createContentVersionWithTitleAndFileType(String title, String fileType){
        ContentVersion aContentVersion = new ContentVersion(
        	Title = Title,
            PathOnClient = Title + '.' + fileType,
            VersionData = Blob.valueOf(Title)
        );
        insert aContentVersion;
        
        return aContentVersion;
    }

    public static ContentNote createContentNote(){
        ContentNote aContentNote = new ContentNote(
			Title = 'Test Note',
            Content = Blob.valueOf('Test Content Note')
        );
        insert aContentNote;
        
        return aContentNote;
    }

    public static Task createTaskRelatedToSObject(Id relatedToId) {
        
        Task aTask = new Task(
            WhatId = relatedToId,
            Status = 'New',
            Subject = 'Test Subject',
            ActivityDate = Date.today().addDays(7)
        );

        insert aTask;

        return aTask;
    }
    
    
    public static FeedItem createFeedItem(Id opportunityId, Id userId) {
        FeedItem feedItem = new FeedItem(
            ParentId = opportunityId,
            Body = 'Test Body',
            CreatedById = userId
        );
        insert feedItem;

        return feedItem;
    }

    public static EmailMessage createEmailMessage(Id relatedId) {
        EmailMessage anEmailMessage = new EmailMessage(
            Subject = 'Test Email',
            FromAddress = 'test@example.com',
            RelatedToId = relatedId
        );
        insert anEmailMessage;

        return anEmailMessage;
    }
}
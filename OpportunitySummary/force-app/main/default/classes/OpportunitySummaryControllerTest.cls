/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 26/10/2024
* @description Test class for pdfGeneratorController
*/
public with sharing class OpportunitySummaryControllerTest {
    
    @TestSetup
    static void makeData(){

        Opportunity anOpportunity = TestUtility.createOpportunity();

        ContentNote aContentNote = TestUtility.createContentNote();
        ContentDocumentLink aCDL = TestUtility.createContentDocumentLink(anOpportunity.Id, aContentNote.Id);
        TestUtility.sleep(1000);

        ContentVersion aContentVersion = TestUtility.createContentVersionWithTitleAndFileType('Test Title', 'txt');
        ContentDocument aContentDocument = [SELECT Id, Title, FileType FROM ContentDocument WHERE LatestPublishedVersionId = :aContentVersion.Id LIMIT 1]; 
        ContentDocumentLink anotherCDL = TestUtility.createContentDocumentLink(anOpportunity.Id, aContentDocument.Id);
        TestUtility.sleep(1000);

        Task aTask = TestUtility.createTaskRelatedToSObject(anOpportunity.Id);
        TestUtility.sleep(1000);
    
        User aUser = TestUtility.createInternalUser();
        FeedItem aFeedItem = TestUtility.createFeedItem(anOpportunity.Id, aUser.Id);
        TestUtility.sleep(1000);

        EmailMessage anEmailMessage = TestUtility.createEmailMessage(anOpportunity.Id);
        TestUtility.sleep(1000);
    }

    @isTest
    static void getOpportunitySummary() {

        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        List<SObject> sObjects = OpportunitySummaryController.getOpportunityAndRelatedObjects(anOpportunity.Id);

        Test.stopTest();

        List<Case> cases = new List<Case>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<OpportunityFeed> feeds = new List<OpportunityFeed>();
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        List<OpportunityHistory> opportunityHistories = new List<OpportunityHistory>();
        List<Task> tasks = new List<Task>();

        
        for (SObject sObj : sObjects) { 
            if (sObj.getSObjectType() == Case.getSObjectType()) {
                cases.add((Case)sObj);            
            }
            if (sObj.getSObjectType() == Opportunity_Products__c.getSObjectType()) {
                opportunityProducts.add((Opportunity_Products__c)sObj);            
            }
            if (sObj.getSObjectType() == ContentDocumentLink.getSObjectType()) {
                contentDocumentLinks.add((ContentDocumentLink)sObj);            
            }
            if (sObj.getSObjectType() == OpportunityFeed.getSObjectType()) {
                feeds.add((OpportunityFeed)sObj);            
            }
            if (sObj.getSObjectType() == EmailMessage.getSObjectType()) {
                emailMessages.add((EmailMessage)sObj);            
            }
            if (sObj.getSObjectType() == Bezahlter_Betrag__c.getSObjectType()) {
                bezahlteBetrags.add((Bezahlter_Betrag__c)sObj);            
            }
            if (sObj.getSObjectType() == OpportunityHistory.getSObjectType()) {
                opportunityHistories.add((OpportunityHistory)sObj);            
            }
            if (sObj.getSObjectType() == Extra_Kosten__c.getSObjectType()) {
                extraKostens.add((Extra_Kosten__c)sObj);            
            }
            if (sObj.getSObjectType() == AttachedContentNote.getSObjectType()) {
                attachedContentNotes.add((AttachedContentNote)sObj);            
            }
            if (sObj.getSObjectType() == Task.getSObjectType()) {
                tasks.add((Task)sObj);            
            }
        }

        System.assertNotEquals(null, sObjects.size(), 'SObject list should not be null.');
        System.assertEquals(1, emailMessages.size(), '1 EmailMessage should be created.');
        //System.assertEquals(1, opportunityHistories.size(), 'SObject list should not be null.');
        System.assertEquals(1, cases.size(), '1 case should be created.');
        System.assertEquals(1, feeds.size(), '1 feed should be created.');
        System.assertEquals(1, contentDocumentLinks.size(), '1 contentVersion should be created.');  
        System.assertEquals(1, tasks.size(), '1 task should be created.');  
    }

    @isTest
    static void getOpportunitySummary_withoutEmailMessage() {

        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        EmailMessage anEmailMessage = [SELECT Id FROM EmailMessage WHERE RelatedToId = :anOpportunity.Id LIMIT 1];

        delete anEmailMessage;

        Test.startTest();

        List<SObject> sObjects = OpportunitySummaryController.getOpportunityAndRelatedObjects(anOpportunity.Id);

        Test.stopTest();

        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for (SObject sObj : sObjects) {
            if (sObj.getSObjectType() == EmailMessage.getSObjectType()) {
                emailMessages.add((EmailMessage)sObj);
            }
        }

        System.assertNotEquals(null, sObjects.size(), 'SObject list should not be null.');
        System.assertEquals(0, emailMessages.size(), 'EmailMessage should not be created.');
    }

    @isTest
    static void getOpportunitySummary_withoutOpportunityFeed() {

        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        FeedItem anOpportunityFeed = [SELECT Id FROM FeedItem WHERE ParentId = :anOpportunity.Id LIMIT 1];

        delete anOpportunityFeed;

        Test.startTest();

        List<SObject> sObjects = OpportunitySummaryController.getOpportunityAndRelatedObjects(anOpportunity.Id);

        Test.stopTest();

        List<FeedItem> opportunityFeeds = new List<FeedItem>();

        for (SObject sObj : sObjects) {
            if (sObj.getSObjectType() == FeedItem.getSObjectType()) {
                opportunityFeeds.add((FeedItem)sObj);
            }
        }
        
        System.assertNotEquals(null, sObjects.size(), 'SObject list should not be null.');
        System.assertEquals(0, opportunityFeeds.size(), 'Opportunity Feed should not be created.');
    }

    @isTest
    static void getOpportunitySummary_withoutContentDocumentLink() {

        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
       
        ContentVersion aContentVersion = [SELECT Id FROM ContentVersion WHERE Title = 'Test Title' LIMIT 1];
        ContentDocument aContentDocument = [SELECT Id, Title, FileType FROM ContentDocument WHERE LatestPublishedVersionId = :aContentVersion.Id LIMIT 1]; 
        
        delete aContentDocument;

        Test.startTest();

        List<SObject> sObjects = OpportunitySummaryController.getOpportunityAndRelatedObjects(anOpportunity.Id);

        Test.stopTest();

        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();

        for (SObject sObj : sObjects) {
            if (sObj.getSObjectType() == ContentDocumentLink.getSObjectType()) {
                CDLs.add((ContentDocumentLink)sObj);
            }
        }
        
        System.assertNotEquals(null, sObjects.size(), 'SObject list should not be null.');
        System.assertEquals(0, CDLs.size(), 'ContentDocumentLink should not be created.');
    }

    @isTest
    static void getOpportunitySummary_withoutTask() {

        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
       
        Task aTask = [SELECT Id FROM Task WHERE WhatId = :anOpportunity.Id LIMIT 1];
        
        delete aTask;

        Test.startTest();

        List<SObject> sObjects = OpportunitySummaryController.getOpportunityAndRelatedObjects(anOpportunity.Id);

        Test.stopTest();

        List<Task> tasks = new List<Task>();

        for (SObject sObj : sObjects) {
            if (sObj.getSObjectType() == Task.getSObjectType()) {
                tasks.add((Task)sObj);
            }
        }
        
        System.assertNotEquals(null, sObjects.size(), 'SObject list should not be null.');
        System.assertEquals(0, tasks.size(), 'There should be no task.');
    }
}
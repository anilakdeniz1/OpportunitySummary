import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunityAndRelatedObjects from '@salesforce/apex/OpportunitySummaryController.getOpportunityAndRelatedObjects';

const Constants = {
    EMAIL_MESSAGE_OBJECT_IDENTIFIER: '02s',
    NOTE_OBJECT_IDENTIFIER: '069',
    OPPORTUNITY_FEED_OBJECT_IDENTIFIER: '0D5',
    OPPORTUNITY_HISTORY_OBJECT_IDENTIFIER: '008',
    CONTENT_DOCUMENT_LINK_OBJECT_IDENTIFIER: '06A',
    TASK_OBJECT_IDENTIFIER: '00T'
}
export default class OpportunitySummary extends NavigationMixin(LightningElement) {
    @api recordId;
    @track opportunityData = [];
    @track datatitle = [];
    recordCreatedDate;
    constants = Constants;
     
    idCounter = 0;
   
    
    @wire(getOpportunityAndRelatedObjects, { opportunityId : '$recordId' })
    wiredOpportunityData(result){

        const { data, error } = result;

        if (data) {
            this.opportunityData = data.map(record => {

                this.idCounter++;
                
                let objectIdentifier = record.Id.substring(0,3)
                let formatedCreatedDate = objectIdentifier === this.constants.CONTENT_DOCUMENT_LINK_OBJECT_IDENTIFIER ? record.SystemModstamp.replaceAll('T',' ').replaceAll('.000Z', '') : record.CreatedDate.replaceAll('T',' ').replaceAll('.000Z', '')
                this.recordCreatedDate = this.formatDateTime(formatedCreatedDate);
                
                if (objectIdentifier === this.constants.EMAIL_MESSAGE_OBJECT_IDENTIFIER) {
                    
                    let validSubject = record.Subject != null ? (record.Subject.length > 40 ? record.Subject.substring(0, 40) + '...' : record.Subject) : 'Email'
                   
                    if (!record.Incoming)  {
                    
                        if (record.IsOpened) {
                            
                            return { id: this.idCounter, link: validSubject, title: ' sent and read.', date: this.recordCreatedDate, iconName: 'standard:email', recordId : record.Id, clickable: true, objectApiName: "EmailMessage"}
                            
                        }else {
                           
                            return { id: this.idCounter, link: validSubject, title: ' sent and not read.', date: this.recordCreatedDate, iconName: 'standard:email', recordId : record.Id, clickable: true, objectApiName: "EmailMessage"}

                        }
                    }

                 } else if(objectIdentifier === this.constants.NOTE_OBJECT_IDENTIFIER){
                    
                    let validNoteTitle = record.Title != null ? (record.Title.length > 30 ? record.Title.substring(0, 30) + '...' : record.Title) : 'Note'
                    return { id: this.idCounter, link: validNoteTitle  , title: ' created.', date: this.recordCreatedDate, iconName: 'standard:note', body: record.TextPreview, objectApiName: "ContentNote", clickable: true, recordId : record.Id}

                } else if(objectIdentifier === this.constants.OPPORTUNITY_FEED_OBJECT_IDENTIFIER){
                 
                    let validBody = record.Body.replace(/(<([^>]+)>)/gi, ""); // To remove HTML tags
                    return {id: this.idCounter, title: `${record.InsertedBy.Name} posted.`, link: 'Chatter Message', date: this.recordCreatedDate, iconName: 'standard:feed', body:validBody, objectApiName: "OpportunityFeed", clickable: true, recordId : record.Id}                           
                                                      
                } else if (objectIdentifier === this.constants.OPPORTUNITY_HISTORY_OBJECT_IDENTIFIER) {
                    
                    return { id: this.idCounter, title: `Stage is changed by ${record.CreatedBy.Name} to ${record.StageName}.`, date: this.recordCreatedDate, clickable: false, iconName: 'standard:stage', recordId : record.Id, objectApiName: "OpportunityHistory"}

                } else if (objectIdentifier === this.constants.CONTENT_DOCUMENT_LINK_OBJECT_IDENTIFIER){
                    
                    let validDocumentName = record.ContentDocument.Title != null ? (record.ContentDocument.Title.length > 30 ? record.ContentDocument.Title.substring(0, 30) + '...' : record.ContentDocument.Title) : 'Content Document'
                    return { id: this.idCounter, link: `${validDocumentName}.${record.ContentDocument.FileType.toLowerCase()}`, title: ` Uploaded by ${record.ContentDocument.CreatedBy.Name}.`, date: this.recordCreatedDate, iconName: 'standard:file', clickable: true, objectApiName: "ContentDocument", recordId : record.ContentDocumentId}

                } else if (objectIdentifier === this.constants.TASK_OBJECT_IDENTIFIER){
                    
                    let validDueDate = record.ActivityDate == null ? ' Null' : this.formatDate(record.ActivityDate)
                    let validTask = record.Subject != null ? (record.Subject.length > 30 ? record.Subject.substring(0, 30) + '...' : record.Subject) : 'Task'
                    return { id: this.idCounter, link: validTask, title: `Task is created for ${record.Owner.Name}.`, date: this.recordCreatedDate, iconName: 'standard:task', clickable: true, objectApiName: "Task", recordId : record.Id, body: `Task status is ${record.Status} and end date is ${validDueDate}.`}

                }
                 
        })

        } else if(error) {
            this.createToast('Warning', error.message, 'sticky')
        }
    }

    navigateToRecord(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.recordId;
        const objectApiName = event.currentTarget.dataset.objectApiName;

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    createToast(title, message, mode, variant) {
        const toast = new ShowToastEvent(
            {
                title,
                message,
                mode,
                variant: variant || 'error'
            }
        );
        this.dispatchEvent(toast);
    }

    formatDateTime(dateTime) {
       
        const[ datePart, TimePart ] = dateTime.split(' ');
        const[ year, month, day ] = datePart.split('-');
        const formatedDate = `${day}.${month}.${year} ${TimePart}`;

        return formatedDate;
    }

    formatDate(date) {
       
        const[ year, month, day ] = date.split('-');
        const formatedDate = `${day}.${month}.${year}`;

        return formatedDate;
    }
}
public with sharing class EventAttendanceFormController {
    @AuraEnabled
    public static Id save(Event__c event, List<Attendee__c> attendees) {
        Savepoint savepoint = Database.setSavepoint();

        try {
            Security.stripInaccessible(AccessType.CREATABLE, new List<Event__c>{ event });

            insert event;

            Security.stripInaccessible(AccessType.CREATABLE, attendees);

            upsert attendees Email__c;

            List<EventAttendance__c> eventAttendances = new List<EventAttendance__c>();
            for (Attendee__c attendee : attendees) {
                eventAttendances.add(new EventAttendance__c(Event__c = event.Id, Attendee__c = attendee.Id));
            }

            Security.stripInaccessible(AccessType.UPSERTABLE, eventAttendances);

            insert eventAttendances;

            return event.Id;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
}

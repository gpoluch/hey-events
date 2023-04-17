@IsTest
private class EventAttendanceFormControllerTest {
    @IsTest
    private static void shouldSaveSucessfully() {
        Id adminProfileId = [SELECT Id, Name FROM Profile WHERE name = 'System Administrator' LIMIT 1].Id;
        User user = TestUtils.createTestUser(adminProfileId, 'Test', 'User');
        insert user;

        Event__c expectedEvent = TestUtils.createTestEvent('Special heyCloud event');
        Attendee__c expectedAttendee = TestUtils.createTestAttendee(
            'john.doe@heycloud.com',
            Date.today().addYears(-18)
        );

        Test.startTest();
        System.runAs(user) {
            EventAttendanceFormController.save(expectedEvent, new List<Attendee__c>{ expectedAttendee });
        }
        Test.stopTest();

        List<Event__c> actualEvents = [SELECT Id, EventName__c, StartDate__c, Place__c, Description__c FROM Event__c];
        List<Attendee__c> actualAttendees = [
            SELECT Id, FirstName__c, LastName__c, DateOfBirth__c, Email__c
            FROM Attendee__c
        ];
        List<EventAttendance__c> actualEventAttendances = [SELECT Id, Event__c, Attendee__c FROM EventAttendance__c];

        System.assertEquals(false, actualEvents.isEmpty(), 'Evenets should not be empty');
        System.assertEquals(
            expectedEvent.EventName__c,
            actualEvents.get(0).EventName__c,
            'Event name should be equal to expected value'
        );
        System.assertEquals(
            expectedEvent.StartDate__c,
            actualEvents.get(0).StartDate__c,
            'Event date should be equal to expected value'
        );
        System.assertEquals(
            expectedEvent.Place__c,
            actualEvents.get(0).Place__c,
            'Event place should be equal to expected value'
        );
        System.assertEquals(
            expectedEvent.Description__c,
            actualEvents.get(0).Description__c,
            'Event description should be equal to expected value'
        );

        System.assertEquals(false, actualAttendees.isEmpty(), 'Attendees should not be empty');
        System.assertEquals(
            expectedAttendee.FirstName__c,
            actualAttendees.get(0).FirstName__c,
            'Attendee first name should be equal to expected value'
        );
        System.assertEquals(
            expectedAttendee.LastName__c,
            actualAttendees.get(0).LastName__c,
            'Attendee last name should be equal to expected value'
        );
        System.assertEquals(
            expectedAttendee.DateOfBirth__c,
            actualAttendees.get(0).DateOfBirth__c,
            'Attendee date of birth should be equal to expected value'
        );
        System.assertEquals(
            expectedAttendee.Email__c,
            actualAttendees.get(0).Email__c,
            'Attendee date of birth should be equal to expected value'
        );

        System.assertEquals(false, actualEventAttendances.isEmpty(), 'Event Attendances should not be empty');
        System.assertEquals(
            actualEvents.get(0).Id,
            actualEventAttendances.get(0).Event__c,
            'Event Id should be equal to expected value'
        );
        System.assertEquals(
            actualAttendees.get(0).Id,
            actualEventAttendances.get(0).Attendee__c,
            'Attendee Id should be equal to expected value'
        );
    }

    @IsTest
    private static void shoudThrowValiation() {
        Id adminProfileId = [SELECT Id, Name FROM Profile WHERE name = 'System Administrator' LIMIT 1].Id;
        User user = TestUtils.createTestUser(adminProfileId, 'Test', 'User');
        insert user;

        Event__c expectedEvent = TestUtils.createTestEvent('Special heyCloud event');
        Attendee__c expectedAttendee = TestUtils.createTestAttendee('john.doe@heycloud.com', Date.today());

        Exception actualException;

        Test.startTest();
        System.runAs(user) {
            try {
                EventAttendanceFormController.save(expectedEvent, new List<Attendee__c>{ expectedAttendee });
            } catch (AuraHandledException ex) {
                actualException = ex;
            }
        }
        Test.stopTest();

        List<Event__c> actualEvents = [SELECT Id, Name, StartDate__c, Place__c, Description__c FROM Event__c];

        System.assertEquals(true, actualEvents.isEmpty(), 'Evenets should be empty');
        System.assert(
            actualException.getMessage().contains('Attendee cannot be under 18 years old'),
            'Exception message should contains expected value'
        );
    }

    @IsTest
    private static void shoudThrowAccess() {
        Id readOnlyProfileId = [SELECT Id, Name FROM Profile WHERE name = 'Read Only' LIMIT 1].Id;
        User user = TestUtils.createTestUser(readOnlyProfileId, 'Test', 'User');
        insert user;

        Event__c expectedEvent = TestUtils.createTestEvent('Special heyCloud event');
        Attendee__c expectedAttendee = TestUtils.createTestAttendee(
            'john.doe@heycloud.com',
            Date.today().addYears(-18)
        );

        Exception actualException;

        Test.startTest();
        System.runAs(user) {
            try {
                EventAttendanceFormController.save(expectedEvent, new List<Attendee__c>{ expectedAttendee });
            } catch (AuraHandledException ex) {
                actualException = ex;
            }
        }
        Test.stopTest();

        System.assert(
            actualException.getMessage().contains('No access to entity'),
            'Exception message should contains expected value'
        );
    }
}

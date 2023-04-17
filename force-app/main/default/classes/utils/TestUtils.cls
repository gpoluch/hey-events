public with sharing class TestUtils {
    public static User createTestUser(Id profileID, String firstName, String lastName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User user = new User(
            firstname = firstName,
            lastName = lastName,
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileID
        );
        return user;
    }

    public static Event__c createTestEvent(String name) {
        Event__c event = new Event__c(
            EventName__c = name,
            StartDate__c = System.today(),
            Place__c = 'http://www.heycloud.com/events/special/meeting',
            Description__c = 'Salesforce event'
        );
        return event;
    }

    public static Attendee__c createTestAttendee(String email, Date dateOfBirth) {
        Attendee__c attendee = new Attendee__c(
            FirstName__c = 'Test',
            LastName__c = 'Attendee',
            Email__c = email,
            DateOfBirth__c = dateOfBirth
        );
        return attendee;
    }
}

public with sharing class ResidentDashboardController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getResidentData() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Map<String, Object> result = new Map<String, Object>();

        List<Booking__c> bookings = [SELECT Id, Room__r.Name, Room__r.Type__c, Start_Date__c, End_Date__c 
                                     FROM Booking__c 
                                     WHERE Resident__c = :contactId AND Status__c = 'Active' LIMIT 1];
        result.put('booking', bookings.isEmpty() ? null : bookings[0]);

        result.put('invoices', [SELECT Id, Name, Amount__c, Due_Date__c, Status__c 
                                FROM Invoice__c 
                                WHERE Resident__c = :contactId 
                                ORDER BY Due_Date__c DESC LIMIT 5]);
        
        return result;
    }
}
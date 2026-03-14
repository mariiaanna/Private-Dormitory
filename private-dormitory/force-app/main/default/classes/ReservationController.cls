public with sharing class ReservationController {
    
    @AuraEnabled(cacheable=true)
    public static List<Inventory__c> getAvailableInventory() {
        return [SELECT Id, Name FROM Inventory__c WHERE Status__c = 'Working' ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableSlots(Id inventoryId, Date selectedDate) {
        List<String> allSlots = new List<String>{
            '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', 
            '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
        };

        Datetime startOfDay = Datetime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
        Datetime endOfDay = Datetime.newInstance(selectedDate, Time.newInstance(23, 59, 59, 999));

        List<Reservation__c> existingReservations = [
            SELECT Start_Time__c, End_Time__c 
            FROM Reservation__c 
            WHERE Inventory__c = :inventoryId 
            AND Status__c != 'Cancelled'
            AND Start_Time__c >= :startOfDay 
            AND Start_Time__c <= :endOfDay
        ];

        List<String> availableSlots = new List<String>();
        for (String slot : allSlots) {
            Time slotTime = Time.newInstance(Integer.valueOf(slot.substring(0, 2)), 0, 0, 0);
            Datetime slotDt = Datetime.newInstance(selectedDate, slotTime);
            
            Boolean isBusy = false;
            for (Reservation__c res : existingReservations) {
                if (slotDt >= res.Start_Time__c && slotDt < res.End_Time__c) {
                    isBusy = true;
                    break;
                }
            }
            if (!isBusy) {
                availableSlots.add(slot);
            }
        }
        return availableSlots;
    }

    @AuraEnabled
    public static void createReservation(Id inventoryId, String startIsoString, Integer hours) {
        String jsonDate = '"' + startIsoString + '"';
        Datetime startDt = (Datetime)JSON.deserialize(jsonDate, Datetime.class);
        
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (u.ContactId == null) {
            throw new AuraHandledException('Current user is not a Resident (Contact missing).');
        }

        insert new Reservation__c(
            Inventory__c = inventoryId,
            Resident__c = u.ContactId,
            Start_Time__c = startDt,
            End_Time__c = startDt.addHours(hours),
            Status__c = 'Scheduled'
        );
    }
}
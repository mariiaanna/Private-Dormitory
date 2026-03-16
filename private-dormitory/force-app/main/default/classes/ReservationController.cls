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
    @AuraEnabled(cacheable=true)
    public static List<Reservation__c> getMyReservations() {
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (u.ContactId == null) return new List<Reservation__c>();

        return [SELECT Id, Inventory__r.Name, Start_Time__c, End_Time__c, Status__c 
                FROM Reservation__c 
                WHERE Resident__c = :u.ContactId 
                AND Status__c = 'Scheduled'
                AND Start_Time__c >= :Datetime.now()
                ORDER BY Start_Time__c ASC];
    }

    @AuraEnabled
    public static void cancelReservation(Id resId) {
        Reservation__c res = [SELECT Id, Start_Time__c, Status__c FROM Reservation__c WHERE Id = :resId LIMIT 1];
        
        Long diffInMinutes = (res.Start_Time__c.getTime() - DateTime.now().getTime()) / 60000;
        
        if (diffInMinutes < 30) {
            throw new AuraHandledException('Too late to cancel! Reservations must be cancelled at least 30 minutes before the start.');
        }

        res.Status__c = 'Cancelled';
        update res;
    }
}
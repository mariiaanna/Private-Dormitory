public with sharing class ReservationHelper {
    public static void checkConflicts(List<Reservation__c> newList) {
        Set<Id> inventoryIds = new Set<Id>();
        for (Reservation__c res : newList) {
            if (res.Inventory__c != null) inventoryIds.add(res.Inventory__c);
        }

        List<Reservation__c> existingReservations = [
            SELECT Id, Start_Time__c, End_Time__c, Inventory__c 
            FROM Reservation__c 
            WHERE Inventory__c IN :inventoryIds 
            AND Status__c != 'Cancelled'
            AND Id NOT IN :newList 
        ];

        for (Reservation__c newRes : newList) {
            for (Reservation__c existing : existingReservations) {
                if (newRes.Inventory__c == existing.Inventory__c) {
                    if (newRes.Start_Time__c < existing.End_Time__c && newRes.End_Time__c > existing.Start_Time__c) {
                        newRes.addError('Conflict! This item is already booked from ' + 
                                       existing.Start_Time__c.format('HH:mm') + ' to ' + 
                                       existing.End_Time__c.format('HH:mm'));
                        break; 
                    }
                }
            }
        }
    }
}
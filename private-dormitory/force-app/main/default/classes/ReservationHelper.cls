public with sharing class ReservationHelper {
    public static void validateAndCheckConflicts(List<Reservation__c> newList) {
        Set<Id> inventoryIds = new Set<Id>();
        for (Reservation__c res : newList) {
            if (res.Inventory__c != null) inventoryIds.add(res.Inventory__c);
        }

        Map<Id, Inventory__c> invMap = new Map<Id, Inventory__c>([
            SELECT Id, Status__c FROM Inventory__c WHERE Id IN :inventoryIds
        ]);

        for (Reservation__c res : newList) {
            Inventory__c inv = invMap.get(res.Inventory__c);
            if (inv != null && inv.Status__c != 'Working') {
                res.addError('This item is currently unavailable for reservation. Status: ' + inv.Status__c);
            }
        }

        checkConflicts(newList);
    }

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
            if (newRes.Start_Time__c == null || newRes.End_Time__c == null) continue;
            
            for (Reservation__c existing : existingReservations) {
                if (newRes.Inventory__c == existing.Inventory__c) {
                    if (newRes.Start_Time__c < existing.End_Time__c && newRes.End_Time__c > existing.Start_Time__c) {
                        newRes.addError('Conflict! Item already reserved from' + 
                                       existing.Start_Time__c.format('HH:mm') + ' to ' + 
                                       existing.End_Time__c.format('HH:mm'));
                        break; 
                    }
                }
            }
        }
    }
}
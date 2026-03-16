public with sharing class BookingHelper {
    
    public static void checkRoomAvailability(List<Booking__c> newList) {
        Set<Id> roomIds = new Set<Id>();
        for (Booking__c b : newList) {
            if (b.Room__c != null) roomIds.add(b.Room__c);
        }

        if (roomIds.isEmpty()) return;

        Map<Id, Room__c> roomsMap = new Map<Id, Room__c>([
            SELECT Id, Needs_Maintenance__c FROM Room__c WHERE Id IN :roomIds
        ]);

        for (Booking__c b : newList) {
            Room__c targetRoom = roomsMap.get(b.Room__c);
            if (targetRoom != null && targetRoom.Needs_Maintenance__c) {
                b.addError('This room is currently out of service (Needs Maintenance).');
            }
        }
    }

    public static void updateResidentStatus(List<Booking__c> newList) {
        Set<Id> contactIds = new Set<Id>();
        for (Booking__c b : newList) {
            if (b.Resident__c != null) contactIds.add(b.Resident__c);
        }

        if (contactIds.isEmpty()) return;

        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id cid : contactIds) {
            contactsToUpdate.add(new Contact(Id = cid, Status__c = 'Active'));
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}
public with sharing class BookingHandler extends TriggerHandler{
    List<Booking__c> newBookings = (List<Booking__c>) Trigger.new;

    override public void beforeInsert() {
        BookingHelper.checkRoomAvailability(newBookings);
    }

    override public void afterInsert() {
        BookingHelper.updateResidentStatus(newBookings);
    }
}
trigger BookingTrigger on Booking__c (before insert, after insert) {
    new BookingHandler().run();
}
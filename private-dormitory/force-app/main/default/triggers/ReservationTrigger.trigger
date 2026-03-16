trigger ReservationTrigger on Reservation__c (before insert, before update) {
    new ReservationHandler().run();
}
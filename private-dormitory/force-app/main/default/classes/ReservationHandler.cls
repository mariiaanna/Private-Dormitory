public with sharing class ReservationHandler extends TriggerHandler {
    List<Reservation__c> newReservations = (List<Reservation__c>) Trigger.new;

    override public void beforeInsert() {
        ReservationHelper.checkConflicts(newReservations);
    }

    override public void beforeUpdate() {
        ReservationHelper.checkConflicts(newReservations);
    }
}
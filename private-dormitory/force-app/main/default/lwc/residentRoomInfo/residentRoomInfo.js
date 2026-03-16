import { LightningElement, wire, track } from 'lwc';
import getResidentData from '@salesforce/apex/ResidentDashboardController.getResidentData';

export default class ResidentRoomInfo extends LightningElement {
    @track booking;
    @track isLoading = true;

    @wire(getResidentData)
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.booking = data.booking;
        } else if (error) {
            console.error('Error fetching room data:', error);
            this.booking = null;
        }
    }

    get hasBooking() {
        return !!this.booking;
    }

    get roomType() {
        return this.booking && this.booking.Room__r ? this.booking.Room__r.Type__c : 'N/A';
    }
}
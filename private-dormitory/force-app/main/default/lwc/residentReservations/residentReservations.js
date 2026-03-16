import { LightningElement, wire, track } from 'lwc';
import getMyReservations from '@salesforce/apex/ReservationController.getMyReservations';
import cancelReservation from '@salesforce/apex/ReservationController.cancelReservation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ResidentReservations extends LightningElement {
    @track reservations;
    wiredData;

    @wire(getMyReservations)
    wiredRes(result) {
        this.wiredData = result;
        if (result.data) {
            this.reservations = result.data.map(res => ({
                ...res,
                formattedTime: `${new Date(res.Start_Time__c).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})} - ${new Date(res.End_Time__c).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}`
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    handleCancel(event) {
        const resId = event.target.dataset.id;
        const res = this.reservations.find(r => r.Id === resId);
        
        const startTime = new Date(res.Start_Time__c);
        const now = new Date();
        const diff = (startTime - now) / 60000;

        if (diff < 30) {
            this.showToast('Error', 'Too late to cancel! Minimum 30 minutes notice required.', 'error');
            return;
        }

        cancelReservation({ resId })
            .then(() => {
                this.showToast('Success', 'Reservation cancelled successfully', 'success');
                return refreshApex(this.wiredData);
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
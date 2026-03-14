import { LightningElement, track, wire } from 'lwc';
import getAvailableInventory from '@salesforce/apex/ReservationController.getAvailableInventory';
import getAvailableSlots from '@salesforce/apex/ReservationController.getAvailableSlots';
import createReservation from '@salesforce/apex/ReservationController.createReservation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InventoryReservation extends LightningElement {
    @track selectedInventory;
    @track selectedDate;
    @track rawSlots = [];
    @track selectedSlots = [];
    @track inventoryOptions = [];

    minDate = new Date().toISOString().split('T')[0];

    @wire(getAvailableInventory)
    wiredInventory({ data, error }) {
        if (data) {
            this.inventoryOptions = data.map(item => ({ label: item.Name, value: item.Id }));
        }
    }

    get slots() {
        return this.rawSlots.map(time => {
            let isSelected = this.selectedSlots.includes(time);
            return {
                time: time,
                btnClass: isSelected ? 'slds-button slds-button_brand slds-m-around_xx-small' 
                                   : 'slds-button slds-button_outline-brand slds-m-around_xx-small'
            };
        });
    }

    get isReady() {
        return this.selectedInventory && this.selectedDate && this.selectedSlots.length > 0;
    }

    get reservationTimeRange() {
        if (this.selectedSlots.length === 0) return '';
        let sorted = [...this.selectedSlots].sort();
        return sorted.length === 1 ? sorted[0] : `${sorted[0]} - ${sorted[1]}`;
    }

    handleInventoryChange(event) {
        this.selectedInventory = event.detail.value;
        this.resetSlots();
        this.fetchSlots();
    }

    handleDateChange(event) {
        this.selectedDate = event.detail.value;
        this.resetSlots();
        this.fetchSlots();
    }

    resetSlots() {
        this.selectedSlots = [];
        this.rawSlots = [];
    }

    fetchSlots() {
        if (this.selectedInventory && this.selectedDate) {
            getAvailableSlots({ inventoryId: this.selectedInventory, selectedDate: this.selectedDate })
                .then(result => { this.rawSlots = result; })
                .catch(error => console.error(error));
        }
    }

    handleSlotSelect(event) {
        const time = event.target.dataset.time;
        if (this.selectedSlots.includes(time)) {
            this.selectedSlots = this.selectedSlots.filter(s => s !== time);
        } else {
            if (this.selectedSlots.length < 2) {
                this.selectedSlots = [...this.selectedSlots, time].sort();
            } else {
                this.selectedSlots = [time];
            }
        }
    }

    handleReservation() {
        const sorted = [...this.selectedSlots].sort();
        const startIso = `${this.selectedDate}T${sorted[0]}:00.000Z`;
        const duration = sorted.length; // 1 або 2 години

        createReservation({ 
            inventoryId: this.selectedInventory, 
            startIsoString: startIso, 
            hours: duration 
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Успіх!',
                message: 'Інвентар заброньовано',
                variant: 'success'
            }));
            this.resetSlots();
            this.fetchSlots();
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Помилка',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }
}
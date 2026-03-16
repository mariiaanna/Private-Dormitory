import { LightningElement, wire, track } from 'lwc';
import getResidentData from '@salesforce/apex/ResidentDashboardController.getResidentData';

export default class ResidentInvoices extends LightningElement {
    @track invoices = [];
    @track isLoading = true;

    @wire(getResidentData)
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data && data.invoices) {
            this.invoices = data.invoices.map(inv => {
                let statusClass = '';
                let statusLabel = inv.Status__c;

                if (inv.Status__c === 'Paid') {
                    statusClass = 'success';
                } else if (inv.Status__c === 'Overdue') {
                    statusClass = 'error';
                } else {
                    statusClass = 'warning'; 
                }

                return {
                    ...inv,
                    badgeVariant: statusClass,
                    formattedAmount: new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD'
                    }).format(inv.Amount__c)
                };
            });
        } else if (error) {
            console.error('Error fetching invoices:', error);
        }
    }

    get hasInvoices() {
        return this.invoices && this.invoices.length > 0;
    }
}
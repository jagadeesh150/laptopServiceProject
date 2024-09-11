import { LightningElement, api, track, wire } from 'lwc';
import getDefectReports from '@salesforce/apex/DefectReportTableController.getDefectReports';
import getAllDefectReports from '@salesforce/apex/DefectReportTableController.getAllDefectReports';
import updateDefectStatus from '@salesforce/apex/DefectReportTableController.updateDefectStatus';

export default class DefectReportTable extends LightningElement {
    @api recordId; // This will be either the Customer Contact ID, Technician ID, or undefined for all records
    @track defectReports = [];
    @track error;
    @track isLoading = true;

    // Define status options for the combobox
    get statusOptions() {
        return [
            { label: 'Open', value: 'Open' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    // Boolean flags for template
    get hasDefectReports() {
        return this.defectReports.length > 0;
    }

    get hasError() {
        return !!this.error;
    }

    get noDefectReports() {
        return !this.isLoading && !this.hasDefectReports && !this.hasError;
    }

    get errorMessage() {
        return this.error ? this.error.body.message : '';
    }

    connectedCallback() {
        this.fetchDefectReports();
    }

    // Fetch defect reports based on the recordId or fetch all
    fetchDefectReports() {
        this.isLoading = true;

        if (!this.recordId) {
            // If no recordId is provided, fetch all defect reports
            getAllDefectReports()
                .then(data => {
                    this.defectReports = data;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.defectReports = [];
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            // If a recordId is provided, fetch defect reports related to that ID (Customer Contact or Technician)
            getDefectReports({ recordId: this.recordId })
                .then(data => {
                    this.defectReports = data;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.defectReports = [];
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    // Handle status change event from combobox
    handleStatusChange(event) {
        const defectId = event.target.dataset.id;
        const newStatus = event.detail.value;

        // Call the Apex method to update status
        updateDefectStatus({ defectId: defectId, newStatus: newStatus })
            .then(() => {
                this.fetchDefectReports(); // Refresh the data after the update
            })
            .catch(error => {
                this.error = error;
            });
    }
}
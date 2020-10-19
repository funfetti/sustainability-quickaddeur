import { LightningElement, api, wire, track} from 'lwc';
import getEurList from '@salesforce/apex/sustain_eurHelper.getEurList';
import createJunctions from '@salesforce/apex/sustain_eurHelper.createJunctions';

export default class eurtable extends LightningElement {
    @track columns = [
    {
        label: 'Energy Use Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Start Date',
        fieldName: 'sustain_app__StartDate__c',
        type: 'date',
        sortable: true 
    },
    {
        label: 'End Date',
        fieldName: 'sustain_app__EndDate__c',
        type: 'date',
        sortable: true 
    },
    {
        label: 'Id',
        fieldName: 'Id',
        type: 'string',
        sortable: true
    }
    ];

    @api recordId;
    @track error;
    @track eurList; 
    @wire( getEurList, {cf: '$recordId'} )
    wiredEurs({error, data}){
        if (data) {this.eurList = data;} 
        else if (error) {this.error = error;}
    }

    message; 

    handleButtonClick(event){
        console.log('button clicked');
        var t = this.template.querySelector('lightning-datatable');
        var selected = t.getSelectedRows();
        console.log(selected);

        // i can't figure out how to pass a list of sobjects so i gotta parse them to ids

        var eursToPair = [];
        var row;
        for (row of selected){
            console.log('for loop ' + row);
            eursToPair.push(row.Id);
        }

        console.log(eursToPair);

        createJunctions({toPair: eursToPair, cf: this.recordId})
            .then((result) => {
                this.message = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.message = error;
                this.error = error;
            });

        // need to add some kind of table refresh 
    }
}
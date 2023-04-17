import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import save from '@salesforce/apex/EventAttendanceFormController.save';
import ErrorWhileAddingEventAttendee from '@salesforce/label/c.ErrorWhileAddingEventAttendee';
import ErrorUponEventAttendanceCreation from '@salesforce/label/c.ErrorUponEventAttendanceCreation';
import AttendeeCannotBeUnder18YearsOld from '@salesforce/label/c.AttendeeCannotBeUnder18YearsOld';
import AttendeeWithEmailAlreadyExists from '@salesforce/label/c.AttendeeWithEmailAlreadyExists';
import EventCreatedSuccessfully from '@salesforce/label/c.EventCreatedSuccessfully';
import EventAttendanceWizard from '@salesforce/label/c.EventAttendanceWizard';
import CheckCreatedEvent from '@salesforce/label/c.CheckCreatedEvent';
import EventInformation from '@salesforce/label/c.EventInformation';
import EventDateAndTime from '@salesforce/label/c.EventDateAndTime';
import ViewEvent from '@salesforce/label/c.ViewEvent';
import Finish from '@salesforce/label/c.Finish';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';

export default class EventAttendanceForm extends NavigationMixin(LightningElement) {
    @track currentStep = '1';
    @track eventName;
    @track event = {};
    @track attendee = {};
    @track attendees = [];

    labels = {
        errorUponEventAttendanceCreation: ErrorUponEventAttendanceCreation,
        attendeeCannotBeUnder18YearsOld: AttendeeCannotBeUnder18YearsOld,
        attendeeWithEmailAlreadyExists: AttendeeWithEmailAlreadyExists,
        errorWhileAddingEventAttendee: ErrorWhileAddingEventAttendee,
        eventCreatedSuccessfully: EventCreatedSuccessfully,
        eventAttendanceWizard: EventAttendanceWizard,
        checkCreatedEvent: CheckCreatedEvent,
        eventInformation: EventInformation,
        eventDateAndTime: EventDateAndTime,
        viewEvent: ViewEvent,
        finish: Finish,
        back: Back,
        next: Next
    };

    handleOnStepClick(event) {
        this.currentStep = event.target.value;
    }

    get isStepOne() {
        return this.currentStep === '1';
    }

    get isStepTwo() {
        return this.currentStep === '2';
    }

    get isStepThree() {
        return this.currentStep === '3';
    }

    handleNext() {
        this.currentStep = `${++this.currentStep}`;
    }

    handlePrev() {
        this.currentStep = `${--this.currentStep}`;
    }

    handleOnSubmitEvent(event) {
        event.preventDefault();
        this.event = event.detail.fields;
    }

    handleOnSubmitAttendee(event) {
        event.preventDefault();
        this.attendee = event.detail.fields;

        if (this.attendee.Email__c) {
            const attendeeExists = this.attendees.some(
                (el) => el.Email__c.toLowerCase() === this.attendee.Email__c.toLowerCase()
            );

            if (attendeeExists) {
                const toastEvent = new ShowToastEvent({
                    title: this.labels.errorWhileAddingEventAttendee,
                    message: this.interpolate(this.labels.attendeeWithEmailAlreadyExists, [this.attendee.Email__c]),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvent);
            } else {
                const hasEighteen =
                    new Date().getFullYear() - new Date(this.attendee.DateOfBirth__c).getFullYear() >= 18;

                if (hasEighteen) {
                    this.attendee = Object.fromEntries(Object.keys(this.attendee).map((key) => [key, null]));
                    this.attendees.push(event.detail.fields);
                } else {
                    const toastEvent = new ShowToastEvent({
                        title: this.labels.errorWhileAddingEventAttendee,
                        message: this.labels.attendeeCannotBeUnder18YearsOld,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
    }

    handleFinish() {
        save({ event: this.event, attendees: this.attendees })
            .then((result) => {
                this.currentStep = '3';
                this.event.Id = result;
                console.log(result);
                const toastEvent = new ShowToastEvent({
                    title: this.labels.eventCreatedSuccessfully,
                    message: this.labels.checkCreatedEvent,
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvent);
            })
            .catch((error) => {
                const toastEvent = new ShowToastEvent({
                    title: this.labels.errorUponEventAttendanceCreation,
                    message: error.message,
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvent);
            });
    }

    handleEventView(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Event__c',
                actionName: 'view'
            }
        });
    }

    interpolate(str, values) {
        return str.replace(/{([^{}]*)}/g, (match, key) => values[key.trim()] || match);
    }
}

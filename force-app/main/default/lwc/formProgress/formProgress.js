import { LightningElement, api } from 'lwc';
import FirstStep from '@salesforce/label/c.FirstStep';
import SecondStep from '@salesforce/label/c.SecondStep';
import FinalStep from '@salesforce/label/c.FinalStep';

export default class FormProgress extends LightningElement {
    @api currentStep;

    labels = {
        firstStep: FirstStep,
        secondStep: SecondStep,
        finalStep: FinalStep
    };
}

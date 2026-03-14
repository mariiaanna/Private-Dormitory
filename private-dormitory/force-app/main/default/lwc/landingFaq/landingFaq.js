import { LightningElement } from 'lwc';

export default class LandingFaq extends LightningElement {
    faqs = [
        { q: 'Are pets allowed?', a: 'Unfortunately, pets are not allowed according to our rules.' },
        { q: 'What documents are required?', a: 'Passport, tax ID, and university enrollment certificate.' },
        { q: 'Is there a curfew?', a: 'No, residents have 24/7 access with electronic key cards.' }
    ];
}
import { LightningElement, api } from 'lwc';
import HERO_IMAGE from '@salesforce/resourceUrl/heroImg'; 
export default class LandingHero extends LightningElement {
    @api imageUrl;
    @api mainTitle;
    @api subTitle;

    get backgroundStyle() {
        const imgUrl = this.imageUrl ? this.imageUrl : HERO_IMAGE;
        return `background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('${imgUrl}');`;
    }
}
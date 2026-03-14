import { LightningElement, api } from 'lwc';

export default class LandingBenefits extends LightningElement {
    // Масив даних, який твій HTML перебирає через for:each
    benefits = [
        { 
            icon: '🚀', 
            title: 'High-Speed Wi-Fi', 
            description: 'Stable internet throughout the dormitory for your studies and entertainment.' 
        },
        { 
            icon: '🛡️', 
            title: '24/7 Security', 
            description: 'Video surveillance and professional security for your peace of mind.' 
        },
        { 
            icon: '☕', 
            title: 'Lounge Zone', 
            description: 'A space for socializing, meeting new people, and relaxing after classes.' 
        },
        { 
            icon: '🧺', 
            title: 'Laundry Room', 
            description: 'Modern equipment available at any time right inside the building.' 
        }
    ];
}
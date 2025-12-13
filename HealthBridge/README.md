# HealthBridge iOS App

A native iOS application designed to help refugees, asylum seekers, undocumented individuals, and immigrants navigate the US healthcare system.

## Features

### Personalized Onboarding
The app starts with a comprehensive onboarding flow that asks about:
- **Language preference** - Supports 12+ languages
- **Immigration status** - Refugee, Asylum Seeker, Undocumented, Visa Holder, etc.
- **Housing situation** - Including options for homeless or shelter
- **Personal information** - Name, country of origin, family situation
- **Health needs** - What type of care they're looking for
- **Insurance status** - With guidance on available options
- **Location** - To find nearby clinics

### Personalized Dashboard
Based on the user's answers, the dashboard shows:
- Recommended clinics and services
- Upcoming appointments
- Emergency contact information (911, 988)
- Quick actions for finding care
- Health tips relevant to their situation

### Clinic Finder
- **Map and list views** of nearby clinics
- **Smart filtering** based on user status (refugee clinics, free clinics, etc.)
- **Detailed clinic information**:
  - Services offered
  - Languages spoken
  - Whether they accept uninsured patients
  - Sliding scale fees
  - Interpreter availability
  - Operating hours
- **One-tap calling and directions**

### Appointment Scheduling
- Book appointments at any clinic
- Request interpreter services
- Request transportation assistance
- Track upcoming and past appointments
- Appointment reminders

### Healthcare Education ("Learn")
Educational content including:
- Understanding the healthcare system
- Your rights as a patient (interpreter services, emergency care, privacy)
- Insurance guide
- Emergency care guide
- Preventive care
- Mental health resources
- Women's and children's health

## Technical Details

### Built With
- **SwiftUI** - Modern declarative UI framework
- **MapKit** - For clinic mapping
- **CoreLocation** - For location services
- **UserDefaults** - For local data persistence

### Requirements
- iOS 16.0+
- Xcode 15.0+

### Project Structure
```
HealthBridge/
├── HealthBridgeApp.swift          # App entry point
├── ContentView.swift              # Main navigation
├── Models/
│   ├── UserProfile.swift          # User data model with all status enums
│   ├── Clinic.swift               # Clinic data model
│   └── Appointment.swift          # Appointment model & manager
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── LanguageSelectionView.swift
│   │   ├── StatusSelectionView.swift
│   │   ├── HousingSelectionView.swift
│   │   ├── PersonalInfoView.swift
│   │   ├── HealthNeedsView.swift
│   │   ├── InsuranceView.swift
│   │   ├── LocationView.swift
│   │   └── OnboardingCompleteView.swift
│   ├── Dashboard/
│   │   ├── MainTabView.swift
│   │   └── DashboardView.swift
│   ├── Clinics/
│   │   └── ClinicFinderView.swift
│   ├── Appointments/
│   │   └── AppointmentsView.swift
│   └── Learn/
│       └── LearnView.swift
└── Info.plist
```

### Key Models

**ImmigrationStatus** options:
- Refugee
- Asylum Seeker
- Undocumented
- Visa Holder
- Green Card Holder
- Citizen
- Other

**HousingStatus** options:
- Stable Housing
- Temporary Housing
- Shelter
- Currently Homeless
- Other

## Getting Started

1. Open `HealthBridge.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on simulator or device

## Privacy & Security

- All user data is stored locally on the device
- No data is sent to external servers
- Location is only used to find nearby clinics
- The app emphasizes that clinics are "sensitive locations" where immigration enforcement is limited

## App Store Submission

Before submitting to the App Store:
1. Add your Apple Developer Team ID
2. Create app icons (1024x1024)
3. Add screenshots for various device sizes
4. Write App Store description and keywords
5. Set up App Store Connect listing

## Future Enhancements

- [ ] Real clinic database integration (HRSA API)
- [ ] Push notification reminders
- [ ] Offline mode support
- [ ] More language translations
- [ ] Voice navigation
- [ ] Telehealth appointment booking
- [ ] Document storage (insurance cards, medical records)

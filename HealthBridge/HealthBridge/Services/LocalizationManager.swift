import Foundation
import SwiftUI

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
        }
    }

    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    func localized(_ key: String) -> String {
        return LocalizedStrings.get(key, language: currentLanguage)
    }
}

// MARK: - Localized Strings Database
struct LocalizedStrings {
    static func get(_ key: String, language: String) -> String {
        let strings = language == "es" ? spanishStrings : englishStrings
        return strings[key] ?? englishStrings[key] ?? key
    }

    // MARK: - English Strings
    static let englishStrings: [String: String] = [
        // Welcome & Onboarding
        "welcome_to": "Welcome to",
        "app_name": "HealthBridge",
        "app_tagline": "Your guide to healthcare in a new country",
        "lets_get_started": "Let's Get Started",
        "continue": "Continue",
        "back": "Back",
        "skip": "Skip",
        "done": "Done",

        // Features
        "find_care_near_you": "Find Care Near You",
        "find_care_desc": "Locate clinics that welcome everyone",
        "easy_appointments": "Easy Appointments",
        "easy_appointments_desc": "Schedule visits with one tap",
        "learn_the_system": "Learn the System",
        "learn_the_system_desc": "Understand your healthcare rights",
        "your_language": "Your Language",
        "your_language_desc": "Available in multiple languages",

        // Language Selection
        "select_language": "Select Your Language",
        "language_desc": "Choose the language you're most comfortable with",

        // Status Selection
        "tell_us_status": "Tell us about your situation",
        "status_desc": "This helps us find the right resources for you. Your information is private and secure.",
        "refugee": "Refugee",
        "refugee_desc": "I came to this country as a refugee",
        "asylum_seeker": "Asylum Seeker",
        "asylum_desc": "I am seeking asylum protection",
        "undocumented": "Undocumented",
        "undocumented_desc": "I don't have legal documentation",
        "visa_holder": "Visa Holder",
        "visa_desc": "I have a temporary visa",
        "green_card": "Green Card Holder",
        "green_card_desc": "I have permanent residency",
        "citizen": "Citizen",
        "citizen_desc": "I am a citizen",
        "other_status": "Other / Prefer not to say",

        // Housing
        "housing_situation": "What is your housing situation?",
        "housing_desc": "This helps us connect you with appropriate services",
        "stable_housing": "Stable Housing",
        "temporary_housing": "Temporary Housing",
        "shelter": "Shelter",
        "homeless": "Currently Homeless",
        "homeless_support": "We're here to help. Many clinics offer special services for people experiencing homelessness.",

        // Personal Info
        "tell_us_about_yourself": "Tell us about yourself",
        "personal_info_desc": "This information helps us personalize your experience.",
        "whats_your_name": "What's your name?",
        "enter_your_name": "Enter your name",
        "where_are_you_from": "Where are you from?",
        "country_of_origin": "Country of origin",
        "when_did_you_arrive": "When did you arrive?",
        "do_you_have_children": "Do you have children?",
        "i_have_children": "I have children",
        "how_many_children": "How many children?",
        "do_you_have_transportation": "Do you have transportation?",
        "i_have_transportation": "I have reliable transportation",

        // Health Needs
        "health_needs": "What are your health needs?",
        "health_needs_desc": "Select all that apply. This helps us recommend the right clinics.",
        "general_checkup": "General Check-up",
        "mental_health": "Mental Health Support",
        "dental_care": "Dental Care",
        "vision_care": "Vision / Eye Care",
        "pregnancy_care": "Pregnancy Care",
        "childrens_health": "Children's Health",
        "chronic_condition": "Chronic Condition",
        "need_medications": "Need Medications",
        "vaccinations": "Vaccinations",
        "urgent_health": "Urgent Health Issue",

        // Insurance
        "insurance_status": "Do you have health insurance?",
        "insurance_desc": "Don't worry if you don't have insurance. Many clinics offer free or low-cost care.",
        "no_insurance": "No Insurance",
        "medicaid": "Medicaid",
        "medicare": "Medicare",
        "marketplace_plan": "Marketplace Plan",
        "employer_insurance": "Employer Insurance",
        "emergency_medicaid": "Emergency Medicaid",
        "not_sure": "Not Sure",
        "may_qualify_medicaid": "Based on your status, you may qualify for Medicaid. We can help you apply.",
        "emergency_medicaid_info": "Emergency Medicaid is available for emergency care regardless of immigration status.",

        // Location
        "where_located": "Where are you located?",
        "location_desc": "This helps us find clinics and services near you.",
        "use_my_location": "Use My Current Location",
        "find_clinics_nearby": "We'll find clinics nearby",
        "or": "or",
        "enter_zip": "Enter your ZIP code",
        "need_interpreter": "I need an interpreter",
        "interpreter_desc": "We'll find clinics with language services",

        // Onboarding Complete
        "youre_all_set": "You're All Set!",
        "setup_complete": "We've personalized your HealthBridge experience based on your needs.",
        "start_exploring": "Start Exploring",

        // Dashboard
        "home": "Home",
        "find_care": "Find Care",
        "appointments": "Appointments",
        "learn": "Learn",
        "profile": "Profile",
        "emergency": "Emergency",
        "call_911": "Call 911",
        "crisis_line": "Crisis Line",
        "quick_actions": "Quick Actions",
        "recommended_for_you": "Recommended for You",

        // Clinic Finder
        "search_clinics": "Search clinics...",
        "all": "All",
        "more_filters": "More",
        "list": "List",
        "map": "Map",
        "open": "Open",
        "closed": "Closed",
        "free": "Free",
        "sliding_scale": "Sliding Scale",
        "interpreter": "Interpreter",
        "walk_ins_ok": "Walk-ins OK",
        "call": "Call",
        "directions": "Directions",
        "book_appointment": "Book Appointment",
        "about": "About",
        "services": "Services",
        "hours": "Hours",

        // Appointments
        "upcoming": "Upcoming",
        "past": "Past",
        "no_upcoming_appointments": "No Upcoming Appointments",
        "schedule_first_appointment": "Schedule your first appointment to get started with your healthcare journey.",
        "today": "TODAY",
        "tomorrow": "TOMORROW",
        "call_clinic": "Call Clinic",
        "cancel": "Cancel",
        "cancel_appointment": "Cancel Appointment?",
        "keep_appointment": "Keep Appointment",
        "select_clinic": "Select Clinic",
        "type_of_visit": "Type of Visit",
        "when": "When",
        "date": "Date",
        "time": "Time",
        "special_needs": "Special Needs",
        "need_interpreter_toggle": "I need an interpreter",
        "need_transportation": "I need help with transportation",
        "notes_optional": "Notes (Optional)",
        "appointment_booked": "Appointment Booked!",
        "appointment_confirmed": "Your appointment has been confirmed. You will receive a reminder.",

        // Learn
        "healthcare_guide": "Healthcare Guide",
        "us_healthcare_basics": "US Healthcare Basics",
        "your_rights": "Your Rights as a Patient",
        "understanding_insurance": "Understanding Insurance",
        "emergency_vs_urgent": "Emergency vs Urgent Care",
        "finding_doctors": "Finding the Right Doctor",
        "prescription_help": "Getting Prescription Help",

        // Profile
        "edit_profile": "Edit Profile",
        "language_settings": "Language Settings",
        "notifications": "Notifications",
        "privacy": "Privacy",
        "help_support": "Help & Support",
        "about_app": "About HealthBridge",
        "sign_out": "Sign Out",

        // Common
        "loading": "Loading...",
        "error": "Error",
        "try_again": "Try Again",
        "save": "Save",
        "close": "Close",
        "yes": "Yes",
        "no": "No",

        // Clinic Search & Loading
        "searching_nearby": "Searching nearby...",
        "clinics_found": "clinics found",
        "finding_best_clinics": "Finding the best clinics for your needs",
        "no_clinics_found": "No clinics found",
        "try_adjusting_filters": "Try adjusting your filters or search, or enable location services to find clinics near you.",
        "enable_location_tip": "Tip: Enable location services to automatically find clinics near you",
        "open_settings": "Open Settings",
        "mapkit_clinics_note": "Some clinics found via search. Call ahead to confirm services for uninsured patients."
    ]

    // MARK: - Spanish Strings
    static let spanishStrings: [String: String] = [
        // Welcome & Onboarding
        "welcome_to": "Bienvenido a",
        "app_name": "HealthBridge",
        "app_tagline": "Tu guía de salud en un nuevo país",
        "lets_get_started": "Comenzar",
        "continue": "Continuar",
        "back": "Atrás",
        "skip": "Omitir",
        "done": "Listo",

        // Features
        "find_care_near_you": "Encuentra Atención Cerca de Ti",
        "find_care_desc": "Encuentra clínicas que dan la bienvenida a todos",
        "easy_appointments": "Citas Fáciles",
        "easy_appointments_desc": "Programa visitas con un solo toque",
        "learn_the_system": "Aprende el Sistema",
        "learn_the_system_desc": "Entiende tus derechos de salud",
        "your_language": "Tu Idioma",
        "your_language_desc": "Disponible en varios idiomas",

        // Language Selection
        "select_language": "Selecciona Tu Idioma",
        "language_desc": "Elige el idioma con el que te sientas más cómodo",

        // Status Selection
        "tell_us_status": "Cuéntanos sobre tu situación",
        "status_desc": "Esto nos ayuda a encontrar los recursos adecuados para ti. Tu información es privada y segura.",
        "refugee": "Refugiado",
        "refugee_desc": "Llegué a este país como refugiado",
        "asylum_seeker": "Solicitante de Asilo",
        "asylum_desc": "Estoy buscando protección de asilo",
        "undocumented": "Indocumentado",
        "undocumented_desc": "No tengo documentación legal",
        "visa_holder": "Titular de Visa",
        "visa_desc": "Tengo una visa temporal",
        "green_card": "Titular de Green Card",
        "green_card_desc": "Tengo residencia permanente",
        "citizen": "Ciudadano",
        "citizen_desc": "Soy ciudadano",
        "other_status": "Otro / Prefiero no decir",

        // Housing
        "housing_situation": "¿Cuál es tu situación de vivienda?",
        "housing_desc": "Esto nos ayuda a conectarte con servicios apropiados",
        "stable_housing": "Vivienda Estable",
        "temporary_housing": "Vivienda Temporal",
        "shelter": "Refugio",
        "homeless": "Actualmente Sin Hogar",
        "homeless_support": "Estamos aquí para ayudar. Muchas clínicas ofrecen servicios especiales para personas sin hogar.",

        // Personal Info
        "tell_us_about_yourself": "Cuéntanos sobre ti",
        "personal_info_desc": "Esta información nos ayuda a personalizar tu experiencia.",
        "whats_your_name": "¿Cuál es tu nombre?",
        "enter_your_name": "Ingresa tu nombre",
        "where_are_you_from": "¿De dónde eres?",
        "country_of_origin": "País de origen",
        "when_did_you_arrive": "¿Cuándo llegaste?",
        "do_you_have_children": "¿Tienes hijos?",
        "i_have_children": "Tengo hijos",
        "how_many_children": "¿Cuántos hijos?",
        "do_you_have_transportation": "¿Tienes transporte?",
        "i_have_transportation": "Tengo transporte confiable",

        // Health Needs
        "health_needs": "¿Cuáles son tus necesidades de salud?",
        "health_needs_desc": "Selecciona todas las que apliquen. Esto nos ayuda a recomendar las clínicas adecuadas.",
        "general_checkup": "Chequeo General",
        "mental_health": "Apoyo de Salud Mental",
        "dental_care": "Cuidado Dental",
        "vision_care": "Cuidado de la Vista",
        "pregnancy_care": "Cuidado del Embarazo",
        "childrens_health": "Salud Infantil",
        "chronic_condition": "Condición Crónica",
        "need_medications": "Necesito Medicamentos",
        "vaccinations": "Vacunas",
        "urgent_health": "Problema de Salud Urgente",

        // Insurance
        "insurance_status": "¿Tienes seguro de salud?",
        "insurance_desc": "No te preocupes si no tienes seguro. Muchas clínicas ofrecen atención gratuita o de bajo costo.",
        "no_insurance": "Sin Seguro",
        "medicaid": "Medicaid",
        "medicare": "Medicare",
        "marketplace_plan": "Plan del Mercado",
        "employer_insurance": "Seguro del Empleador",
        "emergency_medicaid": "Medicaid de Emergencia",
        "not_sure": "No Estoy Seguro",
        "may_qualify_medicaid": "Según tu situación, podrías calificar para Medicaid. Podemos ayudarte a aplicar.",
        "emergency_medicaid_info": "El Medicaid de emergencia está disponible para atención de emergencia sin importar el estado migratorio.",

        // Location
        "where_located": "¿Dónde estás ubicado?",
        "location_desc": "Esto nos ayuda a encontrar clínicas y servicios cerca de ti.",
        "use_my_location": "Usar Mi Ubicación Actual",
        "find_clinics_nearby": "Encontraremos clínicas cercanas",
        "or": "o",
        "enter_zip": "Ingresa tu código postal",
        "need_interpreter": "Necesito un intérprete",
        "interpreter_desc": "Encontraremos clínicas con servicios de idiomas",

        // Onboarding Complete
        "youre_all_set": "¡Todo Listo!",
        "setup_complete": "Hemos personalizado tu experiencia de HealthBridge según tus necesidades.",
        "start_exploring": "Comenzar a Explorar",

        // Dashboard
        "home": "Inicio",
        "find_care": "Buscar Atención",
        "appointments": "Citas",
        "learn": "Aprender",
        "profile": "Perfil",
        "emergency": "Emergencia",
        "call_911": "Llamar al 911",
        "crisis_line": "Línea de Crisis",
        "quick_actions": "Acciones Rápidas",
        "recommended_for_you": "Recomendado Para Ti",

        // Clinic Finder
        "search_clinics": "Buscar clínicas...",
        "all": "Todas",
        "more_filters": "Más",
        "list": "Lista",
        "map": "Mapa",
        "open": "Abierto",
        "closed": "Cerrado",
        "free": "Gratis",
        "sliding_scale": "Escala Móvil",
        "interpreter": "Intérprete",
        "walk_ins_ok": "Sin Cita OK",
        "call": "Llamar",
        "directions": "Direcciones",
        "book_appointment": "Reservar Cita",
        "about": "Acerca de",
        "services": "Servicios",
        "hours": "Horario",

        // Appointments
        "upcoming": "Próximas",
        "past": "Pasadas",
        "no_upcoming_appointments": "Sin Citas Próximas",
        "schedule_first_appointment": "Programa tu primera cita para comenzar tu viaje de salud.",
        "today": "HOY",
        "tomorrow": "MAÑANA",
        "call_clinic": "Llamar a la Clínica",
        "cancel": "Cancelar",
        "cancel_appointment": "¿Cancelar Cita?",
        "keep_appointment": "Mantener Cita",
        "select_clinic": "Seleccionar Clínica",
        "type_of_visit": "Tipo de Visita",
        "when": "Cuándo",
        "date": "Fecha",
        "time": "Hora",
        "special_needs": "Necesidades Especiales",
        "need_interpreter_toggle": "Necesito un intérprete",
        "need_transportation": "Necesito ayuda con transporte",
        "notes_optional": "Notas (Opcional)",
        "appointment_booked": "¡Cita Reservada!",
        "appointment_confirmed": "Tu cita ha sido confirmada. Recibirás un recordatorio.",

        // Learn
        "healthcare_guide": "Guía de Salud",
        "us_healthcare_basics": "Conceptos Básicos de Salud en EE.UU.",
        "your_rights": "Tus Derechos como Paciente",
        "understanding_insurance": "Entendiendo el Seguro",
        "emergency_vs_urgent": "Emergencia vs Cuidado Urgente",
        "finding_doctors": "Encontrando el Doctor Adecuado",
        "prescription_help": "Ayuda con Recetas Médicas",

        // Profile
        "edit_profile": "Editar Perfil",
        "language_settings": "Configuración de Idioma",
        "notifications": "Notificaciones",
        "privacy": "Privacidad",
        "help_support": "Ayuda y Soporte",
        "about_app": "Acerca de HealthBridge",
        "sign_out": "Cerrar Sesión",

        // Common
        "loading": "Cargando...",
        "error": "Error",
        "try_again": "Intentar de Nuevo",
        "save": "Guardar",
        "close": "Cerrar",
        "yes": "Sí",
        "no": "No",

        // Clinic Search & Loading
        "searching_nearby": "Buscando cerca...",
        "clinics_found": "clínicas encontradas",
        "finding_best_clinics": "Encontrando las mejores clínicas para tus necesidades",
        "no_clinics_found": "No se encontraron clínicas",
        "try_adjusting_filters": "Intenta ajustar tus filtros o búsqueda, o activa los servicios de ubicación para encontrar clínicas cerca de ti.",
        "enable_location_tip": "Consejo: Activa los servicios de ubicación para encontrar clínicas cerca de ti automáticamente",
        "open_settings": "Abrir Configuración",
        "mapkit_clinics_note": "Algunas clínicas encontradas por búsqueda. Llama antes para confirmar servicios para pacientes sin seguro."
    ]
}

// MARK: - View Extension for Localization
extension View {
    func localized(_ key: String) -> String {
        return LocalizationManager.shared.localized(key)
    }
}

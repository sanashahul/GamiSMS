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
        "app_name": "CareConnect",
        "app_tagline": "Your path to healthcare, jobs, and housing",
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
        "setup_complete": "We've personalized your CareConnect experience based on your needs.",
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
        "about_app": "About CareConnect",
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
        "mapkit_clinics_note": "Some clinics found via search. Call ahead to confirm services for uninsured patients.",

        // Clinic Detail
        "call_to_schedule": "Call to Schedule",
        "call_clinic_to_book": "Call the clinic directly to schedule your appointment",
        "call_now": "Call Now:",
        "visit_website": "Visit Website",

        // Appointments - Tracker System
        "my_appointments": "My Appointments",
        "appointment_tracker_info": "Track appointments you've scheduled by calling clinics",
        "no_upcoming_reminders": "No Upcoming Reminders",
        "add_appointment_after_calling": "After calling a clinic to schedule, add your appointment here as a reminder.",
        "how_to_use": "How to Use",
        "step_find_clinic": "Find a clinic in the Find Care tab",
        "step_call_clinic": "Call the clinic to schedule your appointment",
        "step_add_reminder": "Add your appointment here as a reminder",
        "add_appointment": "Add Appointment",
        "add_reminder": "Add Reminder",
        "add_reminder_after": "Add your scheduled appointment here as a reminder",
        "clinic_info": "Clinic Information",
        "clinic_name": "Clinic Name",
        "address_optional": "Address (Optional)",
        "phone_optional": "Phone Number (Optional)",
        "reminders_for_visit": "Reminders for Your Visit",
        "bring_interpreter_or_request": "Request/bring interpreter",
        "arrange_transportation": "Arrange transportation",
        "notes_placeholder": "Anything you want to remember...",
        "reminder": "Reminder",
        "transport": "Transport",
        "delete": "Delete",
        "keep": "Keep",
        "delete_reminder": "Delete Reminder?",
        "delete_reminder_confirm": "Are you sure you want to delete this appointment reminder?",
        "no_past_appointments": "No past appointments",
        "completed": "Completed",

        // Dashboard
        "good_morning": "Good morning",
        "good_afternoon": "Good afternoon",
        "good_evening": "Good evening",
        "welcome": "Welcome!",
        "life_threatening": "Life-threatening",
        "mental_health_crisis": "Mental health crisis",
        "upcoming_reminders": "Upcoming Reminders",
        "see_all": "See All",
        "find_clinic": "Find Clinic",
        "learn_healthcare": "Learn Healthcare",
        "my_rights": "My Rights",
        "did_you_know": "Did You Know?",

        // Recommendations
        "rec_free_care_title": "Free & Low-Cost Care",
        "rec_free_care_desc": "Find clinics that offer care regardless of ability to pay",
        "rec_refugee_title": "Refugee Health Services",
        "rec_refugee_desc": "Specialized clinics and programs for refugees",
        "rec_asylum_title": "Asylum Seeker Health",
        "rec_asylum_desc": "Healthcare resources for asylum seekers",
        "rec_fqhc_title": "Community Health Centers",
        "rec_fqhc_desc": "Federally funded clinics that serve everyone regardless of status",
        "rec_homeless_title": "Healthcare for the Homeless",
        "rec_homeless_desc": "Programs designed for people experiencing homelessness",
        "rec_mental_health_title": "Mental Health Support",
        "rec_mental_health_desc": "Counseling and mental health services",
        "rec_prenatal_title": "Prenatal Care",
        "rec_prenatal_desc": "Care for expecting mothers - often free regardless of status",
        "rec_dental_title": "Dental Care",
        "rec_dental_desc": "Affordable dental services in your area",
        "rec_vision_title": "Vision Care",
        "rec_vision_desc": "Eye exams and glasses at low cost",
        "rec_pediatric_title": "Children's Health",
        "rec_pediatric_desc": "Healthcare services for your children",
        "rec_chronic_title": "Chronic Care Management",
        "rec_chronic_desc": "Ongoing care for chronic conditions",
        "rec_medications_title": "Prescription Assistance",
        "rec_medications_desc": "Programs to help afford your medications",
        "rec_vaccines_title": "Vaccinations",
        "rec_vaccines_desc": "Free vaccines for you and your family",
        "rec_family_title": "Family Health Services",
        "rec_family_desc": "Healthcare for the whole family",
        "rec_interpreter_title": "Language Services",
        "rec_interpreter_desc": "You have the right to a free interpreter at all healthcare visits",
        "rec_primary_care_title": "Find a Primary Care Doctor",
        "rec_primary_care_desc": "Having a regular doctor helps you stay healthy",

        // Health Tips
        "tip_interpreter": "You have the right to a FREE interpreter at any healthcare facility",
        "tip_emergency": "Emergency rooms MUST treat you regardless of ability to pay",
        "tip_fqhc": "Community health centers offer care on a sliding fee scale",
        "tip_vaccines": "You can get FREE vaccines through the VFC program",
        "tip_no_immigration_questions": "FQHCs cannot ask about your immigration status",
        "tip_refugee_programs": "You may qualify for special refugee health programs",
        "tip_prenatal_free": "Prenatal care is often free regardless of immigration status",

        // Rights
        "right_emergency_title": "Emergency Care",
        "right_emergency_desc": "Emergency rooms must treat you regardless of immigration status or ability to pay. This is federal law (EMTALA).",
        "right_interpreter_title": "Free Interpreter",
        "right_interpreter_desc": "Any healthcare facility receiving federal funds must provide you with a free interpreter in your language.",
        "right_privacy_title": "Medical Privacy",
        "right_privacy_desc": "Your medical information is protected by HIPAA. Healthcare providers cannot share your information without your consent.",
        "right_no_discrimination_title": "No Discrimination",
        "right_no_discrimination_desc": "Healthcare facilities cannot discriminate based on race, national origin, or immigration status.",
        "right_fqhc_title": "Community Health Centers",
        "right_fqhc_desc": "Federally Qualified Health Centers must serve everyone regardless of immigration status or ability to pay.",

        // Profile
        "personal_info": "Personal Information",
        "name": "Name",
        "country": "Country",
        "status": "Status",
        "not_set": "Not set",
        "preferences": "Preferences",
        "language": "Language",
        "needs_interpreter": "Needs Interpreter",
        "reset_onboarding": "Reset Onboarding"
    ]

    // MARK: - Spanish Strings
    static let spanishStrings: [String: String] = [
        // Welcome & Onboarding
        "welcome_to": "Bienvenido a",
        "app_name": "CareConnect",
        "app_tagline": "Tu camino a salud, empleo y vivienda",
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
        "setup_complete": "Hemos personalizado tu experiencia de CareConnect según tus necesidades.",
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
        "about_app": "Acerca de CareConnect",
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
        "mapkit_clinics_note": "Algunas clínicas encontradas por búsqueda. Llama antes para confirmar servicios para pacientes sin seguro.",

        // Clinic Detail
        "call_to_schedule": "Llama para Programar",
        "call_clinic_to_book": "Llama a la clínica directamente para programar tu cita",
        "call_now": "Llamar Ahora:",
        "visit_website": "Visitar Sitio Web",

        // Appointments - Tracker System
        "my_appointments": "Mis Citas",
        "appointment_tracker_info": "Registra las citas que has programado llamando a las clínicas",
        "no_upcoming_reminders": "Sin Recordatorios Próximos",
        "add_appointment_after_calling": "Después de llamar a una clínica para programar, agrega tu cita aquí como recordatorio.",
        "how_to_use": "Cómo Usar",
        "step_find_clinic": "Encuentra una clínica en la pestaña Buscar Atención",
        "step_call_clinic": "Llama a la clínica para programar tu cita",
        "step_add_reminder": "Agrega tu cita aquí como recordatorio",
        "add_appointment": "Agregar Cita",
        "add_reminder": "Agregar Recordatorio",
        "add_reminder_after": "Agrega tu cita programada aquí como recordatorio",
        "clinic_info": "Información de la Clínica",
        "clinic_name": "Nombre de la Clínica",
        "address_optional": "Dirección (Opcional)",
        "phone_optional": "Número de Teléfono (Opcional)",
        "reminders_for_visit": "Recordatorios para Tu Visita",
        "bring_interpreter_or_request": "Solicitar/traer intérprete",
        "arrange_transportation": "Organizar transporte",
        "notes_placeholder": "Cualquier cosa que quieras recordar...",
        "reminder": "Recordatorio",
        "transport": "Transporte",
        "delete": "Eliminar",
        "keep": "Mantener",
        "delete_reminder": "¿Eliminar Recordatorio?",
        "delete_reminder_confirm": "¿Estás seguro de que quieres eliminar este recordatorio de cita?",
        "no_past_appointments": "Sin citas pasadas",
        "completed": "Completada",

        // Dashboard
        "good_morning": "Buenos días",
        "good_afternoon": "Buenas tardes",
        "good_evening": "Buenas noches",
        "welcome": "¡Bienvenido!",
        "life_threatening": "Peligro de vida",
        "mental_health_crisis": "Crisis de salud mental",
        "upcoming_reminders": "Próximos Recordatorios",
        "see_all": "Ver Todo",
        "find_clinic": "Buscar Clínica",
        "learn_healthcare": "Aprender Salud",
        "my_rights": "Mis Derechos",
        "did_you_know": "¿Sabías Que?",

        // Recommendations
        "rec_free_care_title": "Atención Gratuita y de Bajo Costo",
        "rec_free_care_desc": "Encuentra clínicas que ofrecen atención sin importar tu capacidad de pago",
        "rec_refugee_title": "Servicios de Salud para Refugiados",
        "rec_refugee_desc": "Clínicas y programas especializados para refugiados",
        "rec_asylum_title": "Salud para Solicitantes de Asilo",
        "rec_asylum_desc": "Recursos de salud para solicitantes de asilo",
        "rec_fqhc_title": "Centros de Salud Comunitarios",
        "rec_fqhc_desc": "Clínicas con fondos federales que atienden a todos sin importar su estado",
        "rec_homeless_title": "Atención para Personas sin Hogar",
        "rec_homeless_desc": "Programas diseñados para personas sin hogar",
        "rec_mental_health_title": "Apoyo de Salud Mental",
        "rec_mental_health_desc": "Servicios de consejería y salud mental",
        "rec_prenatal_title": "Cuidado Prenatal",
        "rec_prenatal_desc": "Atención para futuras madres - a menudo gratis sin importar el estado",
        "rec_dental_title": "Cuidado Dental",
        "rec_dental_desc": "Servicios dentales asequibles en tu área",
        "rec_vision_title": "Cuidado de la Vista",
        "rec_vision_desc": "Exámenes de ojos y lentes a bajo costo",
        "rec_pediatric_title": "Salud Infantil",
        "rec_pediatric_desc": "Servicios de salud para tus hijos",
        "rec_chronic_title": "Manejo de Enfermedades Crónicas",
        "rec_chronic_desc": "Atención continua para condiciones crónicas",
        "rec_medications_title": "Asistencia con Medicamentos",
        "rec_medications_desc": "Programas para ayudarte a pagar tus medicamentos",
        "rec_vaccines_title": "Vacunas",
        "rec_vaccines_desc": "Vacunas gratis para ti y tu familia",
        "rec_family_title": "Servicios de Salud Familiar",
        "rec_family_desc": "Atención médica para toda la familia",
        "rec_interpreter_title": "Servicios de Idioma",
        "rec_interpreter_desc": "Tienes derecho a un intérprete gratis en todas tus visitas médicas",
        "rec_primary_care_title": "Encuentra un Médico de Cabecera",
        "rec_primary_care_desc": "Tener un médico regular te ayuda a mantenerte saludable",

        // Health Tips
        "tip_interpreter": "Tienes derecho a un intérprete GRATIS en cualquier centro de salud",
        "tip_emergency": "Las salas de emergencia DEBEN atenderte sin importar tu capacidad de pago",
        "tip_fqhc": "Los centros de salud comunitarios ofrecen atención con tarifas según tus ingresos",
        "tip_vaccines": "Puedes obtener vacunas GRATIS a través del programa VFC",
        "tip_no_immigration_questions": "Los FQHCs no pueden preguntar sobre tu estado migratorio",
        "tip_refugee_programs": "Podrías calificar para programas especiales de salud para refugiados",
        "tip_prenatal_free": "El cuidado prenatal a menudo es gratis sin importar el estado migratorio",

        // Rights
        "right_emergency_title": "Atención de Emergencia",
        "right_emergency_desc": "Las salas de emergencia deben atenderte sin importar tu estado migratorio o capacidad de pago. Esta es ley federal (EMTALA).",
        "right_interpreter_title": "Intérprete Gratis",
        "right_interpreter_desc": "Cualquier centro de salud que reciba fondos federales debe proporcionarte un intérprete gratis en tu idioma.",
        "right_privacy_title": "Privacidad Médica",
        "right_privacy_desc": "Tu información médica está protegida por HIPAA. Los proveedores de salud no pueden compartir tu información sin tu consentimiento.",
        "right_no_discrimination_title": "Sin Discriminación",
        "right_no_discrimination_desc": "Los centros de salud no pueden discriminar por raza, origen nacional o estado migratorio.",
        "right_fqhc_title": "Centros de Salud Comunitarios",
        "right_fqhc_desc": "Los Centros de Salud con Calificación Federal deben atender a todos sin importar el estado migratorio o la capacidad de pago.",

        // Profile
        "personal_info": "Información Personal",
        "name": "Nombre",
        "country": "País",
        "status": "Estado",
        "not_set": "No establecido",
        "preferences": "Preferencias",
        "language": "Idioma",
        "needs_interpreter": "Necesita Intérprete",
        "reset_onboarding": "Reiniciar Incorporación"
    ]
}

// MARK: - View Extension for Localization
extension View {
    func localized(_ key: String) -> String {
        return LocalizationManager.shared.localized(key)
    }
}

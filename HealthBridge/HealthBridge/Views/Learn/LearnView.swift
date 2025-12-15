import SwiftUI

struct LearnView: View {
    @EnvironmentObject var userProfile: UserProfile

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Personalized recommendations
                    if !recommendedTopics.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommended for You")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(recommendedTopics, id: \.title) { topic in
                                        RecommendedTopicCard(topic: topic)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Main topics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Healthcare Basics")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            NavigationLink(destination: HealthcareSystemView()) {
                                TopicCard(
                                    icon: "building.2.fill",
                                    title: "Understanding the Healthcare System",
                                    description: "Learn about different types of care and when to use them",
                                    color: .blue
                                )
                            }

                            NavigationLink(destination: YourRightsDetailView()) {
                                TopicCard(
                                    icon: "shield.fill",
                                    title: "Your Rights as a Patient",
                                    description: "Important rights including interpreter services",
                                    color: .green
                                )
                            }

                            NavigationLink(destination: InsuranceGuideView()) {
                                TopicCard(
                                    icon: "creditcard.fill",
                                    title: "Health Insurance Guide",
                                    description: "Coverage options even without documents",
                                    color: .purple
                                )
                            }

                            NavigationLink(destination: EmergencyGuideView()) {
                                TopicCard(
                                    icon: "cross.case.fill",
                                    title: "Emergency Care",
                                    description: "When and how to get emergency help",
                                    color: .red
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Health topics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Health Topics")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            NavigationLink(destination: PreventiveCareView()) {
                                TopicCard(
                                    icon: "heart.fill",
                                    title: "Preventive Care",
                                    description: "Stay healthy with regular checkups and screenings",
                                    color: .pink
                                )
                            }

                            NavigationLink(destination: MentalHealthView()) {
                                TopicCard(
                                    icon: "brain.head.profile",
                                    title: "Mental Health",
                                    description: "Taking care of your emotional wellbeing",
                                    color: .teal
                                )
                            }

                            NavigationLink(destination: WomensHealthView()) {
                                TopicCard(
                                    icon: "figure.stand.dress",
                                    title: "Women's Health",
                                    description: "Prenatal care, screenings, and more",
                                    color: .orange
                                )
                            }

                            NavigationLink(destination: ChildrensHealthView()) {
                                TopicCard(
                                    icon: "figure.2.and.child.holdinghands",
                                    title: "Children's Health",
                                    description: "Keeping kids healthy and up-to-date on vaccines",
                                    color: .mint
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Helpful phrases
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Helpful Phrases")
                            .font(.headline)
                            .padding(.horizontal)

                        NavigationLink(destination: PhrasesView()) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.indigo)
                                    .cornerRadius(12)

                                VStack(alignment: .leading) {
                                    Text("Medical Phrases")
                                        .font(.headline)
                                    Text("Common phrases for healthcare visits")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Learn")
        }
    }

    var recommendedTopics: [LearnTopic] {
        var topics: [LearnTopic] = []

        // Recommend insurance/free care info for uninsured users
        if userProfile.insuranceStatus == .none || userProfile.insuranceStatus == .unsure {
            topics.append(LearnTopic(
                icon: "hand.raised.fill",
                title: "Care Without Insurance",
                description: "Options available to you",
                color: .green
            ))
        }

        // Recommend homeless health resources for those in unstable housing
        if userProfile.currentHousingSituation == .street ||
           userProfile.currentHousingSituation == .shelter ||
           userProfile.currentHousingSituation == .vehicle {
            topics.append(LearnTopic(
                icon: "house.lodge.fill",
                title: "Homeless Health Programs",
                description: "Special services for you",
                color: .purple
            ))
        }

        // Recommend mental health if user indicated need
        if userProfile.needsMentalHealthSupport {
            topics.append(LearnTopic(
                icon: "brain.head.profile",
                title: "Mental Health Support",
                description: "Counseling and support",
                color: .teal
            ))
        }

        // Recommend dental care if user indicated need
        if userProfile.needsDentalCare {
            topics.append(LearnTopic(
                icon: "mouth.fill",
                title: "Dental Care",
                description: "Free and low-cost options",
                color: .cyan
            ))
        }

        return topics
    }
}

struct LearnTopic {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Topic Card
struct TopicCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Recommended Topic Card
struct RecommendedTopicCard: View {
    let topic: LearnTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: topic.icon)
                .font(.title)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(topic.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: 160)
        .padding()
        .background(
            LinearGradient(colors: [topic.color, topic.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
    }
}

// MARK: - Healthcare System View
struct HealthcareSystemView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Intro
                Text("The healthcare system can be confusing, but understanding the basics will help you get the care you need.")
                    .foregroundColor(.secondary)

                // Types of care
                VStack(alignment: .leading, spacing: 16) {
                    Text("Types of Care")
                        .font(.title2.bold())

                    CareTypeCard(
                        icon: "stethoscope",
                        title: "Primary Care Doctor",
                        description: "Your main doctor for regular checkups and common health problems. This should be your first stop for most health concerns.",
                        whenToUse: "Annual checkups, colds, ongoing conditions, prescription refills",
                        color: .blue
                    )

                    CareTypeCard(
                        icon: "clock.badge.exclamationmark",
                        title: "Urgent Care",
                        description: "For problems that need quick attention but aren't emergencies. Usually faster and cheaper than the emergency room.",
                        whenToUse: "Minor injuries, infections, when your doctor isn't available",
                        color: .orange
                    )

                    CareTypeCard(
                        icon: "cross.case.fill",
                        title: "Emergency Room (ER)",
                        description: "Only for life-threatening emergencies. The ER must treat everyone, regardless of ability to pay or immigration status.",
                        whenToUse: "Chest pain, severe bleeding, difficulty breathing, stroke symptoms",
                        color: .red
                    )

                    CareTypeCard(
                        icon: "building.2",
                        title: "Community Health Center",
                        description: "Provide care to everyone regardless of ability to pay. Fees are based on your income (sliding scale).",
                        whenToUse: "Primary care, dental, mental health - especially if uninsured",
                        color: .green
                    )
                }

                // Important note
                ImportantNoteCard(
                    title: "Remember",
                    text: "You have the right to emergency care regardless of your immigration status or ability to pay. No one can be turned away from an emergency room."
                )
            }
            .padding()
        }
        .navigationTitle("Healthcare System")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CareTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let whenToUse: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("When to use:")
                    .font(.caption.weight(.semibold))
                Text(whenToUse)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct ImportantNoteCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            Text(text)
                .font(.subheadline)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Your Rights Detail View
struct YourRightsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("As a patient, you have important rights that protect you when getting healthcare.")
                    .foregroundColor(.secondary)

                VStack(spacing: 16) {
                    RightCard(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Right to an Interpreter",
                        description: "Hospitals and clinics must provide a free interpreter if you don't speak English well. You do NOT have to bring your own interpreter or use family members.",
                        tip: "Say: \"I need an interpreter in [your language], please.\""
                    )

                    RightCard(
                        icon: "cross.case.fill",
                        title: "Right to Emergency Care",
                        description: "Emergency rooms must treat you regardless of your ability to pay, insurance status, or immigration status. This is federal law (EMTALA).",
                        tip: "You cannot be turned away from emergency care."
                    )

                    RightCard(
                        icon: "lock.shield.fill",
                        title: "Right to Privacy",
                        description: "Your health information is protected by law (HIPAA). Doctors cannot share your information without your permission, including with immigration authorities.",
                        tip: "Clinics are generally considered 'sensitive locations' where immigration enforcement is limited."
                    )

                    RightCard(
                        icon: "hand.raised.fill",
                        title: "Right to Non-Discrimination",
                        description: "Healthcare providers cannot refuse to treat you based on your race, national origin, religion, or immigration status.",
                        tip: "If you experience discrimination, you can file a complaint with the Office for Civil Rights."
                    )

                    RightCard(
                        icon: "doc.text.fill",
                        title: "Right to Your Medical Records",
                        description: "You have the right to see and get copies of your medical records. This is important if you need to see a new doctor.",
                        tip: "Ask for records in your language if available."
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Your Rights")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct RightCard: View {
    let icon: String
    let title: String
    let description: String
    let tip: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.green)
                Text(title)
                    .font(.headline)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text(tip)
                    .font(.caption)
                    .italic()
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Placeholder Views
struct InsuranceGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Understanding your health coverage options")
                    .foregroundColor(.secondary)

                // Content would go here
                Text("Coming soon: Detailed insurance guide")
            }
            .padding()
        }
        .navigationTitle("Insurance Guide")
    }
}

struct EmergencyGuideView: View {
    var body: some View {
        Text("Emergency Guide")
            .navigationTitle("Emergency Care")
    }
}

struct PreventiveCareView: View {
    var body: some View {
        Text("Preventive Care Guide")
            .navigationTitle("Preventive Care")
    }
}

struct MentalHealthView: View {
    var body: some View {
        Text("Mental Health Resources")
            .navigationTitle("Mental Health")
    }
}

struct WomensHealthView: View {
    var body: some View {
        Text("Women's Health Guide")
            .navigationTitle("Women's Health")
    }
}

struct ChildrensHealthView: View {
    var body: some View {
        Text("Children's Health Guide")
            .navigationTitle("Children's Health")
    }
}

struct PhrasesView: View {
    var body: some View {
        Text("Helpful Medical Phrases")
            .navigationTitle("Medical Phrases")
    }
}

#Preview {
    LearnView()
        .environmentObject(UserProfile())
}

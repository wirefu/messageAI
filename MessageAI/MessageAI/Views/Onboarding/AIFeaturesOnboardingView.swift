import SwiftUI

/// Onboarding view for AI features
/// Shows first-time users how to use AI capabilities
struct AIFeaturesOnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var showingFeatureDemo = false
    @State private var selectedFeature: AIFeature?
    
    private let features = [
        AIFeature(
            id: "summarization",
            title: "Smart Summaries",
            subtitle: "AI-powered conversation analysis",
            icon: "doc.text",
            color: .blue,
            description: "Get AI-powered summaries of long conversations",
            demoText: "This conversation covered project planning, timeline discussions, and resource allocation. " +
                     "Key decisions were made about the Q1 roadmap."
        ),
        AIFeature(
            id: "clarity",
            title: "Clarity Assistant",
            subtitle: "Pre-send message analysis",
            icon: "lightbulb",
            color: .yellow,
            description: "Improve message clarity before sending",
            demoText: "Original: 'The thing needs fixing'\nImproved: 'The authentication bug needs fixing'"
        ),
        AIFeature(
            id: "actionItems",
            title: "Action Items",
            subtitle: "Automatic task extraction",
            icon: "checklist",
            color: .green,
            description: "Automatically extract tasks and commitments",
            demoText: "✅ Review code by Friday\n✅ Update documentation\n✅ Test new features"
        ),
        AIFeature(
            id: "toneAnalysis",
            title: "Tone Check",
            subtitle: "Professional communication",
            icon: "exclamationmark.triangle",
            color: .orange,
            description: "Ensure your message tone is appropriate",
            demoText: "Warning: This might sound abrupt\nSuggestion: 'I understand your concern, but...'"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentPage + 1), total: Double(features.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal)
                    .padding(.top, AppConstants.UIConfig.smallSpacing)
                
                // Feature showcase
                TabView(selection: $currentPage) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeaturePageView(
                            feature: feature,
                            onDemoTapped: {
                                selectedFeature = feature
                                showingFeatureDemo = true
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Previous") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentPage < features.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, AppConstants.UIConfig.standardSpacing)
            }
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        completeOnboarding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingFeatureDemo) {
            if let feature = selectedFeature {
                FeatureDemoView(feature: feature) {
                    showingFeatureDemo = false
                }
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "ai_features_onboarding_completed")
        isPresented = false
    }
}

// MARK: - Feature Page View

struct FeaturePageView: View {
    let feature: AIFeature
    let onDemoTapped: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.UIConfig.standardSpacing) {
            Spacer()
            
            // Feature icon
            Image(systemName: feature.icon)
                .font(.system(size: 80))
                .foregroundColor(feature.color)
                .padding(.bottom, AppConstants.UIConfig.standardSpacing)
            
            // Feature title
            Text(feature.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Feature description
            Text(feature.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            
            // Demo button
            Button("See Demo") {
                onDemoTapped()
            }
            .buttonStyle(.borderedProminent)
            .tint(feature.color)
            .padding(.top, AppConstants.UIConfig.standardSpacing)
            
            Spacer()
        }
        .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
    }
}

// MARK: - Feature Demo View

struct FeatureDemoView: View {
    let feature: AIFeature
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.UIConfig.standardSpacing) {
                // Demo content
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("How it works:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(feature.demoText ?? "No demo available")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(AppConstants.UIConfig.cornerRadius)
                }
                .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
                
                Spacer()
                
                // Benefits
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Benefits:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(feature.benefits, id: \.self) { benefit in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            Text(benefit)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
                
                Spacer()
            }
            .navigationTitle(feature.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Onboarding Manager

class AIFeaturesOnboardingManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = false
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "ai_features_onboarding_completed")
        shouldShowOnboarding = !hasCompletedOnboarding
    }
    
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "ai_features_onboarding_completed")
        shouldShowOnboarding = false
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "ai_features_onboarding_completed")
        shouldShowOnboarding = true
    }
}

#Preview {
    AIFeaturesOnboardingView(isPresented: .constant(true))
}

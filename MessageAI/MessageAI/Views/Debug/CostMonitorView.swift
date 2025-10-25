import SwiftUI
import Foundation

/// Debug-only cost monitoring dashboard for AI features
/// Tracks API calls, Firestore operations, and estimated costs
#if DEBUG
struct CostMonitorView: View {
    @StateObject private var costTracker = CostTracker.shared
    @State private var isExpanded = false
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("AI Cost Monitor")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { isExpanded.toggle() }, label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                })
            }
            .padding(.horizontal)
            .padding(.top, AppConstants.UIConfig.smallSpacing)
            
            if isExpanded {
                // Cost Summary
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    CostSummaryRow(
                        title: "Total Cost",
                        value: String(format: "$%.4f", costTracker.totalCost),
                        color: .primary
                    )
                    
                    CostSummaryRow(
                        title: "OpenAI API Calls",
                        value: "\(costTracker.openAICalls)",
                        color: .blue
                    )
                    
                    CostSummaryRow(
                        title: "Firestore Reads",
                        value: "\(costTracker.firestoreReads)",
                        color: .green
                    )
                    
                    CostSummaryRow(
                        title: "Firestore Writes",
                        value: "\(costTracker.firestoreWrites)",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Recent Activity
                if !costTracker.recentActivity.isEmpty {
                    VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                        Text("Recent Activity")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        ForEach(costTracker.recentActivity.prefix(5), id: \.id) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Cost Breakdown
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Cost Breakdown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    CostBreakdownRow(
                        title: "Summarization",
                        cost: costTracker.summarizationCost,
                        calls: costTracker.summarizationCalls
                    )
                    
                    CostBreakdownRow(
                        title: "Clarity Assistant",
                        cost: costTracker.clarityCost,
                        calls: costTracker.clarityCalls
                    )
                    
                    CostBreakdownRow(
                        title: "Action Items",
                        cost: costTracker.actionItemsCost,
                        calls: costTracker.actionItemsCalls
                    )
                    
                    CostBreakdownRow(
                        title: "Tone Analysis",
                        cost: costTracker.toneAnalysisCost,
                        calls: costTracker.toneAnalysisCalls
                    )
                }
                .padding(.horizontal)
                
                // Controls
                HStack {
                    Button("Reset Data") {
                        showingResetAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Export Report") {
                        exportCostReport()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding(.horizontal)
                .padding(.bottom, AppConstants.UIConfig.smallSpacing)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.UIConfig.cornerRadius)
        .shadow(radius: 2)
        .alert("Reset Cost Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                costTracker.resetData()
            }
        } message: {
            Text("This will permanently delete all cost tracking data. This action cannot be undone.")
        }
    }
    
    private func exportCostReport() {
        let report = costTracker.generateReport()
        // In a real implementation, you would save this to a file or share it
        print("Cost Report:\n\(report)")
    }
}

// MARK: - Supporting Views

struct CostSummaryRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct ActivityRow: View {
    let activity: CostActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundColor(activity.color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "$%.4f", activity.cost))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct CostBreakdownRow: View {
    let title: String
    let cost: Double
    let calls: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(calls) calls")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(String(format: "$%.4f", cost))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Cost Tracking Models

struct CostActivity: Identifiable {
    let id = UUID()
    let description: String
    let cost: Double
    let timestamp: Date
    let icon: String
    let color: Color
}

// MARK: - Cost Tracker

@MainActor
class CostTracker: ObservableObject {
    static let shared = CostTracker()
    
    @Published var totalCost: Double = 0.0
    @Published var openAICalls: Int = 0
    @Published var firestoreReads: Int = 0
    @Published var firestoreWrites: Int = 0
    @Published var recentActivity: [CostActivity] = []
    
    // Cost breakdown by feature
    @Published var summarizationCost: Double = 0.0
    @Published var summarizationCalls: Int = 0
    @Published var clarityCost: Double = 0.0
    @Published var clarityCalls: Int = 0
    @Published var actionItemsCost: Double = 0.0
    @Published var actionItemsCalls: Int = 0
    @Published var toneAnalysisCost: Double = 0.0
    @Published var toneAnalysisCalls: Int = 0
    
    private init() {
        loadData()
    }
    
    func trackOpenAICall(feature: String, cost: Double) {
        openAICalls += 1
        totalCost += cost
        
        // Update feature-specific tracking
        switch feature {
        case "summarization":
            summarizationCost += cost
            summarizationCalls += 1
        case "clarity":
            clarityCost += cost
            clarityCalls += 1
        case "actionItems":
            actionItemsCost += cost
            actionItemsCalls += 1
        case "toneAnalysis":
            toneAnalysisCost += cost
            toneAnalysisCalls += 1
        default:
            break
        }
        
        // Add to recent activity
        let activity = CostActivity(
            description: "\(feature.capitalized) API call",
            cost: cost,
            timestamp: Date(),
            icon: "brain.head.profile",
            color: .blue
        )
        recentActivity.insert(activity, at: 0)
        
        // Keep only last 50 activities
        if recentActivity.count > 50 {
            recentActivity = Array(recentActivity.prefix(50))
        }
        
        saveData()
    }
    
    func trackFirestoreRead() {
        firestoreReads += 1
        
        let activity = CostActivity(
            description: "Firestore read",
            cost: 0.0, // Firestore reads are free up to limits
            timestamp: Date(),
            icon: "doc.text",
            color: .green
        )
        recentActivity.insert(activity, at: 0)
        
        saveData()
    }
    
    func trackFirestoreWrite() {
        firestoreWrites += 1
        
        let activity = CostActivity(
            description: "Firestore write",
            cost: 0.0, // Firestore writes are free up to limits
            timestamp: Date(),
            icon: "pencil",
            color: .orange
        )
        recentActivity.insert(activity, at: 0)
        
        saveData()
    }
    
    func resetData() {
        totalCost = 0.0
        openAICalls = 0
        firestoreReads = 0
        firestoreWrites = 0
        recentActivity = []
        
        summarizationCost = 0.0
        summarizationCalls = 0
        clarityCost = 0.0
        clarityCalls = 0
        actionItemsCost = 0.0
        actionItemsCalls = 0
        toneAnalysisCost = 0.0
        toneAnalysisCalls = 0
        
        saveData()
    }
    
    func generateReport() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return """
        AI Cost Report
        Generated: \(formatter.string(from: Date()))
        
        Total Cost: $\(String(format: "%.4f", totalCost))
        OpenAI API Calls: \(openAICalls)
        Firestore Reads: \(firestoreReads)
        Firestore Writes: \(firestoreWrites)
        
        Cost Breakdown:
        - Summarization: $\(String(format: "%.4f", summarizationCost)) (\(summarizationCalls) calls)
        - Clarity Assistant: $\(String(format: "%.4f", clarityCost)) (\(clarityCalls) calls)
        - Action Items: $\(String(format: "%.4f", actionItemsCost)) (\(actionItemsCalls) calls)
        - Tone Analysis: $\(String(format: "%.4f", toneAnalysisCost)) (\(toneAnalysisCalls) calls)
        
        Recent Activity:
        \(recentActivity.prefix(10).map { activity in
            let timestamp = formatter.string(from: activity.timestamp)
            let cost = String(format: "%.4f", activity.cost)
            return "\(timestamp): \(activity.description) - $\(cost)"
        }.joined(separator: "\n"))
        """
    }
    
    private func saveData() {
        let data: [String: Any] = [
            "totalCost": totalCost,
            "openAICalls": openAICalls,
            "firestoreReads": firestoreReads,
            "firestoreWrites": firestoreWrites,
            "summarizationCost": summarizationCost,
            "summarizationCalls": summarizationCalls,
            "clarityCost": clarityCost,
            "clarityCalls": clarityCalls,
            "actionItemsCost": actionItemsCost,
            "actionItemsCalls": actionItemsCalls,
            "toneAnalysisCost": toneAnalysisCost,
            "toneAnalysisCalls": toneAnalysisCalls
        ]
        
        UserDefaults.standard.set(data, forKey: "costTrackerData")
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.dictionary(forKey: "costTrackerData") else { return }
        
        totalCost = data["totalCost"] as? Double ?? 0.0
        openAICalls = data["openAICalls"] as? Int ?? 0
        firestoreReads = data["firestoreReads"] as? Int ?? 0
        firestoreWrites = data["firestoreWrites"] as? Int ?? 0
        
        summarizationCost = data["summarizationCost"] as? Double ?? 0.0
        summarizationCalls = data["summarizationCalls"] as? Int ?? 0
        clarityCost = data["clarityCost"] as? Double ?? 0.0
        clarityCalls = data["clarityCalls"] as? Int ?? 0
        actionItemsCost = data["actionItemsCost"] as? Double ?? 0.0
        actionItemsCalls = data["actionItemsCalls"] as? Int ?? 0
        toneAnalysisCost = data["toneAnalysisCost"] as? Double ?? 0.0
        toneAnalysisCalls = data["toneAnalysisCalls"] as? Int ?? 0
    }
}

#Preview {
    CostMonitorView()
        .padding()
}
#endif

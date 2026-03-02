// CareCoordinator/Services/Carey/CareyChatService.swift
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: ChatRole
    let content: String
    let timestamp: Date

    init(role: ChatRole, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

enum ChatRole: String, Codable {
    case user
    case assistant
    case system
}

@Observable
final class CareyChatService {
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return true
        }
        #endif
        return false
    }

    var messages: [ChatMessage] = []
    var isGenerating = false
    var errorMessage: String?

    private var context: CareyContext?

    func configure(context: CareyContext) {
        self.context = context
    }

    func sendMessage(_ userMessage: String) async {
        guard let context else {
            errorMessage = "Care-y is not configured. Please try again."
            return
        }

        let userChat = ChatMessage(role: .user, content: userMessage)
        messages.append(userChat)
        isGenerating = true
        errorMessage = nil

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            await generateWithFoundationModels(userMessage: userMessage, context: context)
        } else {
            appendFallbackMessage()
        }
        #else
        appendFallbackMessage()
        #endif

        isGenerating = false
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(userMessage: String, context: CareyContext) async {
        do {
            let session = LanguageModelSession(
                instructions: context.systemPrompt + "\n\n" + context.contextData
            )

            let response = try await session.respond(to: userMessage)
            let assistantMessage = ChatMessage(role: .assistant, content: response.content)
            messages.append(assistantMessage)
        } catch {
            errorMessage = "Care-y couldn't process your request: \(error.localizedDescription)"
            let errorChat = ChatMessage(role: .assistant, content: "I'm sorry, I couldn't process that request. Please try again.")
            messages.append(errorChat)
        }
    }
    #endif

    private func appendFallbackMessage() {
        let fallback = ChatMessage(
            role: .assistant,
            content: "Care-y requires iOS 26 or later with Apple Intelligence enabled. Please update your device to use this feature."
        )
        messages.append(fallback)
    }

    func clearHistory() {
        messages.removeAll()
    }
}

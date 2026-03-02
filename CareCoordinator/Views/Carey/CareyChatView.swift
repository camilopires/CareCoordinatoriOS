// CareCoordinator/Views/Carey/CareyChatView.swift
import SwiftUI

struct CareyChatView: View {
    @State private var chatService = CareyChatService()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    let profile: Profile
    let careGroup: CareGroup
    let shifts: [Shift]
    let tasks: [CareTask]
    let carerNames: [UUID: String]?

    private let contextBuilder = CareyContextBuilder()

    var body: some View {
        VStack(spacing: 0) {
            if !chatService.isAvailable {
                unavailableView
            } else {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatService.messages) { message in
                                ChatBubble(message: message, isCurrentUser: message.role == .user)
                                    .id(message.id)
                            }

                            if chatService.isGenerating {
                                HStack {
                                    ProgressView()
                                    Text("Care-y is thinking...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("generating")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages.count) { _, _ in
                        withAnimation {
                            if let lastId = chatService.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            } else {
                                proxy.scrollTo("generating", anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input bar
                HStack(spacing: 8) {
                    TextField("Ask Care-y anything...", text: $inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatService.isGenerating)
                }
                .padding()
            }
        }
        .navigationTitle("Care-y")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Clear History", systemImage: "trash") {
                        chatService.clearHistory()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            let context = contextBuilder.buildContext(
                profile: profile,
                careGroup: careGroup,
                shifts: shifts,
                tasks: tasks,
                carerNames: carerNames,
                carePlanTexts: nil
            )
            chatService.configure(context: context)
        }
    }

    private var unavailableView: some View {
        ContentUnavailableView {
            Label("Care-y Unavailable", systemImage: "brain")
        } description: {
            Text("Care-y requires iOS 26 or later with Apple Intelligence enabled. Please update your device to use this feature.")
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task {
            await chatService.sendMessage(text)
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !isCurrentUser { Spacer() }
        }
    }
}

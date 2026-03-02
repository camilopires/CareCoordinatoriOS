// CareCoordinator/Models/Enums.swift
import Foundation

enum PrivacyMode: String, Codable, CaseIterable {
    case full
    case anonymous
    case open
}

enum UserRole: String, Codable {
    case client
    case carer
}

enum ShiftStatus: String, Codable {
    case scheduled
    case needingCover = "needing_cover"
    case covered
    case completed
    case cancelled
}

enum PTOStatus: String, Codable {
    case pending
    case approved
    case denied
}

enum ShiftOfferStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case declined
    case expired
}

enum TaskType: String, Codable {
    case swapoverTemplate = "swapover_template"
    case swapoverInstance = "swapover_instance"
    case general
}

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

enum InvitationStatus: String, Codable {
    case active
    case revoked
    case expired
}

enum JoinRequestStatus: String, Codable {
    case pending
    case approved
    case denied
}

enum NotificationType: String, Codable {
    case joinRequest = "join_request"
    case ptoRequest = "pto_request"
    case shiftChange = "shift_change"
    case taskAssigned = "task_assigned"
    case openShift = "open_shift"
    case ptoDecision = "pto_decision"
    case reminder
    case carePlanUpdate = "care_plan_update"
}

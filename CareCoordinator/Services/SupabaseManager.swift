import Supabase
import Foundation

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Secrets.supabaseURL)!,
        supabaseKey: Secrets.supabaseAnonKey
    )
}

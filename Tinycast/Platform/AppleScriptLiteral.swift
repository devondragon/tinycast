import Foundation

/// AppleScript string syntax: a path dropped into a script is data, never more script.
enum AppleScriptLiteral {
    static func quoted(_ text: String) -> String {
        let escaped =
            text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}

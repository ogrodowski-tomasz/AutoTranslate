import Foundation
import SwiftUI
import UniformTypeIdentifiers

// Difinig string catalog. This is a type we can open in order to translate xcode's project string catalog
extension UTType {
    static var xcStrings = UTType("com.apple.xcode.xcstrings")!
}

struct TranslationUnit: Codable {
    var state = "translated"
    var value: String
}

struct TranslationLanguage: Codable {
    var stringUnit: TranslationUnit
}

struct TranslationString: Codable {
    var localizations = [String: TranslationLanguage]()
}

struct TranslationDocument: Codable, FileDocument {
    static var readableContentTypes = [UTType.xcStrings]
    
    var sourceLanguage: String
    var strings: [String: TranslationString]
    var version = "1.0"
    
    init(sourceLanguage: String, strings: [String : TranslationString] = [:]) {
        self.sourceLanguage = sourceLanguage
        self.strings = strings
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents { // can we read it as a JSON file?
            self = try JSONDecoder().decode(TranslationDocument.self, from: data)
        } else {
            // assume defaults
            sourceLanguage = "en"
            strings = [:]
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}

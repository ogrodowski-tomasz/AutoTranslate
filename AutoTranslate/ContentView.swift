import SwiftUI
import Translation

struct ContentView: View {
    
    enum TranslationState {
        case waiting, creating, done
    }
    
    @State private var input = "Hello, world!"
    @State private var translationState: TranslationState = .waiting
    
    @State private var configuration =  TranslationSession.Configuration(
        source: Locale.Language(
            identifier: "en"
        ),
        target: Locale.Language(
            identifier: "de"
        )
    )
    
    @State private var languages = [
        Language(id: "ar", name: "Arabic", isSelected: false),
        Language(id: "zh", name: "Chinese", isSelected: false),
        Language(id: "pl", name: "Polish", isSelected: true), // MARK: - SELECTED DEFAULT (Polska gurom)
        Language(id: "nl", name: "Dutch", isSelected: false),
        Language(id: "fr", name: "French", isSelected: false),
        Language(id: "de", name: "German", isSelected: false),
        Language(id: "hi", name: "Hindi", isSelected: false),
        Language(id: "in", name: "Indonesian", isSelected: false),
        Language(id: "it", name: "Italian", isSelected: false),
        Language(id: "ja", name: "Japanese", isSelected: false),
        Language(id: "ko", name: "Korean", isSelected: false),
        Language(id: "pt", name: "Portuguese", isSelected: false),
        Language(id: "ru", name: "Russian", isSelected: false),
        Language(id: "es", name: "Spanish", isSelected: false),
        Language(id: "th", name: "Thai", isSelected: false),
        Language(id: "tr", name: "Turkish", isSelected: false),
        Language(id: "uk", name: "Ukrainian", isSelected: false),
        Language(id: "vi", name: "Vietnamese", isSelected: false)
    ]
    
    @State private var translatingLanguages = [Language]()
    @State private var languageIndex = Int.max
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                Form {
                    ForEach($languages) { $language in
                        Toggle(language.name, isOn: $language.isSelected)
                    }
                }
            }
        } detail: {
            VStack(spacing: 0) {
                TextEditor(text: $input)
                    .font(.largeTitle)
                Group {
                    switch translationState {
                    case .waiting:
                        Button("Create Translations", action: createAllTranslations)
                    case .creating:
                        ProgressView()
                    case .done:
                        Text("Done")
                    }
                }
                .frame(height: 60)
            }
        }
        .translationTask(configuration, action: translate)
        .onChange(of: input) {
//            configuration.invalidate() // we don't want to translate to all langs whenever input changes
            translationState = .waiting
        }
        .onChange(of: languages, updateLanguages)
    }
    
    func translate(using session: TranslationSession) async {
        do {
            if translationState == .waiting {
                try await session.prepareTranslation() // download languages
            } else {
                let result = try await session.translate(input)
                print("DEBUG: \(result.targetText)")
                
                languageIndex += 1
                doNextTranslation()
            }
        } catch {
            print(error.localizedDescription)
            translationState = .waiting
        }
    }
    
    func createAllTranslations() {
        translatingLanguages = languages.filter(\.isSelected)
        languageIndex = 0
        translationState = .creating
        doNextTranslation()
    }
    
    func doNextTranslation() {
        guard languageIndex < translatingLanguages.count  else {
            translationState = .done
            return
        }
        
        let language = translatingLanguages[languageIndex]
        configuration.source = Locale.Language(identifier: "en")
        configuration.target = Locale.Language(identifier: language.id)
        configuration.invalidate()
    }
    
    /// Whenever we add new language. Set it as source and trigger invalidation just to let user download locale into their device not when button is tapped but when user selects a language
    func updateLanguages(oldValue: [Language], newValue: [Language]) {
        let oldSet = Set(oldValue.filter(\.isSelected))
        let newSet = Set(newValue.filter(\.isSelected))
        
        let difference = newSet.subtracting(oldSet)
        
        // This method is called when new language is selected (oldSet-newSet should result in a single object)
        if let newLanguage = difference.first {
            configuration.source = Locale.Language(identifier: newLanguage.id)
            configuration.invalidate()
        }
        
        translationState = .waiting
    }
}

#Preview {
    ContentView()
}

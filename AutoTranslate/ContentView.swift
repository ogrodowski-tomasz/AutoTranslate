import SwiftUI
import Translation

struct ContentView: View {
    
    @State private var input = "Hello, world!"
    
    @State private var configuration =  TranslationSession.Configuration(
        source: Locale.Language(
            identifier: "en"
        ),
        target: Locale.Language(
            identifier: "de"
        )
    )
    
    var body: some View {
        TextEditor(text: $input)
            .font(.largeTitle)
            .translationTask(configuration, action: translate)
    }
    
    func translate(using session: TranslationSession) async {
        do {
            let result = try await session.translate(input)
            print(result.targetText)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}

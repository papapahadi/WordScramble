//
//  ContentView.swift
//  WordScramble
//
//  Created by Jatin Singh on 11/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                    Text("Score : \(score)")
                }
                
                
               
                
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .toolbar{
                Button("next word", action: startGame)
            }
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK"){}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        //extra validation to come
        
        guard isOriginal(word: answer) else {
            wordError(title: "word used already", message: "be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "thats not possible", message: "you cant spell that word from '\(rootWord)' !")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "word not recognised", message: "you cant just make them up, you know!")
            return
        }
        
        guard disAllow(word: answer) else {
            wordError(title: "word too small", message: "mf this is not nursery. think of a big word")
            return
        }
        
        score += answer.count
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func disAllow(word : String) -> Bool {
        if (word == rootWord) || (word.count < 3) {
            return false
        }
        return true
    }
    
    func isOriginal(word : String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word : String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func isReal(word : String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title:String , message:String) {
        errorMessage = message
        errorTitle = title
        showingError = true
    }
    
}

#Preview {
    ContentView()
}

import Testing
@testable import RegiereDeutschlandCore

@Test func languageAndCountryAreIndependent() {
    #expect(GameTextLocalization.translate("Energiepolitik 2000", country: .germany, language: .german) == "Energiepolitik 2000")
    #expect(GameTextLocalization.translate("Energiepolitik 2000", country: .germany, language: .english) == "Energy policy in 2000")
    #expect(GameTextLocalization.translate("The dot-com bubble bursts", country: .unitedStates, language: .german) == "Die Dotcom-Blase platzt")
    #expect(GameTextLocalization.translate("The dot-com bubble bursts", country: .unitedStates, language: .english) == "The dot-com bubble bursts")
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2004", country: .germany, language: .english) == "Next federal election: 2004")
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2004", country: .unitedStates, language: .english) == "Next presidential election: 2004")
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2004", country: .unitedStates, language: .german) == "Nächste Präsidentschaftswahl: 2004")
    #expect(GameTextLocalization.translate("Bundestag", country: .unitedStates, language: .german) == "Kongress")
}

@Test func generatedUSTextTranslatesItsNestedEventText() {
    let source = "Technology shares fall sharply. Silicon Valley layoffs threaten a wider slowdown.\n\nYour administration must choose a response. The outcomes below belong to this alternate-history simulation."
    #expect(GameTextLocalization.translate(source, country: .unitedStates, language: .german) ==
        "Technologieaktien verlieren stark an Wert. Entlassungen im Silicon Valley drohen eine breitere Konjunkturabschwächung auszulösen.\n\nDeine Regierung muss entscheiden, wie sie reagiert. Die folgenden Auswirkungen sind Teil dieser alternativen Geschichtssimulation.")
    let delayed = "The dot-com bubble bursts: the negotiated settlement delivers gradual improvements."
    #expect(GameTextLocalization.translate(delayed, country: .unitedStates, language: .german) ==
        "Die Dotcom-Blase platzt: Die ausgehandelte Einigung bringt schrittweise Verbesserungen.")
}

@Test func unknownPlayerTextIsPreserved() {
    for country in GameCountry.allCases {
        for language in GameLanguage.allCases {
            #expect(GameTextLocalization.translate("Alex 🌍", country: country, language: language) == "Alex 🌍")
        }
    }
}

@Test func germanWorldNewsIsReadableInEnglish() {
    let news = LocalJSONNewsRepository().loadNews()
    #expect(!news.isEmpty)
    for item in news {
        #expect(GameTextLocalization.translate(item.headline, country: .germany, language: .english) != item.headline)
        #expect(GameTextLocalization.translate(item.summary, country: .germany, language: .english) != item.summary)
    }
}

@Test func everyUSEventDescriptionTranslatesAsACompleteText() {
    let events = USEventRepository().loadEvents()
    #expect(events.count == 383)
    for event in events {
        let translated = GameTextLocalization.translate(event.description, country: .unitedStates, language: .german)
        #expect(translated.contains("Deine Regierung muss entscheiden"), "Missing generated suffix for \(event.id)")
        #expect(!translated.contains("Your administration must choose a response"), "English suffix in \(event.id)")
        #expect(!translated.contains("Fictional "), "English scenario context in \(event.id)")
    }
}

@Test func usElectionAndOfferTextUsesTheSelectedLanguage() {
    let election = "Opposition: 268 electoral votes. A 269–269 tie ends this campaign because no majority was secured."
    #expect(GameTextLocalization.translate(election, country: .unitedStates, language: .german) == "Opposition: 268 Wahlleutestimmen. Ein Gleichstand von 269 zu 269 beendet diese Kampagne, da keine Mehrheit erreicht wurde.")
    #expect(GameTextLocalization.translate(election, country: .unitedStates, language: .english) == election)
    #expect(GameTextLocalization.translate("Restore purchases", country: .unitedStates, language: .german) == "Käufe wiederherstellen")
}

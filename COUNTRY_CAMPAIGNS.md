# Germany and United States campaigns

The launch screen always asks for a country. The home screen provides a country
switch. Country controls language and content independently of the device locale.

## Preserving Germany

- German event and news JSON files remain unchanged.
- Core APIs still default to Germany; missing `country` in an old save decodes as
  Germany. German save filenames, preference keys, and storage location remain
  unchanged.
- Existing German purchase screens, products, entitlements, and prices are kept.
- The original 103 core tests remain part of the complete test suite.

## Country boundaries

`GameCountry` is immutable in an engine and travels with `GameSessionSnapshot`.
An American engine loads `USEventRepository`, never the German repositories.
`GamePersistence(country:)` separates saves, completed runs, and achievements.

| Data | Germany | United States |
| --- | --- | --- |
| Save | `RegiereDeutschland/savegame.json` | `RegiereDeutschland/UnitedStates/savegame.json` |
| Runs | `RegiereDeutschland/run-results.json` | `RegiereDeutschland/UnitedStates/run-results.json` |
| Achievements | `RegiereDeutschland/achievements.json` | `RegiereDeutschland/UnitedStates/achievements.json` |
| Name, difficulty, onboarding preferences | Existing keys | Existing keys with `.us` appended |

Each window owns its own `GamePresentation`, used only by SwiftUI. Its English cache clears on country
changes; static onboarding content remains in the source language so switching
back to Germany never reuses English text. Shared mechanics use the explicit
`USEnglish.json` catalog, including interpolated messages and accessibility text.

## American content and game rules

- Four playable parties: Democratic, Republican, Libertarian, and Green. Custom
  parties retain the existing founder and platform mechanics.
- 108 decisions for 2000–2026, with four decisions each year. Settings through
  2024 are historical; their response options and simulated effects are alternate
  history. The 2025 and 2026 policy dilemmas are explicitly fictional.
- The future expansion has 200 mandatory scenario decisions and 75 additional
  events for 2026–2050. All future content is identified as fiction.
- Earlier broadband investment and mortgage oversight alter later responses.
  The 2030 crisis has intervention and crisis-prevention branches, which change
  reconstruction costs. The 2050 settlement changes the final legacy text.
- Presidential elections occur in 2004, 2008, …, 2048. Midterms update a simplified
  congressional-support indicator in 2002, 2006, … . Congressional revolts reduce
  influence and trust and do not call snap presidential elections.
- The Electoral College uses 538 votes, census-era allocations, and a 270-vote
  winning threshold. State partisan margins are fictional and move with the
  national vote. Maine and Nebraska are modeled statewide. A tie ends the
  campaign rather than simulating a contingent election in Congress. These limits
  are stated on the results screen. Congressional support is not a full model of
  House districts, Senate seats, or state delegations.
- The long campaign follows successive administrations of a party, rather than
  claiming that one individual can serve as president for fifty years. The
  briefing and onboarding state the two-elected-term limit and the fictional
  premise of minor-party victories.
- Cabinet appointments use fictional American names. US diplomacy targets Canada,
  the EU, Russia, and China; the US never conducts diplomacy with itself.

Run `rtk proxy python3 scripts/build_us_campaign.py` to regenerate the independent
US catalogs. Event identifiers are explicit and must remain stable when editing
titles or inserting content, so existing saves remain usable.

## Purchases

Both countries use the existing main-campaign and future-campaign entitlements.
The same purchase unlocks its corresponding content in both countries, while
progress remains separate. The USA uses separate English RevenueCat paywalls:

| Placement | Germany (unchanged) | United States |
| --- | --- | --- |
| Catalog, main campaign not owned | `katalog_1_6` | `catalog_us` |
| After free prologue | `kampagne_2005` | `campaign_us` |
| Future expansion / US catalog with main campaign owned | `zukunft_2050` | `future_us` |

The English offerings duplicate the packages of the published German offerings;
StoreKit products, entitlements, pricing and the project default stay the same.
The app selects by the window's campaign country, without changing RevenueCat's
global preferred locale. Owners of the main campaign see the future offering
with its expansion selected, avoiding a hidden selected bundle. Owners of all
content keep the English purchase-management screen. Until the US dashboard
drafts are explicitly published (or when unavailable), an English native
purchase and restore screen remains available. Store prices come
from the actual RevenueCat packages. Cancellation is silent, buttons are disabled
during a transaction, and access is read from customer entitlements.

Core access and continuation behavior is tested. The simulator build and rendered
US gameplay were checked. No App Store or sandbox transaction was executed;
purchase, cancellation, and restore against a sandbox account remain release QA.

## Historical and institutional reference points

The simulation's numerical effects and fictional state margins are game design,
not historical measurements or election forecasts.

- [National Archives: Electoral College](https://www.archives.gov/electoral-college/about)
- [National Archives: Electoral College questions, including contingent elections](https://www.archives.gov/electoral-college/faq)
- [US Senate: terms and staggered elections](https://www.senate.gov/senators/qualifications_termsofservice.htm)
- [Federal Reserve History: the Great Recession and its aftermath](https://www.federalreservehistory.org/essays/great-recession-and-its-aftermath)
- [Federal Reserve: the dot-com downturn and financial vulnerabilities](https://www.federalreserve.gov/econres/notes/feds-notes/relationship-between-macroeconomic-overheating-and-financial-vulnerability-narrative-20181012.html)

Run the complete verification with `rtk swift test` and build the
`RegiereDeutschland` Xcode scheme for the iOS Simulator.

The window-local presentation/cache check can also be run on Apple Silicon after
the package tests have compiled the core:

```sh
rtk proxy swiftc -parse-as-library -target arm64-apple-macosx14.0 \
  -I .build/arm64-apple-macosx/debug/Modules \
  Sources/RegiereDeutschlandApp/App/GameTheme.swift \
  Sources/RegiereDeutschlandApp/App/GamePresentation.swift \
  Sources/RegiereDeutschlandApp/Monetization/Monetization.swift \
  scripts/check_window_country.swift \
  .build/arm64-apple-macosx/debug/RegiereDeutschlandCore.build/*.o \
  -o /tmp/WindowCountryCheck
rtk proxy /tmp/WindowCountryCheck
```

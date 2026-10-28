# US RevenueCat paywalls

Created on 2026-10-26 in project `proj4cc080a0` (Regiere Deutschland).
All three are saved, unpublished drafts. Publication requires an explicit user
request. The app keeps its English native purchase screen until a published
US paywall is available; no default RevenueCat paywall or German screen is used
as the US fallback.

| Screen | Offering identifier | Offering ID | Paywall ID |
| --- | --- | --- | --- |
| Campaign catalog | `catalog_us` | `ofrng90027cfa1e` | `pw5c8f1894f9fc4ae7` |
| After prologue | `campaign_us` | `ofrng09eb5229b4` | `pw7abb5f7bf08c45ec` |
| Future expansion | `future_us` | `ofrngc21a39745c` | `pw2f0c35d8141d4c6d` |

- [Catalog editor](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw5c8f1894f9fc4ae7/builder)
- [After-prologue editor](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw7abb5f7bf08c45ec/builder)
- [Future editor](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw2f0c35d8141d4c6d/builder)

## Products and access

Each offering was duplicated from the corresponding **published** German
offering, retaining the existing product attachments. The project default is
still `default1`. No products, prices, entitlement attachments or store settings
were changed. Main and bundle purchase options select the bundle by default;
the future screen shows only its existing expansion package, selected by
default. Its offering still retains the copied bundle package, which is not
displayed by this paywall.

US catalog users who already own the main campaign are routed to `future_us`
to avoid leaving a hidden bundle selected. Users who own both campaigns see
the native English purchase-management screen. Germany keeps the three
original offering identifiers and original paywalls.

## Language and price bindings

Country is taken from each window's `GamePresentation`, independently of device
language. RevenueCat's global preferred UI locale is not modified. Referenced
strings in all US paywalls are English. The catalog retains its copied
`de_DE` default-locale metadata but its displayed strings are English. The
after-prologue paywall defaults to `en_US`; its `de_DE` strings intentionally
match English so US players on German-language devices still see English.
The future paywall defaults to `en_US`.

Prices use `{{ product.price }}`. Savings use client-calculated
`bundle_saving` and `show_bundle_saving`; the calculation requires matching
StoreKit currencies and a positive saving, and is suppressed for existing
main-campaign owners. `has_main_campaign` is a boolean custom variable with
default `false` used for package visibility. Existing custom variables remain.
The preview renderer uses representative prices for products without store
prices in its API response; preview dollar amounts are not a price change.

Restore, close, EULA and privacy links are preserved. The privacy destination
remains the existing German support site's data-protection page.

## Verification

- Exact paywall component inspection: product bindings, default selections,
  dynamic price strings, English referenced strings and restore/legal actions.
- Rendered draft screenshots reviewed; the prologue layout was tightened and
  price columns protected from being squeezed out by long titles.
- Original German paywall revisions/publication timestamps remain unchanged:
  catalog revision 2, prologue revision 4, future revision 6.
- 119 core tests passed.
- Window-country check passed, including all German/US offering mappings and
  ownership-based US catalog routing.
- iOS Simulator build passed with RevenueCat/RevenueCatUI 5.83.2.
- No sandbox/live purchase or restore transaction was executed. Rendering the
  published remote paywalls in the app and transaction testing remain release QA
  after publication; only standard-size draft previews were visually inspected.

# Worldwide product changes

Plan `20db03e0-7113-4474-9a13-b51407c50cff` is **planned**, not applied.
The user requested English plus German and availability in every country.

| Product | Availability before → after | English name | English description |
| --- | --- | --- | --- |
| Main campaign | All 175 → all 175 | Main campaign 2005–2026 | Unlock 2005–2026 and all Pro features. |
| Future expansion | AT/CH/DE → all 175 | Future 2050 | Continue to 2050. Main campaign required. |
| Complete bundle | AT/CH/DE → all 175 | Complete bundle 2005–2050 | Main campaign and Future 2050, permanently. |

The future expansion and bundle each gain 172 territories and automatic
availability in future Apple territories. The main campaign already has both.
Existing German localizations are retained. Product IDs, non-consumable types,
entitlements and package bindings remain unchanged.

Existing territory prices are preserved. Main campaign prices are not sent in
the desired state. For future/bundle the existing AT/CH/DE prices are retained;
Apple fills new countries' prices from the existing Austrian base price.
This is a one-time-product price schedule, not subscription equalization.
No existing-price change appears in the planned diff. New calculated prices
must be checked after apply because they are filled by Apple at apply time.

| Existing price | Main | Future | Bundle |
| --- | --- | --- | --- |
| Austria / Germany | EUR 4.99 | EUR 6.99 | EUR 9.99 |
| Switzerland | CHF 3.00 | CHF 5.00 | CHF 8.00 |
| United States (existing) | USD 3.99 | Not yet available | Not yet available |

## Validation messages

Each product has the same informational message at `store_status`: the product
is already approved in App Store Connect. No warning- or blocker-severity
messages, no planning errors, and no review-screenshot changes were returned.

[Review the plan](https://app.revenuecat.com/projects/proj4cc080a0/product-catalog/product-editor/review-changes?plan_id=20db03e0-7113-4474-9a13-b51407c50cff)

Applying changes requires the user's explicit confirmation after the planned
diff has been shown, as required by the RevenueCat store-state skill/tool.

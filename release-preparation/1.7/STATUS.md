# Release preparation 1.7 / build 3

Prepared on 26 October 2026.

## Completed locally

- German and US English app metadata, release notes, promotional text and keywords.
- Character limits checked: German keywords 93 characters / 94 UTF-8 bytes;
  English keywords 94 characters / 94 bytes; descriptions below 4,000;
  promotional texts below 170.
- English app name and subtitle prepared; existing German name retained.
- English App Review notes describe country selection, shared purchases,
  separate saves, fictional scenarios and purchase/restore access.
- English localizations prepared for all three existing non-consumables, keeping
  existing German localizations. This JSON is prepared only, not applied.
- Xcode Debug and Release configurations updated to version 1.7 / build 3.
- Simulator build passed; built Info.plist confirms version 1.7 / build 3.

## App Store Connect session

- Existing version 1.6 is Ready for Distribution.
- Requested creation of version 1.7 in the open Chrome profile Hasan.
- The address changed to `/distribution/ios/version/inflight`, but the native
  accessibility view remained on the submitting New Version dialog. Creation
  has not yet been confirmed by a fresh version-detail view.
- The connected Chrome extension currently exposes profile Mein Chrome,
  not the user's Hasan profile. The user is connecting the correct profile.
- German/English metadata has not yet been saved in App Store Connect.
- Automatic release after approval has not yet been saved or verified.
- No build upload or Apple review submission was performed.

## Store state verified through RevenueCat

All three existing Apple products are approved. Current snapshots are saved
alongside this file; prices and availability were not changed.

| Product | US available | Current localizations |
| --- | --- | --- |
| Main campaign | Yes; USD 3.99 | German only |
| Future 2050 | No; AT/CH/DE only | German only |
| Complete bundle | No; AT/CH/DE only | German only |

The future expansion and complete bundle need deliberate US storefront
availability and pricing preparation before US customers can buy them. Existing
AT/CH/DE prices must be preserved. No availability plan has been applied.

The three English RevenueCat dashboard paywalls also remain unpublished drafts;
the app's English native fallback is available meanwhile.

## Remaining before submission

1. Confirm version 1.7 was created, then save both locales and review notes.
2. Save and verify “Automatically release this version” without a future date.
3. Inspect inherited screenshots and prepare English screenshots as needed.
4. Finish US purchase availability/localizations and publish English paywalls
   after the relevant review/authorization.
5. Upload and select the final signed 1.7 / build 3 binary, complete build-specific
   questions and transaction testing, and only then submit when authorized.

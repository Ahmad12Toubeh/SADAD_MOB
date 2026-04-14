# SADAD_MOB Structure Report

Date: 2026-04-14

## Goal

Bring `SADAD_MOB` closer to the active frontend structure used in `SADAD_web`, especially at the feature-map and routing level.

## Current Findings

1. `SADAD_MOB` already uses a clean feature-based layout under `lib/features`.
2. The mobile app was missing two frontend-visible modules that exist in the web app:
   - `owner`
   - `subscriptions`
3. Web behavior shows that `subscriptions` is only a gateway that redirects to `owner`.
4. Mobile settings did not expose owner/subscription management for privileged users.
5. Several mobile features still keep API parsing inside presentation providers instead of separating models/repositories/services per feature.

## Changes Applied In This Pass

1. Added `owner` feature to `SADAD_MOB`.
2. Added `subscriptions` feature to `SADAD_MOB`.
3. Added `/owner` route.
4. Added `/subscriptions` route that forwards users to `/owner`.
5. Added owner/subscription entry points inside settings for admin/owner users.
6. Added localization strings required for the new screens.

## Remaining Alignment Gaps

1. Feature internals are still lighter than the web app in some places.
2. Many mobile providers still mix API calling, DTO parsing, and view state.
3. Full parity still needs another pass for richer owner actions, better settings integration, and stronger feature separation.

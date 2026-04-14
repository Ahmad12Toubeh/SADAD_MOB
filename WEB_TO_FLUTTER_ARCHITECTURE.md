# SADAD Web To Flutter Architecture

## SADAD_web Structure

`SADAD_web/src` is split into four main layers:

1. `app/`
   Handles route structure and page entry points.
2. `components/`
   Reusable UI pieces and layout sections.
3. `lib/`
   Shared application logic such as API, i18n, locale helpers, utilities, and exports.
4. `contexts/`
   App-wide providers such as theme and i18n bootstrapping.

## Web Route Groups

The web app uses these route groups:

1. `(auth)`
   - `/login`
   - `/register`
   - `/forgot-password`
   - `/reset-password`
2. `(dashboard)`
   - `/dashboard`
   - `/dashboard/analytics`
   - `/dashboard/associations`
   - `/dashboard/associations/[id]`
   - `/dashboard/customers`
   - `/dashboard/customers/new`
   - `/dashboard/customers/[id]`
   - `/dashboard/debts`
   - `/dashboard/debts/new`
   - `/dashboard/debts/[id]`
   - `/dashboard/guarantors`
   - `/dashboard/guarantors/[id]`
   - `/dashboard/reminders`
   - `/dashboard/settings`
   - `/dashboard/subscriptions`
   - `/dashboard/owner`
3. `owner`
   - `/owner`

## Flutter Mapping

To make `SADAD_MOB` match the same product structure, Flutter should mirror the same intent:

1. Auth routes outside the shell.
2. Dashboard shell routes inside shared layout.
3. Owner route outside the dashboard shell.
4. Feature pages grouped into:
   - list page
   - new/create page
   - detail page

## Flutter Folder Direction

Recommended per feature:

- `presentation/pages/`
- `presentation/providers/`
- `presentation/widgets/`
- `data/`
- `domain/`

## Current Refactor Status

Implemented:

1. Owner feature and route.
2. Subscriptions route as owner redirect.
3. Settings access points for owner/admin users.
4. Route placeholders for the web-style nested feature pages.

Still needed for full parity:

1. Real create/detail forms for customers and debts.
2. Association detail workflow.
3. Guarantor detail workflow.
4. Shared widget parity with web `components/ui`.
5. Stronger data/domain separation inside each feature.

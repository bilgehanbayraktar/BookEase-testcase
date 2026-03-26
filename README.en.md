# BookEase

This repo contains a reservation / appointment system project prepared for the BookEase case study.

Technologies:

- Backend: `ASP.NET Core 8 Web API`
- Database: `PostgreSQL`
- Cache: `Redis`
- Frontend: `Flutter Web`
- Auth: `JWT Access + Refresh Token`

In short, the system works like this:

- The business owner creates a business
- Adds services to the business
- Creates slots for those services
- The customer sees active businesses and available slots
- The customer creates or cancels reservations
- The business owner confirms / cancels incoming reservations

The project includes the 2 main roles from the case document (`customer`, `business_owner`). In addition to that, an `admin` role was added for practical usage.

## Project Structure

The repo consists of two main parts:

- `backend/BookEase.API`
- `frontend/bookease_app`

### On the backend side

- JWT auth exists
- refresh token support exists
- Entity Framework Core is used
- writes to PostgreSQL
- some data is cached with Redis
- Swagger is enabled
- error handling is centralized through middleware

### On the frontend side

- Flutter Web is used
- `Riverpod` is used for state management
- `GoRouter` is used for routing
- `Dio` is used for HTTP requests
- `flutter_secure_storage` is used for token storage
- role-based screens and navigation exist

## Data Model

The project mainly includes these entities:

- `User`
- `Business`
- `Service`
- `Slot`
- `Booking`

Relationship summary:

- One `User` can own multiple `Business` records
- One `Business` can contain multiple `Service` records
- One `Service` can contain multiple `Slot` records
- One `Slot` can receive multiple `Booking` records

## Roles

### Customer

Customer side currently includes these flows:

- login / register
- business list
- business detail
- listing slots by service
- creating bookings
- viewing my bookings with filters
- cancelling bookings
- profile screen

### BusinessOwner

On the business owner side:

- view owned businesses
- create business
- add service
- delete service
- create slot
- view bookings coming to owned businesses
- confirm / cancel reservations
- profile screen

### Admin

The admin side was not mandatory in the case document, but it was added to the project.

Currently these actions are possible:

- create `Customer`
- create `BusinessOwner`
- create `Admin`
- create business
- list all businesses
- open business management screen
- add / delete service
- create slot
- view reservations of the selected business

Note:

Because the backend does not expose a separate endpoint for listing users on the admin side, the admin enters the `BusinessOwner ID` manually while creating a business. The admin panel shows the ID on screen after creating a new owner.

## Screens

The following screens currently exist on the frontend:

- `LoginScreen`
- `RegisterScreen`
- `BusinessListScreen`
- `BusinessDetailScreen`
- `SlotListScreen`
- `CreateBookingScreen`
- `MyBookingsScreen`
- `ProfileScreen`
- `MyBusinessesScreen`
- `ManageBusinessScreen`
- `BusinessBookingsScreen`
- `OwnerBookingsScreen`
- `AdminHomeScreen`
- `AdminBusinessesScreen`

## API Summary

Main endpoint groups:

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/create-admin`

### Business

- `GET /api/businesses`
- `GET /api/businesses/{id}`
- `POST /api/businesses`
- `PUT /api/businesses/{id}`
- `DELETE /api/businesses/{id}`

### Service

- `GET /api/businesses/{businessId}/services`
- `POST /api/businesses/{businessId}/services`
- `PUT /api/businesses/{businessId}/services/{id}`
- `DELETE /api/businesses/{businessId}/services/{id}`

### Slot

- `GET /api/services/{serviceId}/slots`
- `POST /api/services/{serviceId}/slots`
- `POST /api/services/{serviceId}/slots/bulk`
- `DELETE /api/services/{serviceId}/slots/{id}`

### Booking

- `POST /api/bookings`
- `PUT /api/bookings/{id}/confirm`
- `PUT /api/bookings/{id}/cancel`
- `GET /api/bookings/my`
- `GET /api/businesses/{businessId}/bookings`

## Are The Case Requirements Covered?

Quick status summary according to the case document:

### Mandatory items

`1. Auth — Register, Login, Refresh Token`

- completed
- register / login / refresh exist
- password hashing is done with `BCrypt`

`2. Business & Service Management (CRUD)`

- mostly completed
- business create / update / delete exist on the backend
- service create / update / delete exist on the backend
- create and delete flows are active on the frontend
- a separate service update screen was not implemented

`3. Slot Management`

- completed
- slot creation exists
- slot listing exists
- slot delete exists on the backend
- full slots are visible on the frontend but cannot be clicked

`4. Booking — Create & Cancel`

- completed
- customer can create reservations
- an error is returned if capacity is full
- customer can cancel own booking
- business owner can confirm / cancel reservations
- cancellation is handled as a soft status update

`5. Booking Listing (filtered, paginated)`

- mostly completed
- customer can see own reservations with status filter
- customer side has pagination
- business owner can see bookings coming to the business
- backend business bookings endpoint supports page/pageSize
- date range filtering exists on the backend, but a dedicated frontend date range UI was not added

`6. Flutter App — Core Screens & State Management`

- completed
- login/register screens exist
- business list / detail screens exist
- slot list and date picker exist
- booking creation screen exists
- my bookings screen works with filters
- state management is `Riverpod`
- token management exists, session is preserved

### Bonus items

`7. SignalR`

- not implemented

`8. Redis Cache`

- implemented
- business list and slot list use cache
- cache is cleared on booking / slot changes

`9. Reporting & Charts`

- not implemented

## What I Still See As Missing

Honest list:

- no separate service update screen
- slot delete is not exposed as a direct frontend button
- no date range filter UI for business owner reservations
- SignalR was not implemented
- reporting / charts were not implemented
- automated test count is still low, especially no backend tests
- some admin flows are still a bit manual because there is no user listing endpoint

## Why I Chose This Structure

Reasons for this structure:

- Keeping backend and frontend separate made things cleaner
- The `Service` layer helped keep controllers from getting too crowded
- `Riverpod` made auth and data flow easier to manage
- `GoRouter` made role-based redirection easier
- `Dio` interceptor helped centralize token refresh logic
- Using Redis for frequently read data like business list and slot list made sense

I did not try to build a huge enterprise architecture. For a case study, I aimed for something understandable and comfortable to develop.

## Setup

### Requirements

These should be installed on your machine:

- `.NET 8 SDK`
- `Flutter SDK`
- `Chrome`
- `PostgreSQL`
- `Redis`

Optional:

- `dotnet-ef`

## Running The Backend

First create your own config from the example config:

```bash
cp backend/BookEase.API/appsettings.Example.json backend/BookEase.API/appsettings.json
```

Then fill these fields:

- `ConnectionStrings:DefaultConnection`
- `ConnectionStrings:Redis`
- `Jwt:SecretKey`
- `SeedAdmin`

Run the migration:

```bash
dotnet ef database update --project backend/BookEase.API/BookEase.API.csproj
```

Start the API:

```bash
dotnet run --project backend/BookEase.API/BookEase.API.csproj --launch-profile http
```

Expected address:

```text
http://localhost:5154
```

Swagger is enabled in development.

## Running The Frontend

```bash
cd frontend/bookease_app
flutter pub get
flutter run -d chrome
```

The frontend is connected to this API address:

```text
http://localhost:5154/api
```

## Auth and Session Note

- access token and refresh token are used
- frontend stores the token in secure storage
- session is preserved when the app is opened again
- when `401` is returned, refresh is attempted
- if refresh fails, the user is sent back to login

## Cache Note

Redis is used in these areas:

- active business list
- service-based slot list

Cache is cleared in these situations:

- if a business changes
- if a slot is created / deleted
- if a booking is created / cancelled

## Error Handling

There is a centralized exception middleware on the backend.

Returned error shape:

```json
{
  "status": 409,
  "error": "Slot is fully booked."
}
```

## Project Tree

```text
.
├── backend/
│   └── BookEase.API/
│       ├── Controllers/
│       ├── DTOs/
│       ├── Data/
│       ├── Middleware/
│       ├── Migrations/
│       ├── Models/
│       ├── Services/
│       ├── appsettings.Example.json
│       └── Program.cs
├── frontend/
│   └── bookease_app/
│       ├── lib/
│       │   ├── core/
│       │   ├── models/
│       │   ├── providers/
│       │   ├── screens/
│       │   └── widgets/
│       ├── test/
│       ├── web/
│       └── pubspec.yaml
└── book_ease_test_case.sln
```

## Verification

These commands were run on the frontend side:

```bash
flutter analyze
flutter test
flutter test --platform chrome
```

## If I Had More Time

I would add:

- live slot updates with SignalR
- dashboard / reporting screens
- backend unit/integration tests
- user listing and owner picker screen for admin
- better form validation and toast / error UX
- one-command local setup with Docker Compose

## Final Note

In my opinion, this project covers the main case study flow:

- auth exists
- refresh token exists
- business / service / slot / booking flow exists
- customer and business owner scenarios work
- Redis bonus exists

There are still missing parts, but it is also clear where those missing parts are. In this state, it is a readable, extendable, and demo-ready project.

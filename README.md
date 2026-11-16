# Invest Order Flow – Flutter

## 1. Project Overview

Invest Order Flow is a Flutter application that allows investors to place investment orders in INR or USD.

The application allows users to:

- Select INR or USD.
- View their available balance.
- Enter an investment amount.
- Validate the amount before continuing.
- Review order details before confirmation.
- Place an investment order.
- View the success or failure result.

## 2. Setup and How to Run

### Requirements

- Flutter SDK - 3.47.7
- Dart SDK - 3.13.5
- Android Studio or VS Code
- Android Emulator or physical Android device

### Installation

Clone the repository and open the project directory.

Run the following command:

```bash
flutter pub get
```

To run the application:

```bash
flutter run
```

To run automated tests:

```bash
flutter test
```

To check code quality:

```bash
flutter analyze
```

To generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be available at:

`build/app/outputs/flutter-apk/app-release.apk`

### API Configuration

The API base URL is configured in:

`lib/core/api_config.dart`

The application uses the provided mock API:

https://unbordered-flutter-assignment.tech-c06.workers.dev

## 3. Assumptions and Decisions

The following decisions were made while implementing the assignment:

1. INR is selected by default when the application opens.
2. Fund name and description are hard-coded as allowed in the assignment.
3. INR minimum investment is ₹1,000 and maximum investment is ₹5,00,000.
4. USD minimum investment is $10 and maximum investment is $10,000.
5. Amounts must be positive numbers with a maximum of two decimal places.
6. The entered amount is checked against the available balance.
7. When the user changes currency, the amount is validated again using the selected currency's limits and balance.
8. Money calculations use integer minor units (paise/cents) to avoid floating-point precision issues.
9. The balance is updated locally after a successful order because the mock API returns fixed balances.
10. The order request has a 10-second timeout.
11. The application displays a timeout message explaining that the order status could not be confirmed.
12. An `Idempotency-Key` header is sent with order requests. The mock API ignores this header, but a real backend could use it to prevent duplicate orders.
13. Flutter Navigator is used for navigation between the three screens.
14. The "Enter an amount" error is shown only after the user starts typing, so the screen does not open with an error. Continue stays disabled.
15. Only digits and one decimal point can be typed. Thousands separators like `5,000` are not accepted.
16. While an order is being placed, the Confirm button is disabled and back navigation is blocked. Extra taps are also ignored by the BLoC, so only one order is sent.
17. For a 500 error, a friendly message is shown instead of the raw server message. For a 400 error, the server's message is shown because it is about the amount.
18. **Edit Amount** keeps the entered amount and currency. **Done** clears the amount and shows the updated balance.
19. On the Result screen, the Android back button works like Done on success and like Edit Amount on failure.
20. The order time is shown in the device's local time zone (the API returns UTC).
21. The locally updated balance is kept in memory only and resets when the app restarts.

## 4. State Management and Project Structure

### State Management

I used BLoC (Business Logic Component) for state management.

I selected BLoC because it separates UI code from business logic and makes application behavior easier to test and maintain.

The application follows this flow:

**Event → BLoC → State → UI**

- Events represent user actions.
- BLoC handles business logic and API operations.
- States represent the current application status.
- The UI listens to state changes and updates accordingly.

I used `BlocBuilder` to rebuild the UI when the state changes and `BlocListener` for handling one-time UI actions.

I also used the `droppable()` event transformer to prevent repeated order submissions while an order request is in progress.

### Project Structure

```text
lib/
├── core/        API config, Dio client, failures, formatters, amount validator
├── models/      Currency, Fund, Balances, Order (with fromJson / toJson)
├── services/    InvestApi (contract) and HttpInvestApi (Dio implementation)
├── bloc/        InvestBloc, events and state
├── pages/       Invest, Confirm and Result screens
├── widgets/     Small reusable widgets
├── app.dart
└── main.dart

test/
├── amount_validator_test.dart
├── invest_api_test.dart
└── invest_bloc_test.dart
```

### How It Fits Together

- **Models** hold the data and know how to read and write their own JSON.
- **InvestApi** is an abstract contract with the two calls. **HttpInvestApi** implements it with Dio and turns every error (500, 400, timeout, no internet) into a `Failure`, so the BLoC and screens never deal with HTTP details.
- **InvestBloc** holds the state for all three screens and depends only on the `InvestApi` contract.
- **Pages** only show the state and send events.

`InvestApi` and `InvestBloc` are provided at the top of the widget tree with `MultiRepositoryProvider` and `MultiBlocProvider`, and read with `context.read`. The BLoC gets the API through its constructor, so tests pass a mock instead of calling the shared server.

I kept the structure flat because the app has one feature and two API calls, but the main Clean Architecture rule still holds: the BLoC depends on an abstraction, not on Dio. With more features, I would group files by feature and split each into domain and data layers. The BLoC would not need to change.

Example: placing an order

```text
ConfirmPage   → adds OrderSubmitted
InvestBloc    → api.placeOrder(request)
HttpInvestApi → Dio POST /orders (10 second limit), errors become Failure
InvestBloc    → emits success or failure
ResultPage    → shows the result
```

## 5. Time Taken, Scope and Future Improvements

### Actual Time Taken

The total time spent on the assignment was approximately 3 hours.

| Task | Time Taken |
|---|---:|
| Project setup and structure | 10 minutes |
| API integration | 25 minutes |
| Invest screen and amount validation | 35 minutes |
| Confirm screen | 15 minutes |
| Result screen | 20 minutes |
| BLoC implementation | 35 minutes |
| Automated tests | 25 minutes |
| README and documentation | 10 minutes |
| Build and screen recording | 5 minutes |
| **Total** | **180 minutes (3 hours)** |

### What I Simplified

To keep the implementation within the assignment scope:

- Used hard-coded fund information.
- Used local balance updates after successful orders.
- Used a single BLoC to manage the investment flow.
- Focused automated tests on validation, BLoC behavior, JSON parsing and API error handling.
- Used Flutter's built-in navigation.

### What I Would Improve With More Time

- Add more widget and integration tests.
- Add backend-supported idempotency to prevent duplicate orders.
- Add order-status verification after a timeout.
- Improve accessibility and localization.
- Add persistent balance management through a backend.

## 6. Third-Party Packages

| Package | Purpose |
|---|---|
| flutter_bloc | State management |
| bloc_concurrency | Control event processing |
| equatable | Value comparison |
| dio | HTTP requests and API communication |
| intl | Date and number formatting |
| lottie | Success animation |
| uuid | Generate an idempotency key for each order |
| bloc_test | BLoC unit testing |
| mocktail | Mock dependencies in tests |

### Lottie Animation Source and License

- **Source:** [LottieFiles Animation](https://lottiefiles.com/free-animation/check-jSOmPyr6eH)
- **Usage:** Used for the successful investment order screen.
- **License:** Free to use under the Lottie Simple License.

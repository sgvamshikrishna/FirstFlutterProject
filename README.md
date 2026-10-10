# MyTracker

Flutter prototype with schedule conflict detection, expense tracking, dietary preferences, and an AI assistant.

## Try without credentials

```sh
flutter pub get
flutter run
```

Tap **Open AI assistant** from any main screen. The default mode is clearly labeled **Offline sample / Simulated AI**. Try the four tasks: Plan my day, Daily summary, Meal ideas, and Spending insights. Offline responses use rules and fixtures, not an AI model.

For scheduling, try `Dentist appointment at 10:30 am for 30 minutes`. Click Try sample, then Confirm appointment to see the conflict with the existing meeting and a free-time suggestion. Ask again with `Dentist appointment at 3 pm for 30 minutes`, review the preview, and confirm to add it. No appointment is saved automatically.

## Enable real AI for the sample

The included Dart backend calls the OpenAI Responses API with Structured Outputs. It needs no extra backend packages. Keep the API key on your development computer, never in Flutter code or a Dart build flag.

In one PowerShell terminal:

```powershell
$env:OPENAI_API_KEY = 'your-api-key'
$env:OPENAI_MODEL = 'gpt-4o-mini' # optional; use a compatible model your account supports
 dart run backend/server.dart
```

In another terminal, for Windows desktop or Chrome:

```sh
flutter run -d windows --dart-define=AI_BACKEND_URL=http://127.0.0.1:8080/ai
# Or:
flutter run -d chrome --dart-define=AI_BACKEND_URL=http://127.0.0.1:8080/ai
```

For an Android emulator:

```sh
flutter run --dart-define=AI_BACKEND_URL=http://10.0.2.2:8080/ai
```

Restart the app after changing build flags. Android debug builds permit local HTTP. A physical phone needs a reachable HTTPS backend; its localhost is not your computer. The included backend binds to loopback and is for development only: it has no authentication or rate limits and must not be exposed publicly. For deployment add authentication, request limits, restricted CORS, and HTTPS. Apple platforms may require local networking permissions for local HTTP; use HTTPS for a hosted backend.

With the backend configured, the assistant requests real model responses for all four tasks using the current mock schedule, transactions, and dietary preference. The UI shows loading and error states. Failed live requests never silently become demo responses. Requests send the entered prompt and context to the configured backend and OpenAI. Provider usage may incur charges.

The backend validates input, handles provider errors/refusals, and returns a structured message and optional appointment. The Flutter client validates appointment fields and checks conflicts again at confirmation. Scheduling currently supports **today only**; future dates and ambiguous requests require clarification. AI outputs should be reviewed.

Official implementation reference: [OpenAI Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs).

## Prototype boundaries

The original four screens share a ChangeNotifier model with ListenableBuilder. Data is in memory and resets on restart. Voice is still a typed sample transcript; microphone transcription is not implemented. Apple Pay imports are sample transactions, not a connected wallet. Nutrition-screen swaps remain curated options; use the assistant for live AI meal suggestions.

Real AI integration is implemented but requires a configured backend and valid provider credentials. Offline sample mode alone does not satisfy the assignment's AI requirement. Persistent storage remains a separate requirement to implement before final submission.

## Validation

```sh
flutter analyze
flutter test
```

Tests cover scheduling boundaries, expense validation, responsive navigation, request/response handling with a mocked HTTP provider, malformed appointments, live-service failures, and assistant conflict/confirmation flows. An actual provider call requires your credentials and is not part of automated tests.

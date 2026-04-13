# Psychometric Prep — Claude Code Guide

## What this app is
A free, serverless Flutter mobile app for students preparing for the Israeli Psychometric exam (מבחן הפסיכומטרי). No backend, no cost. All content is in `assets/data.json`, all progress in Hive on-device.

## Key architectural decisions
- **State management:** `provider` with `ChangeNotifier` — do not introduce Riverpod or Bloc.
- **Persistence:** Three Hive boxes only (`vocab_progress`, `math_scores`, `practice_stats`). Do not add a database or remote sync.
- **Data:** All questions and vocab live in `assets/data.json`, loaded at startup by `DataService`. Math Sprint problems are **generated at runtime**, not stored in JSON.
- **Layout:** Standard LTR layout. Hebrew text is displayed correctly without flipping the entire layout to RTL.

## Theme
```
Primary (orange):      #F57C00
Dark orange (text):    #E65100
Correct/green:         #66BB6A
Background:            warm white
```
Always use `Theme.of(context)` — do not hardcode colors outside `main.dart`.

## Folder structure
```
lib/features/home/          — quick_launch_screen.dart
lib/features/vocabulary/    — deck_picker_screen.dart, flashcard_screen.dart
lib/features/practice/      — subject_picker_screen.dart, question_screen.dart
lib/features/math_sprint/   — sprint_hub_screen.dart, game_screen.dart, results_screen.dart
lib/services/               — data_service.dart, progress_service.dart
lib/models/                 — vocab_word.dart, question.dart, score_entry.dart
assets/data.json
```

## Data model notes
- Every question has: `id`, `type`, `subject`, `level`, `question`, `options`, `correct_index`, `explanation` (always Hebrew).
- `analogy` questions: options are word **pairs** (e.g. `"גדול : קטן"`), rendered as `A : B :: ? : ?`.
- `reading_comprehension` questions have an extra `passage` field.
- Vocab words: `id`, `word`, `definition`, `example`, `level`, `category`.

## What NOT to do
- Do not add Firebase, Supabase, or any network calls.
- Do not add authentication.
- Do not add ads or in-app purchases.
- Do not flip layout direction to RTL globally — Hebrew renders fine in LTR.
- Do not skip the `correct_index` — it is always 0-based into the `options` array.
- Do not use `hive_generator` for models that don't need persistence (only `ScoreEntry` and progress maps use Hive TypeAdapters).

## Running the app
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates .g.dart
flutter run
```

## Verification checklist (after changes)
1. Vocabulary tab: flip a card → swipe right (Mastered) → restart → card still Mastered.
2. Practice tab: Hebrew Verbal → answer a question → explanation shows in Hebrew.
3. Math Sprint: complete 20 questions → Results screen → score saved to leaderboard.
4. Home tab: progress hints update after completing vocab/practice.

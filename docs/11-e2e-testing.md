# End-to-End Testing (flutter_gherkin)

Everything in [07-testing-strategy.md](07-testing-strategy.md) tests layers
in isolation — the domain with no mocks, the application layer with mocked
ports, presentation with mocked read/write services and Cubit state
assertions. None of that proves the whole system actually works together on
a real device/simulator: real navigation, real rendering, a real app build
talking to a real (or realistically stubbed) backend. That's what
end-to-end tests are for, written in **Gherkin** and run through
**`flutter_gherkin`**, which drives the app via Flutter's own
`integration_test` package underneath.

## Why Gherkin/BDD on top of `integration_test`

`integration_test` alone is a perfectly capable widget/app-level test
runner, but scenarios end up as `testWidgets(...)` blocks read only by
engineers. Gherkin `.feature` files are living documentation: product and
QA can read (and, up to a point, write) scenarios without touching Dart,
and a shared vocabulary of step definitions keeps the same "Given I am on
the home page" phrasing usable across every feature file rather than
duplicated per test.

## Folder structure

```
integration_test/
  features/
    home.feature
    order.feature
  steps/
    navigation_steps.dart
    order_steps.dart
  hooks/
    reset_app_hook.dart
  run_test.dart              — configures and launches the gherkin test suite
```

Naming here intentionally follows the Cucumber/Gherkin ecosystem's own
conventions (`lowercase.feature`, `snake_case_steps.dart`) rather than the
project's suffix table from
[06-vertical-slicing.md](06-vertical-slicing.md#file-naming-convention) —
these files are read by `flutter_gherkin`'s own tooling and by
non-engineers reading `.feature` files as living documentation; matching
the ecosystem's expectations matters more here than internal consistency
with the app's own source file naming.

## Writing scenarios

Gherkin scenarios describe user-facing behavior, not implementation:

```gherkin
Feature: Home page
  Scenario: Viewing recent orders
    Given I am on the home page
    Then I should see 5 order previews
    And the first order should be for "Ada Lovelace"
```

Step definitions are small, generic, and reused across scenarios/features —
avoid writing one narrowly-scoped step per scenario. A handful of
navigation and assertion steps typically covers most of an app:

```dart
// integration_test/steps/navigation_steps.dart
StepDefinitionGeneric iAmOnTheHomePage() {
  return given<FlutterWorld>('I am on the home page', (context) async {
    await context.world.appDriver.waitForText('Home');
  });
}

StepDefinitionGeneric iShouldSeeNOrderPreviews() {
  return then1<int, FlutterWorld>(
    RegExp(r'I should see {int} order previews'),
    (count, context) async {
      final tiles = context.world.appDriver.findByType('OrderPreviewTile');
      expect(tiles, findsNWidgets(count));
    },
  );
}
```

If a Gherkin line doesn't match any step definition, the run fails loudly
with an "undefined step" error rather than silently passing — there's no
way to accidentally write an untested scenario step.

## Hooks: resetting state between scenarios

A hook resets app/backend state between scenarios so they can't leak into
each other (no shared local storage, no leftover data from a previous
scenario's writes):

```dart
// integration_test/hooks/reset_app_hook.dart
class ResetAppHook extends Hook {
  @override
  Future<void> onBeforeScenario(TestConfiguration config, String scenario, Iterable<Tag> tags) async {
    await getIt<AppStateResetter>().reset();
  }
}
```

## Running against a real build, not just the debug widget tree

The point of E2E is testing what actually ships. `run_test.dart` configures
the suite and is invoked through `flutter test integration_test/run_test.dart`
(or `flutter drive`, for a real device/simulator run rather than the
headless test harness):

```dart
// integration_test/run_test.dart
Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [Glob('integration_test/features/**.feature')]
    ..reporters = [ProgressReporter(), TestRunSummaryReporter()]
    ..stepDefinitions = [iAmOnTheHomePage(), iShouldSeeNOrderPreviews(), ...orderSteps]
    ..hooks = [ResetAppHook()]
    ..customStepParameterDefinitions = []
    ..targetAppPath = 'test_driver/app.dart'
    ..exitAfterTestRun = true;

  return GherkinIntegrationTestRunner.create(config).run();
}
```

Point `targetAppPath` at an entry point that boots the real app (real
composition root, real `get_it` wiring) against either the real `backend`
or a disposable test instance of it — not a stripped-down test harness that
skips composition-root wiring, since that's exactly the wiring E2E is
meant to catch regressions in.

## Where this fits in the testing strategy

E2E is slow relative to unit/widget tests (a real app build, a real
device/simulator boot) — it does NOT belong in the `pre-push` hook from
[09-git-workflow.md](09-git-workflow.md), which stays fast on purpose. Run
it on demand locally and as its own step in CI, separate from the fast
suite that gates every push.

This is the starting point for wiring up `flutter_gherkin` in this
monorepo, not a verified recipe against a specific package version — check
the exact API surface (`given`/`then` signatures, `FlutterTestConfiguration`
fields) against the `flutter_gherkin` version actually pinned in
`frontend/pubspec.yaml` when setting this up for real, since BDD-runner
packages tend to shift their configuration API across major versions.

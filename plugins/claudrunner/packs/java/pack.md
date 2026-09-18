# Pack: java

## Detection

`pom.xml` for Maven, `build.gradle` or `build.gradle.kts` for Gradle.

## Commands

| Purpose | Default (Maven) | Default (Gradle) |
|---|---|---|
| test (all) | `mvn test` | `./gradlew test` |
| test (filtered) | `mvn test -Dtest={filter}` | `./gradlew test --tests {filter}` |
| lint | `mvn verify -DskipTests` | `./gradlew check -x test` |
| format | *project-specific* | *project-specific* |
| build | `mvn package -DskipTests` | `./gradlew build -x test` |

Always use the wrapper script when the project ships one.

## Characteristic failure modes

- Lazy relations loaded outside their session, or loaded one row at a time inside a loop.
- Transaction boundaries that do not cover the whole unit of work.
- Mutable state on a singleton bean shared across requests.
- A thread pool sized for development and starved in production.

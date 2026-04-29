# SwiftDataMigrate

A scaffolding tool for SwiftData schema versions and migrations.

## What it does

Each invocation:

1. **Creates `SchemaV{N+1}.swift`** by copying `SchemaV{N}.swift` and rewriting the enum name and `versionIdentifier`. You then edit it to reflect whatever changed in this version.
2. **Creates `MigrateV{N}toV{N+1}.swift`** containing the migration stage. Lightweight by default. Pass `--custom` to get `willMigrate` / `didMigrate` stubs instead.
3. **Creates `MigrateV{N}toV{N+1}Tests.swift`** with a `@Suite` and an empty extension for fixture factories.
4. **Regenerates `SwiftDataMigrationPlan.swift`** from scratch based on the schemas now present in the repo. Always overwrites.
5. **Bumps typealiases** across the repo, rewriting `typealias X = SchemaV{N}.X` to point at `SchemaV{N+1}.X`. Only lines prefixed with `typealias` are touched.

## Usage

From anywhere in the Wallet repo:

```bash
just migrate              # lightweight migration (default)
just migrate --custom     # custom migration with willMigrate/didMigrate stubs
just migrate --lightweight # explicit lightweight, same as default
```

The `just` recipe forwards to `swift run swiftdata-migrate new`. After a successful run, `xcodegen` runs automatically to refresh the Xcode project with the new files.

## Choosing lightweight vs. custom

**Lightweight** is correct when the schema diff is something SwiftData can resolve automatically:

- Adding a new optional property
- Adding a property with a default value
- Removing a property (data in that column is dropped)
- Adding a new `@Model` type
- Adding an optional relationship
- Renaming a property via `@Attribute(originalName: "old")`

**Custom** is required when data needs to be reshaped:

- Type changes (`Int` → `Double`)
- Splitting one property into multiple (`fullName` → `firstName` + `lastName`)
- Extracting an entity from a freeform field (`projectName: String` → `Project` relationship)
- Adding a non-optional property that needs a computed initial value
- Any rename without `@Attribute(originalName:)`

When in doubt, default to lightweight and switch to custom manually later if needed.

## After running the tool

The script gets you to a compilable starting point, but each generated file has work left:

1. **Edit `SchemaV{N+1}.swift`** to reflect the actual schema changes.
2. **For custom migrations**, fill in the `willMigrate` and `didMigrate` closures in `MigrateV{N}toV{N+1}.swift`.
3. **Write tests** Resolve the TODOs in `MigrateV{N}toV{N+1}Tests.swift`.

## Typealiases

Typealiases can live anywhere in the project as the bumper finds them by line content (`typealias` prefix).
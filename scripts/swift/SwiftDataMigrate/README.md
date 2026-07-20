# SwiftDataMigrate

A scaffolding tool for SwiftData schema versions and migrations.

## What it does

Each invocation:

1. **Creates `SchemaV{N+1}.swift`** in `Packages/User/Sources/User/Schema` by copying `SchemaV{N}.swift` and rewriting the enum name and `versionIdentifier`. You then edit it to reflect whatever changed in this version.
2. **Creates `MigrateV{N}toV{N+1}.swift`** in `Packages/User/Sources/User/Migration` containing the migration stage. Lightweight by default. Pass `--custom` to get `willMigrate` / `didMigrate` stubs instead.
3. **Creates `MigrateV{N}toV{N+1}Tests.swift`** in `Packages/User/Tests/UserTests` with a `@Suite` and an empty extension for fixture factories.
4. **Regenerates `SwiftDataMigrationPlan.swift`** from scratch based on the schemas now present in the package. Always overwrites.
5. **Bumps `CurrentSchema.swift`**, rewriting every `SchemaV{N}.` reference to `SchemaV{N+1}.`. Since the mapping extensions target the `CurrentSchema` aliases, they retarget to the new version automatically.

## Usage

From anywhere in the Wallet repo:

```bash
just migrate              # lightweight migration (default)
just migrate --custom     # custom migration with willMigrate/didMigrate stubs
just migrate --lightweight # explicit lightweight, same as default
```

The `just` recipe forwards to `swift run swiftdata-migrate new`. All generated files live inside the `User` package, where SPM discovers sources automatically — no project regeneration needed.

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

The bumper only touches `Packages/User/Sources/User/CurrentSchema.swift`. Keep all version-pinned typealiases (`User`, the `CurrentSchema` members) in that file so a version bump retargets everything in one place.

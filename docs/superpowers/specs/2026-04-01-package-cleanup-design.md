# Package Cleanup Design

**Date:** 2026-04-01  
**Goal:** Minimize `package.json` by removing unused dependencies and replacing minimally-used packages with native Node.js code or inline implementations.  
**Node version:** 20.x (CentOS Stream 9, via nodesource)  
**Scope:** `/Users/bbolt/mcneilco/oss/acas` and the custom modules at `~/schrodinger/livedesign/services/acas_custom_schrodinger/sources/` — both share this `package.json`.

---

## Context

Analysis was performed across both the main ACAS repo and the custom schrodinger modules. Every `require()` call was traced for all 76 dependencies. The result: 14 packages have zero usage, and 6 more are used in only 1–2 files with logic trivially replaceable by native Node.js or a few lines of inline code.

---

## Phase 1 — Remove Unused Packages

These packages have **zero `require()` calls** anywhere in either codebase. Remove them from `package.json` only — no code changes.

| Package | Why it's safe to remove |
|---|---|
| `archiver` | Not used; `jszip` handles all ZIP creation |
| `bluebird` | Not used; native Promise is used throughout |
| `each` | Not used; `_.each()` from underscore is used instead |
| `json2csv` | Not used |
| `lodash` | Not used; `underscore` is the utility library in this codebase |
| `marked` | Not used |
| `puppeteer` | Not used |
| `properties` | Not used; `properties-parser` is the active properties file package |
| `semver` | Not used |
| `style-loader` | Webpack loader; this project uses Gulp, not Webpack |
| `url-loader` | Webpack loader; this project uses Gulp, not Webpack |
| `yamljs` | Not used |
| `jasmine-jquery` | Not used; Mocha/Chai is the test stack |
| `backbone-validation` | Not used |

**Count:** 14 packages removed, 0 files changed.

---

## Phase 2 — Drop-in Native Replacements

These packages are replaced by built-in Node.js behavior. The API is identical so no logic changes are needed.

### 2a. `assert` (npm shim) — remove from package.json only

In Node.js, core module names take priority over npm packages with the same name. `require('assert')` already resolves to the built-in module, not the npm package. The shim is silently ignored at runtime.

**Action:** Remove `assert` from `package.json`. No code changes in any of the 17 spec files.

### 2b. `promise` — delete one `require` line

Used in one file: `modules/Components/src/server/routes/RealtimeDeviceConnectionSockets.coffee`

Usage is limited to `new Promise((resolve, reject) => ...)`, `.then()`, and `.catch()` — all standard Promise API. Native `Promise` is identical for this usage.

**Action:** Remove `promise` from `package.json`. Delete line 4 (`Promise = require 'promise'`) from `RealtimeDeviceConnectionSockets.coffee`.

### 2c. `ncp` → `fs.cp()`

Used in one file: `modules/BuildUtilities/src/server/CopyModuleTemplate.coffee`

`ncp(src, dest, cb)` maps directly to `fs.cp(src, dest, {recursive: true}, cb)`. Error callback signature is identical. `fs.cp` is stable in Node 16+.

**Action:** Remove `ncp` from `package.json`. Replace `require('ncp').ncp` with `require('fs').cp` and add `{recursive: true}` as the third argument in `CopyModuleTemplate.coffee`.

---

## Phase 3 — Inline Replacements

These packages are used in 1–2 files. Their functionality is replaced by writing a small amount of code directly in the consuming file.

### 3a. `flat` — inline a flatten function

Used in: `modules/BuildUtilities/src/server/PrepareConfigFiles.coffee`  
Usage: `flat.flatten(conf)` — flattens a nested object into dot-notation keys.

**Replacement:** Write a `flatten(obj, prefix = '')` recursive function (~10 lines) at the top of `PrepareConfigFiles.coffee`:

```coffeescript
flatten = (obj, prefix = '') ->
  result = {}
  for key, val of obj
    fullKey = if prefix then "#{prefix}.#{key}" else key
    if val? and typeof val is 'object' and not Array.isArray(val)
      Object.assign(result, flatten(val, fullKey))
    else
      result[fullKey] = val
  result
```

### 3b. `underscore-deep-extend` — inline a deep merge function

Used in: `modules/BuildUtilities/src/server/PrepareConfigFiles.coffee`  
Usage: Adds `_.deepExtend` to underscore for merging nested configuration objects.

**Replacement:** Write a `deepExtend(target, source)` recursive function (~15 lines) in `PrepareConfigFiles.coffee` and call it directly instead of via `_`:

```coffeescript
deepExtend = (target, source) ->
  for key, val of source
    if val? and typeof val is 'object' and not Array.isArray(val)
      target[key] ?= {}
      deepExtend(target[key], val)
    else
      target[key] = val
  target
```

### 3c. `temporary` — use `fs.mkdtemp` + `fs.openSync`

Used in two files:
- `modules/ServerAPI/src/server/routes/ServerUtilityFunctions.coffee`
- `modules/ServerAPI/src/server/routes/CreateLiveDesignLiveReportForACAS.coffee`

Usage: `new Tempfile` creates a temp file with a unique path; the `.path` property is then used to write/read the file.

**Replacement:** Write a small `makeTempFile()` helper in each file (or extract to a shared utility):

```coffeescript
os = require 'os'
path = require 'path'
fs = require 'fs'

makeTempFile = ->
  dir = fs.mkdtempSync(path.join(os.tmpdir(), 'acas-'))
  filePath = path.join(dir, 'tmp')
  fs.writeFileSync(filePath, '')
  { path: filePath }
```

This returns an object with a `.path` property, matching the `temporary` API surface used in both files.

### 3d. `async` — rewrite with native async/await

Used in: `modules/BuildUtilities/src/server/PrepareModuleConfJSON.coffee`  
Usage: One async control flow operation.

**Action:** Rewrite the usage as native `async`/`await`. The exact rewrite depends on which `async` method is used (needs confirmation during implementation — likely `async.waterfall` or `async.each`).

### 3e. `csv-stringify` — inline the one call

Used in: `modules/ServerAPI/src/server/routes/ProtocolServiceRoutes.coffee` (line 790)  
Usage: `csv.stringify(data, {header: false})` — converts a 2D array to a CSV string with no header row.

**Replacement:** Replace the `require` and the one call site with:

```coffeescript
csvStringify = (rows) -> rows.map((row) -> row.join(',')).join('\n')
```

Note: This assumes cell values do not contain commas or newlines. If that assumption is wrong, keep `csv-stringify`. Confirm during implementation by checking what `data` contains at that call site.

---

## What We're Keeping

These packages were evaluated and intentionally kept:

| Package | Reason |
|---|---|
| `csv-parse` | Used in 3 files across main repo + custom modules; streaming API is non-trivial to replace |
| `properties-parser` | Java `.properties` format has escaping and unicode rules; writing a correct parser is non-trivial |
| `forever-monitor` | Used in `app_template.coffee` for process management with restart logic |
| `underscore` | Used in 40+ files in main repo and 3+ files in custom modules; migration is a separate effort |
| All Express middleware | Core web framework stack; actively maintained and essential |
| `passport` + strategies | Authentication; security-critical, keep dedicated packages |
| `socket.io` + `passport.socketio` | Real-time communication; keep |
| `winston` + `winston-mongodb` | Logging infrastructure; keep |
| `mongojs` | MongoDB logging; keep |
| `cron` | Job scheduling; keep |
| `mocha` + `mochawesome` | Test runner used both in CI and via HTTP endpoint in SystemTestRoutes |
| `jszip` | Used in 2 files for ZIP archive creation; keep |
| `pug` | Template engine; keep |
| `bootstrap`, `jquery`, `backbone` | Client-side assets bundled via Gulp; keep |
| `less` | CSS compilation via Gulp; keep |
| `glob` | Used in 5 build utility files; native glob requires Node 22+ |
| `multer` | File upload middleware; keep |
| `connect-pg-simple` | PostgreSQL session store; keep |

---

## Expected Outcome

| Metric | Before | After |
|---|---|---|
| `dependencies` count | 58 | ~37 |
| Packages removed entirely | — | 14 (Phase 1) + 3 (Phase 2) + 5 (Phase 3) = 22 |
| Files changed | — | ~7 source files (no test file changes needed) |
| Behavior change | — | None |

---

## Risk & Rollback

- All changes are on a feature branch; rollback is `git revert` or branch deletion.
- Phase 1 has zero risk — removing packages with no `require()` calls.
- Phase 2 replacements are verified drop-in at the API level.
- Phase 3 replacements should be followed by running `npm test` to confirm no regressions.
- The `csv-stringify` replacement carries the only conditional risk (comma/newline in cell values); verify the data shape at that call site before inlining.

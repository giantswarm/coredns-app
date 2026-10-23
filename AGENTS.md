# AGENTS.md

## Upgrading the CoreDNS image

Follow every step for each CoreDNS version bump, including patch releases.

### 1. Bump the version

- `helm/coredns-app/values.yaml`: `image.tag`.
- `helm/coredns-app/Chart.yaml`: `appVersion`.
- `helm/coredns-app/README.md`: the AppVersion badge and the `image` / `image.tag` default rows.
- `CHANGELOG.md`: an entry under `[Unreleased]` linking the upstream release, with `(#<PR>)`.
- PR title in conventional commit format (e.g. `chore: update CoreDNS image to 1.15.0`); the `semantic-pull-request` check enforces it.

### 2. Diff the upstream plugin docs

For every plugin the Corefile renders, diff the upstream README between the old and new tag:

```sh
OLD=v1.14.7 NEW=v1.15.0
for p in forward cache kubernetes log loadbalance autopath errors health ready metrics reload template; do
  echo "== $p"
  diff <(curl -sSfL https://raw.githubusercontent.com/coredns/coredns/$OLD/plugin/$p/README.md) \
       <(curl -sSfL https://raw.githubusercontent.com/coredns/coredns/$NEW/plugin/$p/README.md)
done
```

Compare against the tag, not `master`. For each change:

- New option in a structured block (`forward`, `cache`, `kubernetes`, `log`, `loadbalance`): wire it up (step 3) or state in the PR why it is skipped.
- Removed or renamed option: update the helper and values, and call it out in the changelog.
- Behaviour change with no option (e.g. new defaults, stricter parsing): note it in the changelog if users can notice it.
- Metric renamed or label removed (`metrics` and each plugin's Metrics section): note it in the changelog; dashboards and alerts live outside this repo.

Also check the release notes for deprecated plugins and Corefile syntax changes.

### 3. Wire up a new option

- `helm/coredns-app/values.yaml`: add the key under the zone block with a `# @schema` type annotation and a `# --` helm-docs comment. Leave it unset (`null`) so the CoreDNS default applies.
- `helm/coredns-app/templates/_helpers.tpl`: append one line to the matching `coredns.*Block` helper. For integer options, test with `if not (kindIs "invalid" $f.key)` rather than `with`, otherwise `0` is silently dropped.
- `helm/coredns-app/values.schema.json`: regenerate with `helm schema --use-helm-docs` (run in `helm/coredns-app`, losisin `helm-values-schema-json` plugin) and copy over only the hunks for your change; the committed schema has small unrelated drift.
- `helm/coredns-app/README.md`: if `make helm-docs` rewrites unrelated rows, revert it and edit the affected rows by hand.

`coredns.additionalZones[]` reuses the public and cluster block schemas through `$ref`s declared in the `# @schema allOf` annotation on `additionalZones`. A new key inside an existing block is covered automatically; a new zone-level block needs a new `$ref` there.

### 4. Validate

All of these must pass before the PR leaves draft:

- Render: `helm template t helm/coredns-app --set-json '<values using the new/changed options>'` for the public zone and an `additionalZones` entry, plus a default render.
- Schema rejects wrong types: render once with an invalid value for each new key.
- CI schema check: validate `values.yaml` and every `helm/coredns-app/ci/*.yaml` merged into it with `yajsv` (as `giantswarm/github-workflows/.github/workflows/chart-values.yaml` does).
- Lint: `helm lint helm/coredns-app`.
- Corefile parses on the new image: take the rendered Corefile (or the changed block, with `.:1053` as the server address) and run
  `docker run --rm -v "$PWD/cf:/cf:ro" gsoci.azurecr.io/giantswarm/coredns:<NEW> -conf /cf/Corefile`. It must print `CoreDNS-<NEW>`, not a `plugin/...` error.
- Run E2E by commenting `/run app-test-suites` on the PR, and tick the E2E checkbox once it passes.

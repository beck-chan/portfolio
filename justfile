# Local deploys and releases. Requires bash, quarto, npx, and gh.
# Rehearse without publishing: just staging dry-run
#   (same for production, refresh, deploy, release)

set dotenv-load := true
set windows-shell := ["bash", "-c"]

staging_url := "https://beckchan-staging.netlify.app/"
production_url := "https://beck-chan.github.io/"
pages_repo := "beck-chan/beck-chan.github.io"
pages_repo_url := "https://github.com/beck-chan/beck-chan.github.io"
source_repo := "beck-chan/portfolio"

# List available recipes
default:
    @just --list

# Deploy stripped theme to Netlify FOLIO, then production profile to GitHub Pages
production *args:
    #!/usr/bin/env bash
    set -euo pipefail
    dry=0
    if [ "${DRY_RUN:-}" = "1" ] || [ "${DRY_RUN:-}" = "true" ]; then dry=1; fi
    set -- {{args}}
    for arg in "$@"; do
      case "$arg" in
        --dry-run|dry-run) dry=1 ;;
        *) echo "Unknown argument: $arg" >&2; echo "Usage: just production [dry-run]" >&2; exit 1 ;;
      esac
    done
    just _require NETLIFY_PAT FOLIO_PROJECT
    message="portfolio-local-$(date -u +%Y%m%d-%H%M%S)"
    if [ "$dry" -eq 1 ]; then
      echo "Would: quarto render --profile stripped"
      echo "Would: netlify deploy --prod --dir=_output --site=${FOLIO_PROJECT} --message=${message}"
      echo "Would: quarto render --profile production"
      echo "Would: clone {{pages_repo}}, replace with _output, commit, push origin main"
      echo "{{pages_repo_url}}"
      exit 0
    fi
    just _render stripped
    just _netlify _output "$FOLIO_PROJECT" "$message"
    just _render production
    just _pages_sync
    echo "{{pages_repo_url}}"

# Spellcheck, render, and deploy preview to Netlify staging
staging *args:
    #!/usr/bin/env bash
    set -euo pipefail
    dry=0
    if [ "${DRY_RUN:-}" = "1" ] || [ "${DRY_RUN:-}" = "true" ]; then dry=1; fi
    set -- {{args}}
    for arg in "$@"; do
      case "$arg" in
        --dry-run|dry-run) dry=1 ;;
        *) echo "Unknown argument: $arg" >&2; echo "Usage: just staging [dry-run]" >&2; exit 1 ;;
      esac
    done
    just _require NETLIFY_PAT NETLIFY_PROJECT
    message="portfolio-local-$(date -u +%Y%m%d-%H%M%S)"
    if [ "$dry" -eq 1 ]; then
      echo "Would: npx cspell \"**/*.qmd\" --exclude \"_output\" --exclude \".quarto\" --exclude \"poetry/random/*\""
      echo "Would: quarto render"
      echo "Would: netlify deploy --prod --dir=_output --site=${NETLIFY_PROJECT} --message=${message}"
      echo "{{staging_url}}"
      exit 0
    fi
    npx cspell "**/*.qmd" --exclude "_output" --exclude ".quarto" --exclude "poetry/random/*"
    just _render
    just _netlify _output "$NETLIFY_PROJECT" "$message"
    echo "{{staging_url}}"

# Replace staging with a redirect to production
refresh *args:
    #!/usr/bin/env bash
    set -euo pipefail
    dry=0
    if [ "${DRY_RUN:-}" = "1" ] || [ "${DRY_RUN:-}" = "true" ]; then dry=1; fi
    set -- {{args}}
    for arg in "$@"; do
      case "$arg" in
        --dry-run|dry-run) dry=1 ;;
        *) echo "Unknown argument: $arg" >&2; echo "Usage: just refresh [dry-run]" >&2; exit 1 ;;
      esac
    done
    just _require NETLIFY_PAT NETLIFY_PROJECT
    message="portfolio-local-$(date -u +%Y%m%d-%H%M%S)-closed"
    if [ "$dry" -eq 1 ]; then
      echo "Would: write _redirects (302 {{production_url}}) and index.html"
      echo "Would: netlify deploy --prod --site=${NETLIFY_PROJECT} --message=${message}"
      echo "{{staging_url}}"
      exit 0
    fi
    dir="$(mktemp -d)"
    printf '%s\n' '/*    {{production_url}}    302' > "$dir/_redirects"
    printf '%s\n' \
      '<!doctype html>' \
      '<meta http-equiv="refresh" content="0;url={{production_url}}">' \
      '<title>Redirecting…</title>' \
      '<p>No active preview. <a href="{{production_url}}">Go to portfolio</a>.</p>' \
      > "$dir/index.html"
    just _netlify "$dir" "$NETLIFY_PROJECT" "$message"
    echo "{{staging_url}}"

# Rebuild GitHub Pages from beck-chan.github.io main
deploy *args:
    #!/usr/bin/env bash
    set -euo pipefail
    dry=0
    if [ "${DRY_RUN:-}" = "1" ] || [ "${DRY_RUN:-}" = "true" ]; then dry=1; fi
    set -- {{args}}
    for arg in "$@"; do
      case "$arg" in
        --dry-run|dry-run) dry=1 ;;
        *) echo "Unknown argument: $arg" >&2; echo "Usage: just deploy [dry-run]" >&2; exit 1 ;;
      esac
    done
    command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }
    build_type="$(gh api repos/{{pages_repo}}/pages --jq '.build_type // "legacy"')"
    html_url="$(gh api repos/{{pages_repo}}/pages --jq '.html_url')"
    branch="$(gh api repos/{{pages_repo}}/pages --jq '.source.branch // empty')"
    echo "Pages: ${html_url} (branch=${branch:-unknown}, build_type=${build_type})"
    if [ "$build_type" = "workflow" ]; then
      echo "GitHub Pages build_type is workflow (Actions). POST /pages/builds will not publish this site." >&2
      echo "Use Settings → Pages → Source: Deploy from a branch (legacy) for this command." >&2
      exit 1
    fi
    if [ "$dry" -eq 1 ]; then
      echo "Would: POST /repos/{{pages_repo}}/pages/builds"
      echo "{{production_url}}"
      exit 0
    fi
    gh api -X POST "repos/{{pages_repo}}/pages/builds" >/dev/null
    echo "Latest build:"
    gh api "repos/{{pages_repo}}/pages/builds/latest" --jq '{status, commit, created_at, updated_at}'
    echo "{{production_url}}"

# Create a tagged GitHub release (major / minor / patch)
release *args:
    #!/usr/bin/env bash
    set -euo pipefail
    dry=0
    if [ "${DRY_RUN:-}" = "1" ] || [ "${DRY_RUN:-}" = "true" ]; then dry=1; fi
    set -- {{args}}
    for arg in "$@"; do
      case "$arg" in
        --dry-run|dry-run) dry=1 ;;
        *) echo "Unknown argument: $arg" >&2; echo "Usage: just release [dry-run]" >&2; exit 1 ;;
      esac
    done
    command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }

    latest_major=0
    latest_minor=0
    latest_patch=0
    while IFS= read -r tag; do
      [ -z "$tag" ] && continue
      if [[ "$tag" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        patch="${BASH_REMATCH[3]}"
        if (( major > latest_major \
          || (major == latest_major && minor > latest_minor) \
          || (major == latest_major && minor == latest_minor && patch > latest_patch) )); then
          latest_major=$major
          latest_minor=$minor
          latest_patch=$patch
        fi
      fi
    done < <(gh api --paginate "repos/{{source_repo}}/tags" --jq '.[].name')

    major_tag="v$((latest_major + 1)).0.0"
    minor_tag="v${latest_major}.$((latest_minor + 1)).0"
    patch_tag="v${latest_major}.${latest_minor}.$((latest_patch + 1))"
    echo "Latest: v${latest_major}.${latest_minor}.${latest_patch}"
    echo "1. major  ${major_tag}  https://github.com/{{source_repo}}/releases/tag/${major_tag}"
    echo "2. minor  ${minor_tag}  https://github.com/{{source_repo}}/releases/tag/${minor_tag}"
    echo "3. patch  ${patch_tag}  https://github.com/{{source_repo}}/releases/tag/${patch_tag}"

    if [ "$dry" -eq 1 ]; then
      echo "Would: gh release create <chosen tag> --title \"Release <tag>\" --target $(git rev-parse HEAD)"
      exit 0
    fi

    read -r -p "Select bump (1/2/3): " choice
    case "$choice" in
      1) new_tag="$major_tag" ;;
      2) new_tag="$minor_tag" ;;
      3) new_tag="$patch_tag" ;;
      *) echo "Invalid choice: ${choice}" >&2; exit 1 ;;
    esac

    if gh api --paginate "repos/{{source_repo}}/tags" --jq '.[].name' | grep -Fxq "$new_tag"; then
      echo "Tag ${new_tag} already exists." >&2
      exit 1
    fi

    echo "Enter release notes. Finish with a line containing only END."
    notes=""
    while IFS= read -r line || [ -n "$line" ]; do
      [[ "$line" == "END" ]] && break
      notes+="${line}"$'\n'
    done
    notes="$(printf '%s' "$notes" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if [ -z "$notes" ]; then
      notes="No public-facing release notes."
    fi

    body="${notes}

> **Browse the updated portfolio at: [{{production_url}}]({{production_url}})**

[How are releases generated?]({{production_url}}samples/content-engineering/personal/portfolio/deployment.html#release-notes)"

    echo
    echo "----"
    echo "Release ${new_tag}"
    printf '%s\n' "$body"
    echo "----"
    read -r -p "Create release? [y/N] " confirm
    case "$confirm" in
      y|Y) ;;
      *) echo "Aborted."; exit 1 ;;
    esac

    printf '%s\n' "$body" | gh release create "$new_tag" \
      --title "Release ${new_tag}" \
      --notes-file - \
      --target "$(git rev-parse HEAD)"
    echo "https://github.com/{{source_repo}}/releases/tag/${new_tag}"

[private]
_require +names:
    #!/usr/bin/env bash
    set -euo pipefail
    for name in {{names}}; do
      if [ -z "${!name:-}" ]; then
        echo "Missing required environment variable: $name" >&2
        echo "Set it in .env." >&2
        exit 1
      fi
    done

[private]
_render profile="":
    #!/usr/bin/env bash
    set -euo pipefail
    set -o pipefail
    profile="{{profile}}"
    if [ -n "$profile" ]; then
      quarto render --profile "$profile" 2>&1 | tee render_errors.log || {
        echo "Quarto render failed immediately"
        cat render_errors.log
        exit 1
      }
    else
      quarto render 2>&1 | tee render_errors.log || {
        echo "Quarto render failed immediately"
        cat render_errors.log
        exit 1
      }
    fi

[private]
_netlify dir site message:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="{{dir}}"
    site="{{site}}"
    message="{{message}}"
    if [ ! -d "$dir" ]; then
      echo "Deploy directory ${dir}/ is missing"
      exit 1
    fi
    npx --yes netlify-cli deploy \
      --prod \
      --dir="$dir" \
      --message="$message" \
      --auth="$NETLIFY_PAT" \
      --site="$site"

[private]
_pages_sync:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d _output ]; then
      echo "Quarto output directory _output/ is missing"
      exit 1
    fi
    command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }
    src="$(pwd)"
    dest="$(mktemp -d)"
    gh repo clone {{pages_repo}} "$dest" -- --depth 1 --branch main
    shopt -s dotglob nullglob
    for path in "$dest"/* "$dest"/.[!.]*; do
      [ -e "$path" ] || continue
      [ "$(basename "$path")" = ".git" ] && continue
      rm -rf "$path"
    done
    cp -a "$src/_output/." "$dest/"
    cd "$dest"
    git add -A
    if git diff --staged --quiet; then
      echo "No changes to deploy"
    else
      git commit -m "Automated file sync from portfolio"
      git push origin main
    fi

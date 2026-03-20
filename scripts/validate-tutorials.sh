#!/usr/bin/env bash
# =============================================================================
# validate-tutorials.sh
#
# Validator script for kubelabs tutorials.
# Checks that each tutorial directory meets the repository's quality standards:
#   1. Has a README.md file
#   2. README.md is non-empty (≥ 100 bytes)
#   3. README.md contains at least one Markdown heading
#   4. All YAML files in the directory are syntactically valid
#   5. Markdown files do not contain common broken-link patterns
#
# Usage:
#   ./scripts/validate-tutorials.sh [DIRECTORY...]
#
#   If no directories are given, all *101 and *201 tutorial directories
#   in the repository root are validated.
#
# Exit codes:
#   0  — All validations passed
#   1  — One or more validations failed
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---- Colour helpers ----------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

pass()  { echo -e "  ${GREEN}✔${NC} $*"; }
fail()  { echo -e "  ${RED}✗${NC} $*"; }
info()  { echo -e "  ${BLUE}ℹ${NC} $*"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $*"; }

# ---- Dependency checks -------------------------------------------------------
YAML_LINT=""
if command -v yamllint &>/dev/null; then
    YAML_LINT="yamllint"
elif command -v python3 &>/dev/null && python3 -c "import yaml" 2>/dev/null; then
    YAML_LINT="python3-yaml"
fi

# ---- Tutorial directory detection -------------------------------------------
get_tutorial_dirs() {
    # Return directories whose names end with digits (101, 201, etc.)
    # or are well-known tutorial directories.
    find "$REPO_ROOT" -maxdepth 1 -type d \
        \( -name '*101' -o -name '*201' -o -name 'cka' -o -name 'intermediate' \) \
        | sort
}

# ---- Individual checks -------------------------------------------------------

check_readme_exists() {
    local dir="$1"
    if [[ -f "$dir/README.md" ]]; then
        pass "README.md exists"
        return 0
    else
        fail "README.md is missing"
        return 1
    fi
}

check_readme_not_empty() {
    local dir="$1"
    local readme="$dir/README.md"
    local min_bytes=100

    if [[ ! -f "$readme" ]]; then
        return 1
    fi

    local size
    size=$(wc -c < "$readme")
    if [[ "$size" -ge "$min_bytes" ]]; then
        pass "README.md has content (${size} bytes)"
        return 0
    else
        fail "README.md is too short (${size} bytes, minimum ${min_bytes})"
        return 1
    fi
}

check_readme_has_heading() {
    local dir="$1"
    local readme="$dir/README.md"

    if [[ ! -f "$readme" ]]; then
        return 1
    fi

    if grep -qE '^#{1,6} .+' "$readme"; then
        pass "README.md contains a Markdown heading"
        return 0
    else
        fail "README.md has no Markdown heading (lines starting with #)"
        return 1
    fi
}

check_yaml_syntax() {
    local dir="$1"
    local yaml_files
    mapfile -t yaml_files < <(find "$dir" -maxdepth 2 -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)

    if [[ "${#yaml_files[@]}" -eq 0 ]]; then
        info "No YAML files found (skipping YAML syntax check)"
        return 0
    fi

    local failed=0
    for f in "${yaml_files[@]}"; do
        local rel="${f#"$REPO_ROOT/"}"
        if [[ "$YAML_LINT" == "yamllint" ]]; then
            if yamllint -d relaxed "$f" &>/dev/null; then
                pass "YAML valid: $rel"
            else
                fail "YAML invalid: $rel"
                yamllint -d relaxed "$f" 2>&1 | sed 's/^/      /'
                failed=1
            fi
        elif [[ "$YAML_LINT" == "python3-yaml" ]]; then
            if python3 -c "
import yaml, sys
try:
    with open('$f') as fh:
        list(yaml.safe_load_all(fh))
except yaml.YAMLError as e:
    print(e)
    sys.exit(1)
" 2>/dev/null; then
                pass "YAML valid: $rel"
            else
                fail "YAML invalid: $rel"
                failed=1
            fi
        else
            warn "No YAML linter available; skipping syntax check for $rel"
        fi
    done

    return "$failed"
}

check_no_placeholder_links() {
    local dir="$1"
    local md_files
    mapfile -t md_files < <(find "$dir" -maxdepth 2 -type f -name '*.md' | sort)

    local failed=0
    for f in "${md_files[@]}"; do
        local rel="${f#"$REPO_ROOT/"}"
        # Look for obvious placeholder patterns: [text](TODO), [text](#), etc.
        if grep -qE '\]\((TODO|FIXME|#|https?://example\.com)\)' "$f" 2>/dev/null; then
            local matches
            matches=$(grep -nE '\]\((TODO|FIXME|#|https?://example\.com)\)' "$f")
            warn "Placeholder links found in $rel:"
            echo "$matches" | sed 's/^/      /'
            # This is a warning, not a hard failure
        else
            pass "No placeholder links: $rel"
        fi
    done

    return "$failed"
}

# ---- Main validation loop ---------------------------------------------------

validate_directory() {
    local dir="$1"
    local name
    name="$(basename "$dir")"
    local errors=0

    echo -e "\n${BLUE}▶ Validating: ${name}${NC}"
    echo "  Path: $dir"

    check_readme_exists       "$dir" || (( errors++ )) || true
    check_readme_not_empty    "$dir" || (( errors++ )) || true
    check_readme_has_heading  "$dir" || (( errors++ )) || true
    check_yaml_syntax         "$dir" || (( errors++ )) || true
    check_no_placeholder_links "$dir" || true   # warning only

    if [[ "$errors" -eq 0 ]]; then
        echo -e "  ${GREEN}Result: PASSED${NC}"
    else
        echo -e "  ${RED}Result: FAILED ($errors error(s))${NC}"
    fi

    return "$errors"
}

main() {
    echo "========================================"
    echo "  Kubelabs Tutorial Validator"
    echo "  Repo: $REPO_ROOT"
    echo "========================================"

    local dirs=()
    if [[ "$#" -gt 0 ]]; then
        for d in "$@"; do
            if [[ ! -d "$d" ]]; then
                echo -e "${RED}Error: Directory not found: $d${NC}" >&2
                exit 1
            fi
            dirs+=("$(cd "$d" && pwd)")
        done
    else
        mapfile -t dirs < <(get_tutorial_dirs)
    fi

    if [[ "${#dirs[@]}" -eq 0 ]]; then
        echo "No tutorial directories found."
        exit 0
    fi

    local total=0
    local passed=0
    local failed=0

    for dir in "${dirs[@]}"; do
        (( total++ )) || true
        if validate_directory "$dir"; then
            (( passed++ )) || true
        else
            (( failed++ )) || true
        fi
    done

    echo ""
    echo "========================================"
    echo "  Summary"
    echo "========================================"
    echo "  Total:  $total"
    echo -e "  ${GREEN}Passed: $passed${NC}"
    if [[ "$failed" -gt 0 ]]; then
        echo -e "  ${RED}Failed: $failed${NC}"
    else
        echo "  Failed: $failed"
    fi
    echo "========================================"

    if [[ "$failed" -gt 0 ]]; then
        exit 1
    fi
}

main "$@"

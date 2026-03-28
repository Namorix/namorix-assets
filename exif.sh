#!/bin/bash
set -euo pipefail

# Repo root = directory containing this script (run from anywhere).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

DIST="${DIST:-dist}"

# --- 1. OWNERSHIP INFORMATION ---
AUTHOR="Nguyen Danh Nam"
COPYRIGHT="Copyright (C) 2026 $AUTHOR. CC BY-NC-ND 4.0"
LICENSE="https://creativecommons.org/licenses/by-nc-nd/4.0/"
TAG_ID="Namorix-Metadata-Block"

# --- 2. CORE SYSTEM COLORS ---
DARK_BG="#1C1C1E"
LIGHT_BG="#FFFFFF"
DARK_I="#007AFF"
LIGHT_I="#005FB8"

# Masters draw satellite/outline as pure white on the dark card. Each PALETTE_* is
# Dark|Light: build maps nmx-glyph-fixed-* white → D_SAT / L_SAT on *-symbol-dark and
# *-symbol-light only (no box-* outputs). Icons without a COLORS entry use D_SAT/L_SAT
# fallback #FFFFFF / #1C1C1E (neutral on both themes).
#
# Logo: chỉ nmx-glyph-fixed-* theo PALETTE_LOGO. nmx-i và nmx-glyph-no-* giữ màu I hệ thống
# (#007AFF / #005FB8 theo theme), không gán D_SAT|L_SAT.
GLYPH_WHITE="#FFFFFF"
GLYPH_ON_LIGHT="#1C1C1E"

# --- 3. CORE PALETTES (Dark|Light) ---
# Left = D_SAT (dark-theme glyph on card), right = L_SAT (light-theme / white-bg UI).
# PALETTE_LOGO: chỉ miếng ghép (glyph-fixed); chấm + chữ I không dùng palette này.
PALETTE_LOGO="#FFFFFF|#1C1C1E"       # Logo chính
PALETTE_SECURITY="#30D158|#248A3D"   # Sentinel, Camera
PALETTE_STORAGE="#FF9F0A|#C67400"    # Files, Downloads
PALETTE_NETWORK="#64D2FF|#0071A4"    # Thread, Zigbee
PALETTE_SYSTEM="#FF453A|#D70015"     # Settings, Manager, Core
PALETTE_STATUS="#BF5AF2|#8944AB"     # Health, Logs, Addons

# --- 4. ASSIGN ICONS TO GROUPS ---
# Keys MUST match the stem after "namorix-" (namorix-settings.svg → settings, not setting).
declare -A COLORS
COLORS["logo"]=$PALETTE_LOGO
COLORS["sentinel"]=$PALETTE_SECURITY
COLORS["files"]=$PALETTE_STORAGE
COLORS["downloads"]=$PALETTE_STORAGE
COLORS["thread"]=$PALETTE_NETWORK
COLORS["settings"]=$PALETTE_SYSTEM
COLORS["addons"]=$PALETTE_SYSTEM
COLORS["logs"]=$PALETTE_STATUS
# Names not listed above use the same D_SAT/L_SAT fallback as former default (#FFFFFF|#1C1C1E).

# Remove the rounded-rect background path (fill = DARK_BG). Safe for single-line and
# multi-line <path>; do NOT use sed '/fill=.../d' — it deletes only the fill line and
# leaves a broken <path> when d= and fill= are on separate lines.
strip_svg_path_with_bg_fill() {
    perl -0777 -e '
        my $hex = shift;
        $/ = undef;
        $_ = <STDIN>;
        s/<path\b[\s\S]*?\bfill="\Q$hex\E"[\s\S]*?\/>//g;
        print;
    ' "$1"
}

# Dark-theme dist outputs: nmx-glyph-fixed-* white → D_SAT only (nmx-i / nmx-glyph-no giữ #007AFF).
# Expects env: D_SAT GLYPH_WHITE
apply_dark_variant_svg() {
    perl -0777 -e '
        use strict;
        use warnings;
        my $D_SAT = $ENV{D_SAT} // die "D_SAT missing";
        my $GW    = $ENV{GLYPH_WHITE} // die "GLYPH_WHITE missing";

        $/ = undef;
        my $svg = <STDIN>;

        $svg =~ s{
            <(path|rect)\b
            [\s\S]*?
            \bid="nmx-glyph-fixed-[^"]+"
            [\s\S]*?
            />
        }{
            my $b = $&;
            $b =~ s/\bstroke="\Q$GW\E"/stroke="$D_SAT"/g;
            $b =~ s/\bfill="\Q$GW\E"/fill="$D_SAT"/g;
            $b;
        }gex;

        print $svg;
    '
}

# Light-theme outputs: swap card / I / palette; nmx-glyph-fixed-* white → L_SAT.
# nmx-glyph-no-*: giữ xanh như nmx-i — bọc khỏi LIGHT_I rồi khôi phục DARK_I (#007AFF).
# Expects env: DARK_BG LIGHT_BG DARK_I LIGHT_I D_SAT L_SAT GLYPH_WHITE GLYPH_ON_LIGHT
apply_light_variant_svg() {
    perl -0777 -e '
        use strict;
        use warnings;
        my $DARK_BG  = $ENV{DARK_BG}  // die "DARK_BG missing";
        my $LIGHT_BG = $ENV{LIGHT_BG} // die "LIGHT_BG missing";
        my $DARK_I   = $ENV{DARK_I}   // die "DARK_I missing";
        my $LIGHT_I  = $ENV{LIGHT_I}  // die "LIGHT_I missing";
        my $D_SAT    = $ENV{D_SAT}    // die "D_SAT missing";
        my $L_SAT    = $ENV{L_SAT}    // die "L_SAT missing";
        my $GW       = $ENV{GLYPH_WHITE}    // die "GLYPH_WHITE missing";
        my $GL       = $ENV{GLYPH_ON_LIGHT} // die "GLYPH_ON_LIGHT missing";

        $/ = undef;
        my $svg = <STDIN>;

        $svg =~ s{
            <(path|rect)\b
            [\s\S]*?
            \bid="nmx-glyph-no-[^"]+"
            [\s\S]*?
            />
        }{
            my $b = $&;
            $b =~ s/\bfill="\Q$DARK_I\E"/fill="__NMX_GLYPH_NO_FILL__"/g;
            $b =~ s/\bstroke="\Q$DARK_I\E"/stroke="__NMX_GLYPH_NO_STROKE__"/g;
            $b;
        }gex;

        # Masters use #FFFFFF for satellite; map to category L_SAT (pair with D_SAT in PALETTE_*).
        $svg =~ s{
            <(path|rect)\b
            [\s\S]*?
            \bid="nmx-glyph-fixed-[^"]+"
            [\s\S]*?
            />
        }{
            my $b = $&;
            $b =~ s/\bstroke="\Q$GW\E"/stroke="$L_SAT"/g;
            $b =~ s/\bfill="\Q$GW\E"/fill="$L_SAT"/g;
            $b;
        }gex;

        # Card fill must be swapped AFTER global white→ink (GL): LIGHT_BG is #FFFFFF, same
        # as GLYPH_WHITE — if we set white first, the next line would recolor the bg too.
        $svg =~ s/fill="\Q$DARK_I\E"/fill="$LIGHT_I"/g;
        $svg =~ s/stroke="\Q$DARK_I\E"/stroke="$LIGHT_I"/g;
        $svg =~ s/fill="\Q$D_SAT\E"/fill="$L_SAT"/g;
        $svg =~ s/stroke="\Q$D_SAT\E"/stroke="$L_SAT"/g;
        $svg =~ s/stroke="\Q$GW\E"/stroke="$GL"/g;
        $svg =~ s/fill="\Q$GW\E"/fill="$GL"/g;

        # Only nmx-bg: global fill DARK_BG→LIGHT_BG would also hit glyph-fixed / strokes
        # already remapped to #1C1C1E (same hex as DARK_BG when L_SAT = GLYPH_ON_LIGHT).
        $svg =~ s{
            <(path|rect)\b
            [\s\S]*?
            \bid="nmx-bg"
            [\s\S]*?
            />
        }{
            my $b = $&;
            $b =~ s/\bfill="\Q$DARK_BG\E"/fill="$LIGHT_BG"/g;
            $b;
        }gex;

        $svg =~ s/fill="__NMX_GLYPH_NO_FILL__"/fill="$DARK_I"/g;
        $svg =~ s/stroke="__NMX_GLYPH_NO_STROKE__"/stroke="$DARK_I"/g;

        print $svg;
    '
}

echo "--- Namorix Factory: Starting Production ---"
echo "ROOT=$ROOT  DIST=$DIST"

# --- 5. VARIANT GENERATION (sources: icons/namorix-*.svg masters → dist/) ---
if ! command -v perl &>/dev/null; then
    echo "Error: perl is required to build symbol-* variants (strip background <path>)." >&2
    exit 1
fi

if [[ ! -d icons ]]; then
    echo "Error: no icons/ directory under $ROOT" >&2
    exit 1
fi

# Source = flat master SVG (box-dark artwork), e.g. namorix-addon.svg — not generated *-box-* / *-symbol-*.
while IFS= read -r -d '' MASTER; do
    REL="${MASTER#./}"
    STEM=$(basename "$MASTER" .svg)
    OUT_DIR="${DIST}"
    OUT_BASE="${OUT_DIR}/${STEM}"

    COLOR_KEY="${STEM#namorix-}"
    # With `set -u`, a missing associative key must not be expanded directly.
    MATCH_COLOR=""
    if [[ -v COLORS[$COLOR_KEY] ]]; then
        MATCH_COLOR=${COLORS[$COLOR_KEY]}
    fi
    if [ -n "$MATCH_COLOR" ]; then
        D_SAT=$(echo "$MATCH_COLOR" | cut -d'|' -f1)
        L_SAT=$(echo "$MATCH_COLOR" | cut -d'|' -f2)
    else
        D_SAT="#FFFFFF"
        L_SAT="#1C1C1E"
    fi

    mkdir -p "$OUT_DIR"

    echo "Processing variants for: $REL → ${OUT_BASE}-symbol-{dark,light}.svg (palette key: ${COLOR_KEY:-?})"

    export DARK_BG LIGHT_BG DARK_I LIGHT_I D_SAT L_SAT GLYPH_WHITE GLYPH_ON_LIGHT
    strip_svg_path_with_bg_fill "$DARK_BG" < "$MASTER" | apply_dark_variant_svg > "${OUT_BASE}-symbol-dark.svg"
    strip_svg_path_with_bg_fill "$DARK_BG" < "$MASTER" | apply_light_variant_svg > "${OUT_BASE}-symbol-light.svg"
done < <(find icons -type f -name 'namorix-*.svg' ! -name '*-box-*' ! -name '*-symbol-*' ! -path '*/.*' -print0)

# --- 6. METADATA & FORMATTING (dist/ only — do not modify icons/ sources) ---
if [[ ! -d "$DIST" ]]; then
    echo "No $DIST/ directory (no sources matched?). Skipping metadata pass."
else
    find "$DIST" -type f \( -name '*.png' -o -name '*.svg' \) ! -path '*/.*' -print0 | while IFS= read -r -d '' FILE; do
        echo "Syncing metadata: $FILE"

        if [[ "$FILE" == *.png ]]; then
            if command -v exiftool &>/dev/null; then
                exiftool -overwrite_original -q -Author="$AUTHOR" -Copyright="$COPYRIGHT" -Description="Official Namorix Asset" "$FILE"
            else
                echo "Warning: exiftool not found; skipping PNG metadata for $FILE" >&2
            fi

        elif [[ "$FILE" == *.svg ]]; then
            sed -i '/<metadata>/,/<\/metadata>/d' "$FILE"
            sed -i '/<rdf:RDF/,/<\/rdf:RDF>/d' "$FILE"
            sed -i '/^[[:space:]]*<\/metadata>[[:space:]]*$/d' "$FILE"
            sed -i "/$TAG_ID/d" "$FILE"

            METADATA="<metadata id=\"$TAG_ID\">
    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
             xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
             xmlns:cc=\"http://creativecommons.org/ns#\">
      <cc:Work rdf:about=\"\">
        <dc:title>Namorix Asset - $(basename "$FILE")</dc:title>
        <dc:date>2026</dc:date>
        <dc:creator><cc:Agent><dc:title>$AUTHOR</dc:title></cc:Agent></dc:creator>
        <dc:rights><cc:Agent><dc:title>$AUTHOR</dc:title></cc:Agent></dc:rights>
        <cc:license rdf:resource=\"$LICENSE\"/>
      </cc:Work>
    </rdf:RDF>
  </metadata>"

            awk -v meta="$METADATA" '/<svg[^>]*>/{print $0; print meta; next}1' "$FILE" > "$FILE.tmp"

            if command -v xmllint &>/dev/null; then
                if xmllint --format "$FILE.tmp" --output "$FILE" 2>/dev/null; then
                    rm -f "$FILE.tmp"
                else
                    echo "Warning: xmllint failed for $FILE — writing unformatted output." >&2
                    mv -f "$FILE.tmp" "$FILE"
                fi
            else
                mv -f "$FILE.tmp" "$FILE"
            fi
        fi
    done
fi

echo "--- Finished: outputs in $ROOT/$DIST/ ---"

#!/bin/bash

AUTHOR="Nguyen Danh Nam"
COPYRIGHT="Copyright (C) 2026 $AUTHOR. CC BY-NC-ND 4.0"
LICENSE="Licensed under Creative Commons Attribution-NonCommercial-NoDerivs 4.0"
DESC="Official Namorix Logo - Branding Assets"
TAG_ID="Namorix-Brand-Asset"

if ! ls *.png *.svg >/dev/null 2>&1; then
    echo "Error: No .svg or .png files found."
    exit 1
fi

echo "--- Metadata synchronization started ---"

find . -maxdepth 1 -name "*.png" -o -name "*.svg" | while read -r FILE; do
    FILE=${FILE#./}
    echo "Processing: $FILE"
    
    echo "  Current metadata:"
    if [[ "$FILE" == *.png ]]; then
        # Check standard PNG tags
        exiftool -S -Author -Copyright -Description "$FILE" | sed 's/^/    /'
    else
        # Check for our custom SVG comment
        grep "$TAG_ID" "$FILE" | sed 's/^/    /'
    fi

    if [[ "$FILE" == *.png ]]; then
        # Using CopyrightNotice instead of Notice to avoid PNG write errors
        exiftool -overwrite_original -q \
            -Author="$AUTHOR" \
            -Copyright="$COPYRIGHT" \
            -CopyrightNotice="$LICENSE" \
            -Description="$DESC" \
            -Creator="$AUTHOR" \
            -Rights="$COPYRIGHT" \
            "$FILE"
        echo "  Result: PNG metadata updated (Standard Tags)."

    elif [[ "$FILE" == *.svg ]]; then
        sed -i "/$TAG_ID/d" "$FILE"
        META_COMMENT=""
        sed -i "s|<svg[^>]*>|&\n  $META_COMMENT|" "$FILE"
        echo "  Result: SVG XML comment injected."
    fi
    echo "----------------------------------------"
done

echo "--- Metadata synchronization finished ---"

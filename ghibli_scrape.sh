#!/bin/bash

BASE_URL="https://www.ghibli.jp"
INFO_PAGE="${BASE_URL}/info/013772/"
OUTPUT_DIR="images"

mkdir -p "$OUTPUT_DIR"

echo "Fetching movie list from $INFO_PAGE..."

MOVIE_URLS=$(curl -s "$INFO_PAGE" | grep -o 'href="[^"]*works[^"]*"' | sed -E 's/href="([^"]*)"/\1/' | sed -E 's/#.*//' | grep -v 'works/$' | sort | uniq)

if [ -z "$MOVIE_URLS" ]; then
    echo "Error: No movie links found."
    exit 1
fi

for MOVIE_PAGE_URL in $MOVIE_URLS; do
    MOVIE_NAME=$(echo "$MOVIE_PAGE_URL" | sed -E 's/.*\/works\/([^\/]+)\/?.*/\1/')
    
    if [[ "$MOVIE_PAGE_URL" != http* ]]; then
        MOVIE_PAGE_URL="${BASE_URL}${MOVIE_PAGE_URL}"
    fi
     
    echo "Processing $MOVIE_NAME ($MOVIE_PAGE_URL)..."
    
    TARGET_DIR="${OUTPUT_DIR}/${MOVIE_NAME}"
    mkdir -p "$TARGET_DIR"
    
    IMAGE_URLS=$(curl -s "$MOVIE_PAGE_URL" | grep -o 'href="[^"]*gallery[^"]*\.jpg"' | sed -E 's/href="([^"]*)"/\1/')
    
    if [ -z "$IMAGE_URLS" ]; then
        echo "  No images found for $MOVIE_NAME."
        sleep 1
        continue
    fi
    
    COUNT=0
    for IMAGE_URL in $IMAGE_URLS; do
        FILENAME=$(basename "$IMAGE_URL")
        FILEPATH="${TARGET_DIR}/${FILENAME}"
        
        if [ -f "$FILEPATH" ]; then
            echo "  Skipping $FILENAME (already exists)"
            continue
        fi
        
        echo "  Downloading $FILENAME..."
        curl -s -o "$FILEPATH" "$IMAGE_URL"
        
        sleep 0.5
        ((COUNT++))
    done
    
    echo "  Downloaded $COUNT new images for $MOVIE_NAME."
    
    sleep 2
done

echo "Done!"

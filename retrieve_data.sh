#!/usr/bin/env bash

# Step 1: Extract version and size from params.yml
VERSION=$(grep 'version:' params.yml | awk '{print $2}')
SIZE=$(grep "${VERSION}" -A 1 params.yml | tail -n 1 | awk '{print $2}')

# Step 2: Define the API endpoint and data destination
API_URL="https://jsonplaceholder.typicode.com/photos"
DATA_FILE="datahub/data.json"

# Step 3: Fetch data from API and format with jq to limit the dataset size
TEMP_FILE="temp_data.json"
curl -s "$API_URL" | jq ".[:$SIZE]" > "$TEMP_FILE"

# Step 4: Compare with existing data.json
if cmp -s "$TEMP_FILE" "$DATA_FILE"; then
    echo "No changes; data has not changed."
    rm "$TEMP_FILE"  # Clean up temporary file
    exit 0
else
    mv "$TEMP_FILE" "$DATA_FILE"  # Replace with new data
    echo "Data updated for version $VERSION with size $SIZE."
fi

# Step 5: Display data information
echo "Current version: $VERSION"
echo "Total dataset size: $(jq '. | length' $DATA_FILE)"
echo "Sample of three rows:"
jq '.[0:3]' "$DATA_FILE"
# Trigger workflow

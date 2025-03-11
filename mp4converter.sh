#!/bin/bash

# Configuration
SONARR_PATH="/media/myfiles/Sonarr/tvshows"
RADARR_PATH="/media/myfiles/Radarr/movies"
LOG_FILE="/var/log/media_converter.log"
TEMP_DIR="/tmp/conversion"
PROCESSED_STATE_DIR="/tmp/media_converter_state"
LOOKBACK_PERIOD=30  # Number of days to look back for new files

# Create temp directory if it doesn't exist
mkdir -p "$TEMP_DIR"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if file is already H.264
is_h264() {
    local file="$1"
    # Properly quote the filename to handle spaces and special characters
    local codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file")

    if [[ "$codec" == "h264" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to convert a file to H.264
convert_to_h264() {
    local input_file="$1"
    # Create a sanitized output filename
    local basename=$(basename "$input_file")
    local output_file="${TEMP_DIR}/${basename%.*}.mp4"

    log "Converting $input_file to H.264"

    # Get audio codec - properly quote the filename
    local audio_codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_file")

    # Convert video to H.264 and keep audio intact if it's already AAC
    if [[ "$audio_codec" == "aac" ]]; then
        # Add proper quoting around filenames
        ffmpeg -i "$input_file" -c:v libx264 -preset medium -crf 20 -c:a copy -movflags +faststart "$output_file" < /dev/null
    else
        # Add proper quoting around filenames
        ffmpeg -i "$input_file" -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 192k -movflags +faststart "$output_file" < /dev/null
    fi

    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        log "Conversion successful: $output_file"

        # Copy all metadata and subtitles
        if [ -f "$output_file" ]; then
            # Move the converted file back to original location
            mv "$output_file" "$input_file"
            log "Replaced original file with converted version"
            return 0
        else
            log "Error: Output file not found after conversion"
            return 1
        fi
    else
        log "Error: Conversion failed for $input_file"
        return 1
    fi
}

# Process files function to reduce code duplication
process_files() {
    local dir_path="$1"
    local dir_name="$2"

    log "Processing $dir_name at $dir_path"

    # Use find with -print0 and process with while read -d '' to handle filenames with spaces correctly
    find "$dir_path" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" \) -not -path "*/sample/*" -not -path "*/Sample/*" -print0 | while IFS= read -r -d '' file; do
        # Generate a unique identifier for this file based on path and size
        FILE_ID=$(echo "$file" | md5sum | cut -d' ' -f1)
        FILE_SIZE=$(stat -c%s "$file")
        UNIQUE_ID="${FILE_ID}_${FILE_SIZE}"

        # Debug information
        log "Checking file: $file (ID: $UNIQUE_ID)"

        # Check if file was modified within the lookback period (newly downloaded)
        if [[ $(find "$file" -mtime -${LOOKBACK_PERIOD} -print) ]]; then
            # Check if we've already processed this file
            if [ -f "${PROCESSED_STATE_DIR}/${UNIQUE_ID}" ]; then
                # File has been processed before
                log "File already processed previously, skipping: $file"
                continue
            fi

            log "Processing new file: $file"

            # Check if already H.264
            if is_h264 "$file"; then
                log "File is already H.264, marking as processed: $file"
                # Mark as processed
                touch "${PROCESSED_STATE_DIR}/${UNIQUE_ID}"
            else
                log "File needs conversion to H.264: $file"
                # Convert the file
                if convert_to_h264 "$file"; then
                    # Mark as processed only if conversion was successful
                    touch "${PROCESSED_STATE_DIR}/${UNIQUE_ID}"
                    log "File successfully converted and marked as processed: $file"
                else
                    log "Conversion failed, not marking as processed: $file"
                fi
            fi
        else
            log "File outside lookback period (not new), skipping: $file"
        fi
    done
}

# Process Sonarr TV Shows
process_sonarr() {
    process_files "$SONARR_PATH" "Sonarr TV Shows"
}

# Process Radarr Movies
process_radarr() {
    process_files "$RADARR_PATH" "Radarr Movies"
}

# State directory for tracking processed files
mkdir -p "$PROCESSED_STATE_DIR"

# Cleanup old state files (remove entries older than 30 days)
find "$PROCESSED_STATE_DIR" -type f -mtime +30 -delete

# Main execution
log "Starting media conversion process"

# Clear the state directory if FORCE_REPROCESS flag is set
if [ "$1" == "--force" ]; then
    log "Force reprocessing requested. Clearing state directory."
    rm -rf "${PROCESSED_STATE_DIR:?}/"*
fi

process_radarr
process_sonarr
log "Completed media conversion process"

# Clean up temp directory
rm -rf "${TEMP_DIR:?}/"*

exit 0

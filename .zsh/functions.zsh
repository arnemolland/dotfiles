# upload to file.io
fileio() {
    if [ -z "$1" ]; then
        echo "No file passed."
        return
    fi
    if [ -z "$2" ]; then
        echo "No expiry date set. Defaulting to 2 years."
        curl -s -F "file=@$1" "https://file.io/?expires=2y" | jq -r '.link' | pbcopy
        echo "Copied to clipboard"
    else
        curl -s -F "file=@$1" "https://file.io/?expires=$2" | jq -r '.link' | pbcopy
        echo "Copied to clipboard"
    fi
}

# cleans all SVG files in directory
svgclean() {
    for file in *; do
        svgcleaner "$file" "$file"
    done
}
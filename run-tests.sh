#!/bin/bash

echo "Building HTML5 tests..."
haxe build-html5.hxml

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Opening tests in browser..."

    # Try to open in default browser
    if command -v open &> /dev/null; then
        # macOS
        open out/test/index.html
    elif command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open out/test/index.html
    elif command -v start &> /dev/null; then
        # Windows
        start out/test/index.html
    else
        echo "Please open out/test/index.html in your browser"
    fi
else
    echo "Build failed!"
    exit 1
fi
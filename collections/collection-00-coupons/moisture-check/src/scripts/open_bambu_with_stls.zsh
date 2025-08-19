#!/bin/zsh
set -euo pipefail

# Workaround script for Bambu Studio CLI segfault issue
# Opens Bambu Studio GUI with the STL files

STL1="$1"
STL2="$2"
PRJ="$3"

echo "Opening Bambu Studio with STL files..."
echo "STL1: $STL1"
echo "STL2: $STL2"
echo "Target project: $PRJ"
echo ""
echo "To complete the process manually:"
echo "1. Import both STL files into Bambu Studio"
echo "2. Arrange them on the build plate"
echo "3. Save the project as: $PRJ"
echo ""

# Try to open Bambu Studio with the STL files
open -a "BambuStudio" "$STL1" "$STL2" || {
    echo "Failed to open with application name, trying direct path..."
    open "/Applications/BambuStudio.app" --args "$STL1" "$STL2" || {
        echo "Could not open Bambu Studio automatically."
        echo "Please manually open Bambu Studio and import the STL files."
    }
}

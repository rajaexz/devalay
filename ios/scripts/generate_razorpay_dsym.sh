#!/bin/sh

# Script to generate dSYM files for Razorpay.framework
# This fixes the App Store Connect archive validation error
# Run this as a build phase script in Xcode

set -e

echo "🔍 [Razorpay dSYM] Checking for Razorpay framework..."

# Try multiple locations for Razorpay framework
RAZORPAY_FRAMEWORK_PATH=""

# Location 1: In built products (most common)
if [ -d "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Razorpay.framework" ]; then
    RAZORPAY_FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Razorpay.framework"
# Location 2: In Pods
elif [ -d "${PODS_ROOT}/razorpay-pod/Razorpay.framework" ]; then
    RAZORPAY_FRAMEWORK_PATH="${PODS_ROOT}/razorpay-pod/Razorpay.framework"
# Location 3: In app bundle
elif [ -d "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Frameworks/Razorpay.framework" ]; then
    RAZORPAY_FRAMEWORK_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Frameworks/Razorpay.framework"
fi

if [ -z "$RAZORPAY_FRAMEWORK_PATH" ] || [ ! -d "$RAZORPAY_FRAMEWORK_PATH" ]; then
    echo "⚠️  [Razorpay dSYM] Razorpay.framework not found. Skipping dSYM generation."
    echo "   Searched in:"
    echo "   - ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Razorpay.framework"
    echo "   - ${PODS_ROOT}/razorpay-pod/Razorpay.framework"
    exit 0
fi

echo "✅ [Razorpay dSYM] Found Razorpay.framework at: $RAZORPAY_FRAMEWORK_PATH"

# Get the binary
FRAMEWORK_BINARY="${RAZORPAY_FRAMEWORK_PATH}/Razorpay"

if [ ! -f "$FRAMEWORK_BINARY" ]; then
    echo "⚠️  [Razorpay dSYM] Razorpay binary not found at: $FRAMEWORK_BINARY"
    exit 0
fi

# Set dSYM output path
# For archive builds, DWARF_DSYM_FOLDER_PATH should be set
if [ -z "$DWARF_DSYM_FOLDER_PATH" ]; then
    # Fallback to default location
    DWARF_DSYM_FOLDER_PATH="${TARGET_BUILD_DIR}"
fi

DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/Razorpay.framework.dSYM"

echo "🔨 [Razorpay dSYM] Generating dSYM file..."
echo "   Binary: $FRAMEWORK_BINARY"
echo "   Output: $DSYM_OUTPUT"

# Generate dSYM using dsymutil
if command -v dsymutil &> /dev/null; then
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$DSYM_OUTPUT")"
    
    # Generate dSYM
    dsymutil "$FRAMEWORK_BINARY" -o "$DSYM_OUTPUT" 2>&1 || {
        echo "⚠️  [Razorpay dSYM] dsymutil failed, but continuing build..."
        exit 0
    }
    
    if [ -d "$DSYM_OUTPUT" ]; then
        echo "✅ [Razorpay dSYM] Successfully generated dSYM at: $DSYM_OUTPUT"
        
        # Verify the UUID if dwarfdump is available
        if command -v dwarfdump &> /dev/null; then
            UUID=$(dwarfdump -u "$DSYM_OUTPUT" 2>/dev/null | head -1 | awk '{print $2}' || echo "")
            if [ ! -z "$UUID" ]; then
                echo "📋 [Razorpay dSYM] dSYM UUID: $UUID"
            fi
        fi
    else
        echo "⚠️  [Razorpay dSYM] dSYM generation may have failed, but continuing..."
    fi
else
    echo "⚠️  [Razorpay dSYM] dsymutil not found. Skipping dSYM generation."
    echo "   Install Xcode Command Line Tools: xcode-select --install"
fi

exit 0


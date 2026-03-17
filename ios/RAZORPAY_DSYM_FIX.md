# Fix for Razorpay dSYM Missing Error

This document explains how to fix the App Store Connect error:
> "The archive did not include a dSYM for the Razorpay.framework"

## Solution

### Option 1: Add Build Script via Xcode (Recommended)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target in the project navigator
3. Go to **Build Phases** tab
4. Click the **+** button at the top and select **New Run Script Phase**
5. Name it: `Generate Razorpay dSYM`
6. Drag it to run **after** `[CP] Embed Pods Frameworks` phase
7. Add this script:

```bash
"${SRCROOT}/scripts/generate_razorpay_dsym.sh"
```

8. Make sure "Run script only when installing" is **unchecked**
9. Clean build folder (Cmd+Shift+K) and rebuild

### Option 2: Manual dSYM Generation (Alternative)

If Option 1 doesn't work, you can manually generate the dSYM:

1. After archiving, locate your archive
2. Right-click the archive → Show in Finder
3. Right-click the `.xcarchive` → Show Package Contents
4. Navigate to `dSYMs` folder
5. Run this command in Terminal:

```bash
# Find Razorpay framework in the archive
FRAMEWORK_PATH="dSYMs/Razorpay.framework"
if [ -d "$FRAMEWORK_PATH" ]; then
    echo "Razorpay framework found"
else
    # Generate dSYM from the binary
    dsymutil "Products/Applications/YourApp.app/Frameworks/Razorpay.framework/Razorpay" -o "dSYMs/Razorpay.framework.dSYM"
fi
```

### Option 3: Update Podfile (Already Done)

The Podfile has been updated to ensure dSYM generation is enabled. Run:

```bash
cd ios
pod install
```

Then rebuild and archive again.

## Verification

After archiving, verify the dSYM exists:

1. Open the archive in Xcode Organizer
2. Right-click → Show in Finder
3. Right-click `.xcarchive` → Show Package Contents
4. Check `dSYMs` folder for `Razorpay.framework.dSYM`

## Notes

- The script automatically generates dSYM files for Razorpay framework
- This only affects Release/Archive builds
- Debug builds are not affected


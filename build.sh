#!/bin/bash
# Build script for ActivityTrackerGodMode

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building ActivityTrackerGodMode...${NC}"

# Verify Info.plist exists
if [ ! -f "activitytrackergodmode/Info.plist" ]; then
  echo -e "${RED}Error: Info.plist is missing!${NC}"
  exit 1
fi

# Add LSUIElement to Info.plist if not present
if ! grep -q "LSUIElement" "activitytrackergodmode/Info.plist"; then
  echo -e "${YELLOW}Adding LSUIElement to Info.plist...${NC}"
  cat > activitytrackergodmode/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
fi

# Build the app
echo -e "${GREEN}Building app...${NC}"
xcodebuild -project activitytrackergodmode.xcodeproj -scheme activitytrackergodmode || exit 1

echo -e "${GREEN}Build completed successfully!${NC}"

# Find the app location in DerivedData
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "activitytrackergodmode.app" -type d 2>/dev/null | grep -v Index | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo -e "${RED}Could not find app in DerivedData!${NC}"
  exit 1
fi

# Check if we should run the app
if [ "$1" = "run" ]; then
  echo -e "${GREEN}Launching app: ${APP_PATH}${NC}"
  
  # Kill previous instances if running
  pkill -f activitytrackergodmode || true
  
  # Check if app executable exists
  if [ ! -f "${APP_PATH}/Contents/MacOS/activitytrackergodmode" ]; then
    echo -e "${RED}The application executable is missing!${NC}"
    echo -e "${YELLOW}Trying to find it in alternate locations...${NC}"
    
    # Find any instances of the executable
    EXECUTABLE_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "activitytrackergodmode" -type f -not -path "*/\.git/*" 2>/dev/null | head -n 1)
    
    if [ -n "$EXECUTABLE_PATH" ]; then
      echo -e "${GREEN}Found executable at: ${EXECUTABLE_PATH}${NC}"
      echo -e "${YELLOW}Launching directly...${NC}"
      "$EXECUTABLE_PATH" &
    else
      echo -e "${RED}Could not find executable. Open the app from Xcode directly.${NC}"
      open activitytrackergodmode.xcodeproj
    fi
  else
    # Open the app
    open "$APP_PATH"
  fi
fi

exit 0

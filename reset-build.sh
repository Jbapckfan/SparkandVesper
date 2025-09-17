#!/bin/bash

# Reset Build Environment for Spark & Vesper
# Fixes common build issues by cleaning derived data and resetting pods

echo "🔧 Resetting Spark & Vesper build environment..."

# Clean Xcode derived data
echo "🧹 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Spark*

# Clean CocoaPods cache
echo "🧹 Cleaning CocoaPods cache..."
pod cache clean --all

# Reinstall pods
echo "📦 Reinstalling CocoaPods dependencies..."
pod deintegrate
pod install

echo "✅ Build environment reset complete!"
echo ""
echo "Next steps:"
echo "1. Open Spark&Vesper.xcworkspace in Xcode"
echo "2. Add Services folder to project if not already added"
echo "3. Build and run (Cmd+R)"
echo ""
echo "If you still have issues, see BUILD_TROUBLESHOOTING.md"
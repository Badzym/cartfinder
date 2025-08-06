#!/bin/bash

echo "🔍 Checking for API keys in repository..."

# Check for Google Maps API keys
echo "📍 Checking for Google Maps API keys..."
if grep -r "AIzaSy" . --exclude-dir=node_modules --exclude-dir=android --exclude-dir=www --exclude-dir=.git --exclude=check-api-keys.sh --exclude-dir=build --exclude-dir=.angular --exclude=SETUP.md 2>/dev/null; then
    echo "❌ Found Google Maps API keys in repository!"
    exit 1
else
    echo "✅ No Google Maps API keys found in repository"
fi

# Check for Firebase API keys
echo "🔥 Checking for Firebase API keys..."
if grep -r "AIzaSy" . --exclude-dir=node_modules --exclude-dir=android --exclude-dir=www --exclude-dir=.git --exclude=check-api-keys.sh --exclude-dir=build --exclude-dir=.angular --exclude=SETUP.md 2>/dev/null; then
    echo "❌ Found Firebase API keys in repository!"
    exit 1
else
    echo "✅ No Firebase API keys found in repository"
fi

# Check for template files
echo "📋 Checking for template files..."
if [ -f "src/environments/environment.template.ts" ] && [ -f "src/environments/environment.prod.template.ts" ]; then
    echo "✅ Template files exist"
else
    echo "❌ Template files missing!"
    exit 1
fi

# Check gitignore
echo "🔒 Checking .gitignore..."
if grep -q "environment.ts" .gitignore && grep -q "AndroidManifest.xml" .gitignore; then
    echo "✅ .gitignore properly configured"
else
    echo "❌ .gitignore missing API key exclusions!"
    exit 1
fi

echo "🎉 All security checks passed!"
echo "✅ API keys are properly secured"
echo "✅ Template files are in place"
echo "✅ .gitignore is configured correctly" 
# Firebase Setup Guide for Spark & Vesper

## Prerequisites Completed ✅
- CocoaPods installed and `pod install` executed
- Firebase SDK integrated via Podfile
- Info.plist updated with AdMob App ID

## Next Steps Required

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "Spark and Vesper"
4. Enable Google Analytics when prompted
5. Select or create a Google Analytics account

### 2. Add iOS App to Firebase
1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter iOS Bundle ID: `com.sparkandvesper.game` (or your actual bundle ID)
3. App nickname: "Spark & Vesper"
4. App Store ID: (leave blank for now, add after App Store submission)
5. Click "Register app"

### 3. Download Configuration File
1. Download `GoogleService-Info.plist` from Firebase Console
2. Drag the file into Xcode project navigator
3. Make sure to check "Copy items if needed"
4. Target membership: Spark&Vesper

### 4. Initialize Firebase in App
The initialization code is already prepared in `SparkAndVesperApp.swift`:
```swift
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

### 5. Enable Firebase Services

#### Analytics (Already in code)
- Automatically starts collecting once Firebase is initialized
- View in Firebase Console > Analytics

#### Crashlytics
1. Firebase Console > Crashlytics > Enable Crashlytics
2. Build and run app to send first crash report
3. Force a test crash (in debug only):
```swift
#if DEBUG
fatalError("Test crash")
#endif
```

#### Remote Config (for A/B Testing)
1. Firebase Console > Remote Config > Create configuration
2. Add parameters:
   - `interstitial_frequency`: Default value `3` (show ad every 3 levels)
   - `rewarded_ad_hints`: Default value `3` (hints per rewarded ad)
   - `daily_reward_multiplier`: Default value `1.0`

### 6. AdMob Linking
1. In Firebase Console, go to Settings > Project Settings > Integrations
2. Link to AdMob
3. Select your AdMob account
4. Link the apps

### 7. Update AdMob IDs
Edit `/Services/AdMobManager.swift` and replace production IDs:
```swift
#else
// Production ad unit IDs - REPLACE WITH YOUR ACTUAL IDS
static let appID = "ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID"
static let bannerID = "ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_ID"
static let interstitialID = "ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_ID"
static let rewardedID = "ca-app-pub-YOUR_PUBLISHER_ID/YOUR_REWARDED_ID"
#endif
```

### 8. Test Device Setup
1. Run app on physical device
2. Check Xcode console for test device ID
3. Add to `AdMobManager.swift`:
```swift
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    GADSimulatorID,
    "YOUR_TEST_DEVICE_ID_HERE"
]
```

### 9. App Tracking Transparency (iOS 14.5+)
The Info.plist already includes:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>This allows us to provide you with personalized ads and helps support the game.</string>
```

### 10. Verify Integration
1. Build and run the app
2. Check Xcode console for:
   - "📱 AdMob SDK initialized"
   - "Firebase Analytics enabled"
   - No Firebase configuration errors
3. Check Firebase Console for first events (may take up to 24 hours)

## Revenue Optimization Checklist

### Ad Placement Strategy
- [x] Banner ads in menus only (not during gameplay)
- [x] Interstitial ads every 3 levels completed
- [x] Rewarded ads for hints and level skips
- [x] 3-minute cooldown between interstitials
- [x] Smart capping to prevent ad fatigue

### In-App Purchases
- [x] Remove Ads ($2.99)
- [x] Hint Packs ($1.99)
- [x] Premium Level Pack ($4.99)
- [x] Pro Version ($9.99)
- [x] Sparks Currency (100-10000 sparks)

### Analytics Events to Track
- Level starts/completes/failures
- Ad impressions and clicks
- IAP purchases
- Player retention (D1, D7, D30)
- Session duration
- Tutorial completion rate

## Testing Checklist

Before Release:
- [ ] Test all IAP products in sandbox
- [ ] Verify ads show correctly (test ads)
- [ ] Check Firebase Analytics dashboard
- [ ] Test Crashlytics reporting
- [ ] Verify Remote Config parameters
- [ ] Test on multiple iOS versions (15.0+)
- [ ] Test on various device sizes

## Support Resources

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [AdMob iOS Quick Start](https://developers.google.com/admob/ios/quick-start)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics/get-started?platform=ios)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config/get-started?platform=ios)
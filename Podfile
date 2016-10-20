# Uncomment this line to define a global platform for your project

source 'https://github.com/CocoaPods/Specs.git'


platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

target 'MOV' do
    pod 'CSStickyHeaderFlowLayout'
    pod 'IQKeyboardManager'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    pod 'AFNetworking', '~> 2.6.3'
    pod 'SVProgressHUD'
    pod 'FLAnimatedImage'
    pod 'AWSS3', '= 2.3.5'
    pod 'BBBadgeBarButtonItem'
    pod 'InstagramKit', '~> 3.0'
    pod 'Branch'
    pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
    pod 'Appsee'
    pod 'SwiftyJSON'
    pod 'Fabric'
    pod 'TwitterKit'
    pod 'TTTAttributedLabel', '~> 2.0'
    pod 'Braintree'
    pod 'Braintree/Venmo'
    pod 'Siren'
    pod 'Mixpanel'
    pod 'SCRecorder'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Appsee'
    pod 'UILabel+Copyable', '~> 1.0.0'
    
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end

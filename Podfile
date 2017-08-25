platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def core_pods
    pod 'Firebase'
    pod 'Firebase/Core'
    pod 'FirebaseMessaging'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Crash'
    pod 'Firebase/AdMob'
    pod 'FirebaseUI/Auth', '~> 0.7'
    pod 'FirebaseUI/Facebook', '~> 0.7'
    pod 'FirebaseUI/Google', '~> 0.7'
    pod 'GoogleSignIn'
    pod 'SDWebImage'
    pod 'DateToolsSwift'
end

target 'Mustage' do
    core_pods
end

target 'MustageTests' do
    core_pods
end

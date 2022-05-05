Pod::Spec.new do |s|

s.name = 'SwiftyRate'
s.version = '3.5.5'
s.license = 'MIT'
s.summary = 'A Swift helper to show a SKStoreReviewController or a custom review UIAlertController.'

s.homepage = 'https://github.com/crashoverride777/swifty-rate'
s.authors = { 'Dominik Ringler' => 'overrideinteractive@icloud.com' }

s.swift_version = '5.0'
s.requires_arc = true
s.ios.deployment_target = '9.3'
    
s.source = {
    :git => 'https://github.com/crashoverride777/swifty-rate.git',
    :tag => s.version
}

s.source_files = 'Sources/**/*.{swift}'

end

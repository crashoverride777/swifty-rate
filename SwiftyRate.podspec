Pod::Spec.new do |s|

s.name = 'SwiftyRate'
s.version = '3.2.4'
s.license = 'MIT'
s.summary = 'A Swift helper to show a SKStoreReviewController or a custom rate app alert.'
s.homepage = 'https://github.com/crashoverride777/SwiftyRate'
s.social_media_url = 'http://twitter.com/overrideiactive'
s.authors = { 'Dominik' => 'overrideinteractive@icloud.com' }

s.requires_arc = true
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

s.ios.deployment_target = '10.3'

s.source = {
    :git => 'https://github.com/crashoverride777/SwiftyRate.git',
    :tag => '3.2.4'
}

s.source_files = "SwiftyRate/**/*.{swift}"

end

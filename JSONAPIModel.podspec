Pod::Spec.new do |spec|
  spec.name         = 'JSONAPIModel'
  spec.version      = '1.0.0'
  spec.summary      = 'Simple JSONAPI parser / serializer and data model'
  spec.homepage     = 'https://github.com/envoy/JSONAPIModel'
  spec.license      = 'MIT'
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author             = { 'Fang-Pen Lin' => 'fang@envoy.com' }
  spec.social_media_url   = 'https://twitter.com/fangpenlin'
  spec.ios.deployment_target = '9.0'
  spec.source       = {
    git: 'https://github.com/envoy/JSONAPIModel.git',
    tag: "v#{spec.version}"
  }
  spec.source_files = 'JSONAPIModel/*.swift', 'JSONAPIModel/**/*.swift'
  spec.dependency 'SwiftyJSON', '~> 4.0'
end

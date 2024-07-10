Pod::Spec.new do |s|
  s.name             = 'YopakiBIP39'
  s.version          = '1.0.0'
  s.summary          = 'Swift implementation without dependencies of Trezor\'s python-mnemonic.'

  s.description      = <<-DESC
CSwift implementation without dependencies of Trezor\'s python-mnemonic.
                       DESC

  s.homepage         = 'https://github.com/yopaki/bip39-swift'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Chida' => 'carlos@yopaki.com' }
  s.source           = { :git => 'https://github.com/yopaki/bip39-swift.git', :tag => s.version.to_s }

  s.swift_version    = '5.4'

  base_platforms     = { :ios => '13', :osx => '10.15', :tvos => '12' }
  s.platforms        = base_platforms.merge({ :watchos => '6.0' })

  s.module_name      = 'BIP39'

  s.source_files     = 'Sources/BIP39/**/*.swift'

  s.test_spec 'Tests' do |ts|
    ts.platforms = base_platforms
    ts.source_files = 'Tests/BIP39Tests/**/*.swift'
  end
end
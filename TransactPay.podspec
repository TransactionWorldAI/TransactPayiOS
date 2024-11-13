Pod::Spec.new do |s|
  s.name         = "TransactPay"
  s.version      = "1.0.0"
  s.summary      = "A payment SDK"
  s.description  = <<-DESC
                   A Payment SDK
                   DESC
  s.homepage     = "https://merchant.transactpay.ai"

  s.author       = { "JAMES ANYANWU" => "geniusjames7@gmail.com" }
#  s.source       = { :git => "https://github.com/username/YourFramework.git", :tag => s.version.to_s }
  s.source = { :git => 'https://github.com/geniusjames/TransactPay.git', :tag => s.version.to_s }

  s.platform     = :ios, "13.0"
  s.source_files = "TransactPay/**/*.{h,m,swift}"
  s.dependency "SwiftyRSA"
  s.dependency "AEXML"
  s.dependency "CryptoSwift"
  s.dependency "SnapKit"
  s.license = "MIT"
end

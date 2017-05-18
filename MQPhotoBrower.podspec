Pod::Spec.new do |s|

  s.name = 'MQPhotoBrower'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Elegant photo browser, Write in Swift.'
  s.homepage = 'https://github.com/Arror/MQPhotoBrower'
  s.authors = { 'Arror' => 'hallo.maqiang@gmail.com' }
  s.source = { git: 'https://github.com/Arror/MQPhotoBrower.git', tag: s.version }

  s.platform = :ios, '8.0'
  s.source_files = 'Sources/*.swift'
  s.resource_bundles = {
    'MQPhotoBrower' => ['Assets/*.storyboard']
  }

  s.dependency "Kingfisher"

end
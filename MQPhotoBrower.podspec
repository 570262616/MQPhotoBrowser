Pod::Spec.new do |s|

  s.name = 'MQPhotoBrower'
  s.version = '0.1.0'
  s.license = { :type => 'MIT', :text => <<-LICENSE
                    MIT License

                    Copyright (c) 2017 Arror

                    Permission is hereby granted, free of charge, to any person obtaining a copy
                    of this software and associated documentation files (the "Software"), to deal
                    in the Software without restriction, including without limitation the rights
                    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                    copies of the Software, and to permit persons to whom the Software is
                    furnished to do so, subject to the following conditions:

                    The above copyright notice and this permission notice shall be included in all
                    copies or substantial portions of the Software.

                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                    SOFTWARE.

                 LICENSE
  }
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
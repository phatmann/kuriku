platform :ios, "7.0"

target "Kuriku" do
    pod "InnerBand", :git => 'git@github.com:phatmann/InnerBand.git' # :path => '/Users/tony/Documents/src/phatmann/InnerBand'
    pod "TPKeyboardAvoiding"
    pod "CoreParse", :git => 'git@github.com:phatmann/CoreParse.git', :branch => 'pod'
    pod "NUI", :git => 'git@github.com:phatmann/nui.git'
    pod "SAMTextView"
end

target "KurikuTests" do
    pod "OCHamcrest"
    pod "KIF", :git => 'git@github.com:kif-framework/KIF.git'
end

link_with 'Kuriku', 'KurikuTests'


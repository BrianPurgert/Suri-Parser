require 'ferrum'
require 'json'
require_relative 'data_file'

test_url = 'http://192.168.1.9/2017/84/PAGEproductdetaildo-GSIN11000040723989-CVIEWtrue-.html'

browser_options = {
'no-sandbox'                                         => nil,
'allow-running-insecure-content'                     => nil,
'autoplay-policy'                                    => 'user-gesture-required',
'disable-add-to-shelf'                               => nil,
'disable-background-networking'                      => nil,
'disable-background-timer-throttling'                => nil,
'disable-backgrounding-occluded-windows'             => nil,
'disable-breakpad'                                   => nil,
'disable-checker-imaging'                            => nil,
'disable-client-side-phishing-detection'             => nil,
'disable-component-extensions-with-background-pages' => nil,
'disable-datasaver-prompt'                           => nil,
'disable-default-apps'                               => nil,
'disable-desktop-notifications'                      => nil,
'disable-dev-shm-usage'                              => nil,
'disable-domain-reliability'                         => nil,
'disable-extensions'                                 => nil,
'disable-features'                                   => 'TranslateUI,BlinkGenPropertyTrees',
'disable-hang-monitor'                               => nil,
'disable-infobars'                                   => nil,
'disable-ipc-flooding-protection'                    => nil,
'disable-notifications'                              => nil,
'disable-popup-blocking'                             => nil,
'disable-prompt-on-repost'                           => nil,
'disable-renderer-backgrounding'                     => nil,
'disable-setuid-sandbox'                             => nil,
'disable-site-isolation-trials'                      => nil,
'disable-sync'                                       => nil,
'disable-web-security'                               => nil,
'enable-automation'                                  => nil,
'force-color-profile'                                => 'srgb',
'force-device-scale-factor'                          => '1',
'ignore-certificate-errors'                          => nil,
'js-flags'                                           => '--random-seed=1157259157',
'disable-logging'                                    => nil,
'metrics-recording-only'                             => nil,
'mute-audio'                                         => nil,
'no-default-browser-check'                           => nil,
'no-first-run'                                       => nil,
'password-store'                                     => 'basic',
'test-type'                                          => nil,
'use-mock-keychain'                                  => nil
}

browser = Ferrum::Browser.new(browser_options: browser_options, timeout: 30, window_size: [1440, 900], process_timeout: 30, headless: false)
browser.go_to(test_url)
body       = browser.page.body.to_s
datafile   = DataFile.new(body, test_url)
input_hash = datafile.to_h
json_str   = JSON.generate(input_hash)
File.open("output.json", "w") do |file|
	file.write(json_str)
end
browser.quit
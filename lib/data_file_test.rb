require 'ferrum'
require 'json'
require_relative 'data_file'
require_relative 'methods'
require 'amazing_print'
require 'fileutils' # Needed for directory creation

url = 'https://getthis.page/test_page.html'

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

body     = fetch_body(url)
datafile = DataFile.new(body, url)
response = datafile.to_h
name     = "date_file_test"
puts path = File.expand_path("../datafiles/#{name}.json", __FILE__)

# Create the directory if it doesn't exist
FileUtils.mkdir_p(File.dirname(path))

File.open(path, "w") { |f| f.write(JSON.pretty_generate(response)) }
response

ap response

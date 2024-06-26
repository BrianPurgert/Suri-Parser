BROWSER_OPTIONS = {
                    'no-sandbox'                                         => nil,
                    'allow-running-insecure-content'                     => nil,
                    'autoplay-policy'                                    => 'user-gesture-required',
                    'disable-add-to-shelf'                               => nil,
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
                    'disable-logging'                                    => nil,
                    'metrics-recording-only'                             => nil,
                    'mute-audio'                                         => nil,
                    'no-default-browser-check'                           => nil,
                    'no-first-run'                                       => nil,
                    'password-store'                                     => 'basic',
                    'test-type'                                          => nil,
                    'use-mock-keychain'                                  => nil
                  }.freeze

def fetch_body(test_url)
  browser = Ferrum::Browser.new(browser_options: BROWSER_OPTIONS)
  browser.go_to(test_url)
  filename = URI.parse(test_url).hostname.gsub('.', '_')
  path     = File.expand_path("../..", __FILE__)
  browser.network.wait_for_idle
  browser.evaluate <<~JS
    window.scrollTo({ top: document.documentElement.scrollHeight });
  JS
  browser.screenshot(full: true, path: "#{path}/screenshots/#{filename}.png")
  body = browser.page.body.to_s
  browser.quit
  body
end

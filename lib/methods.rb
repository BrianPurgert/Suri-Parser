def fetch_body(test_url)
	browser_options = {
	  'no-sandbox' => nil,
	  'allow-running-insecure-content' => nil,
	  'autoplay-policy' => 'user-gesture-required',
	  'disable-add-to-shelf' => nil,
	  'disable-background-networking' => nil,
	  'disable-background-timer-throttling' => nil,
	  'disable-backgrounding-occluded-windows' => nil,
	  'disable-breakpad' => nil,
	  'disable-checker-imaging' => nil,
	  'disable-client-side-phishing-detection' => nil,
	  'disable-component-extensions-with-background-pages' => nil,
	  'disable-datasaver-prompt' => nil,
	  'disable-default-apps' => nil,
	  'disable-desktop-notifications' => nil,
	  'disable-dev-shm-usage' => nil,
	  'disable-domain-reliability' => nil,
	  'disable-extensions' => nil,
	  'disable-features' => 'TranslateUI,BlinkGenPropertyTrees',
	  'disable-hang-monitor' => nil,
	  'disable-infobars' => nil,
	  'disable-ipc-flooding-protection' => nil,
	  'disable-notifications' => nil,
	  'disable-popup-blocking' => nil,
	  'disable-prompt-on-repost' => nil,
	  'disable-renderer-backgrounding' => nil,
	  'disable-setuid-sandbox' => nil,
	  'disable-site-isolation-trials' => nil,
	  'disable-sync' => nil,
	  'disable-web-security' => nil,
	  'enable-automation' => nil,
	  'force-color-profile' => 'srgb',
	  'force-device-scale-factor' => '1',
	  'ignore-certificate-errors' => nil,
	  'js-flags' => '--random-seed=1157259157',
	  'disable-logging' => nil,
	  'metrics-recording-only' => nil,
	  'mute-audio' => nil,
	  'no-default-browser-check' => nil,
	  'no-first-run' => nil,
	  'password-store' => 'basic',
	  'test-type' => nil,
	  'use-mock-keychain' => nil
	}

	browser = Ferrum::Browser.new(browser_options: browser_options)
	browser.go_to(test_url)
	body = browser.page.body.to_s
	browser.quit
	body
end
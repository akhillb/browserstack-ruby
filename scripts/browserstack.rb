require 'yaml'
require 'rspec'
require 'selenium-webdriver'
require 'browserstack/local'

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'single'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../config/#{CONFIG_NAME}.config.yml")))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || CONFIG['key']


RSpec.configure do |config|
  config.around(:example) do |example|
    @options = Selenium::WebDriver::Options.send "chrome"
    @options.browser_name = CONFIG['browser_caps'][TASK_ID]['browser'].downcase
    @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
    enable_local = @caps["browserstack.local"] && @caps["browserstack.local"].to_s == "true"
    @caps['source']= 'rspec:sample-master:v1.1'
    @caps['build'] = ENV['BROWSERSTACK_BUILD_NAME'] unless ENV['BROWSERSTACK_BUILD_NAME'].nil?
    @caps['name'] = ENV['BROWSERSTACK_PROJECT_NAME'] unless ENV['BROWSERSTACK_PROJECT_NAME'].nil?

    # Code to start browserstack local before start of test
    if enable_local
      @bs_local = BrowserStack::Local.new
      bs_local_args = { "key" => CONFIG['key'], "forcelocal" => true }
      @bs_local.start(bs_local_args)
      @caps["local"] = true
    end

    @options.add_option('bstack:options', @caps)

    @driver = Selenium::WebDriver.for(:remote,
      :url => "https://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
      :capabilities => @options)

    begin
      example.run
    ensure 
      @driver.quit
      # Code to stop browserstack local after end of test
      @bs_local.stop if enable_local
    end
  end
end

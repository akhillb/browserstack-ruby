require 'rubygems'
require 'selenium-webdriver'
USER_NAME = ENV['BROWSERSTACK_USERNAME']
ACCESS_KEY = ENV['BROWSERSTACK_ACCESS_KEY']
def run_session(bstack_options)
 options = Selenium::WebDriver::Options.send "chrome"
 options.browser_name = bstack_options["browserName"].downcase
 options.add_option('bstack:options', bstack_options)
 driver = Selenium::WebDriver.for(:remote,
   :url => "https://#{USER_NAME}:#{ACCESS_KEY}@hub.browserstack.com/wd/hub",
   :capabilities => options)
 begin
   # opening the bstackdemo.com website
   driver.navigate.to "https://bstackdemo.com"
   wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
   wait.until { !driver.title.match(/StackDemo/i).nil? }
   # getting name of the product available on the webpage
   product = driver.find_element(:xpath, '//*[@id="1"]/p')
   wait.until { product.displayed? }
   product_text = product.text
   # waiting until the Add to Cart button is displayed on webpage and then clicking it
   cart_btn = driver.find_element(:xpath, '//*[@id="1"]/div[4]')
   wait.until { cart_btn.displayed? }
   cart_btn.click
   # waiting until the Cart pane appears
   wait.until { driver.find_element(:xpath, '//*[@id="__next"]/div/div/div[2]/div[2]/div[2]/div/div[3]/p[1]').displayed? }
   # getting name of the product in the cart
   product_in_cart = driver.find_element(:xpath, '//*[@id="__next"]/div/div/div[2]/div[2]/div[2]/div/div[3]/p[1]')
   wait.until { product_in_cart.displayed? }
   product_in_cart_text = product_in_cart.text
   # checking if the product has been added to the cart
   if product_text.eql? product_in_cart_text
       # marking test as 'passed' if the product is successfully added to the cart
       driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "Product has been successfully added to the cart!"}}')
   else
       # marking test as 'failed' if the product is not added to the cart
       driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Failed to add product to the cart"}}')
   end
 # marking test as 'failed' if test script is unable to open the bstackdemo.com website
 rescue
     driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Some elements failed to load"}}')
 end
 driver.quit
end
caps = [{
 "os" => "Windows",
 "osVersion" => "10",
 "browserName" => "Chrome",
 "browserVersion" => "120.0",
 "build" => ENV['BROWSERSTACK_BUILD_NAME'],
 "name" => ENV['BROWSERSTACK_PROJECT_NAME'],
 "sessionName" => "Github Actions Ruby thread 1"
},
{
 "os" => "OS X",
 "osVersion" => "Monterey",
 "browserName" => "Safari",
 "browserVersion" => "15.6",
 "build" => ENV['BROWSERSTACK_BUILD_NAME'],
 "name" => ENV['BROWSERSTACK_PROJECT_NAME'],
 "sessionName" => "Github Actions Ruby thread 2"
},
{
 "deviceName" => "iPhone 13",
 "osVersion" => "15",
 "browserName" => "Chromium",
 "deviceOrientation" => "portrait",
 "build" => ENV['BROWSERSTACK_BUILD_NAME'],
 "name" => ENV['BROWSERSTACK_PROJECT_NAME'],
 "sessionName" => "Github Actions Ruby thread 3"
}]

t1 = Thread.new{ run_session(caps[0]) }
t2 = Thread.new{ run_session(caps[1]) }
t3 = Thread.new{ run_session(caps[2]) }
t1.join()
t2.join()
t3.join()

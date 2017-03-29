$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rein"
require "yaml"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on a
    # real object. This is generally recommended, and will default to `true` in
    # RSpec 4.
    mocks.verify_partial_doubles = false
  end

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!
end

def test_db_connection(conf)
  ActiveRecord::Base.establish_connection(conf)
  ActiveRecord::Base.connection
end

def test_db_configuration(database)
  y = YAML.safe_load(File.open(File.join(File.expand_path(File.dirname(__FILE__)), "config", "database.yml")))
  y[database]
rescue Errno::ENOENT
  nil
end

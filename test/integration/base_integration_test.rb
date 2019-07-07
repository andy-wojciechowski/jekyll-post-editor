require 'test_helper'
require 'mocha/setup'

##
# The base class for all integration tests. Which includes operations common to all integration tests.
class BaseIntegrationTest < ActionDispatch::IntegrationTest
  protected
    def setup_session(access_token, is_valid_token)
      session = { access_token: access_token }
      PostController.any_instance.expects(:session).at_least_once.returns(session)
      GithubService.expects(:check_access_token).with(access_token).returns(is_valid_token)
    end
end
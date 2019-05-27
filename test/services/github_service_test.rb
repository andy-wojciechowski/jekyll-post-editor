require 'test_helper'
require 'mocha/setup'
require 'octokit'

class GithubServiceTest < ActiveSupport::TestCase
  test 'authenticate should return :unauthorized on failed authentication' do 
    #Arrange
    Octokit::Client.any_instance.expects(:user).raises(Octokit::Unauthorized)

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal :unauthorized, result
  end
  
  test 'authenticate should return :not_in_organization on failed authentication' do 
    #Arrange
    user = DummyApiResource.new
    user.login = 'test'

    Octokit::Client.any_instance.expects(:user).returns(user)
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'test').returns(false)

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal :not_in_organization, result
  end

  test 'authenticate should return a oauth access token on successful authentication' do
    #Arrange
    user = DummyApiResource.new
    user.login = 'test'

    Octokit::Client.any_instance.expects(:user).returns(user)
    Octokit::Client.any_instance.expects(:organization_member?).with('msoe-sse', 'test').returns(true)
    Octokit::Client.any_instance.expects(:create_authorizaion).returns('access token')

    #Act
    result = GithubService.authenticate('test', 'test')

    #Assert
    assert_equal 'access token', result
  end

  class DummyApiResource
    attr_accessor :login
  end
end
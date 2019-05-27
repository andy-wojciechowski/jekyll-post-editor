require 'test_helper'
require 'mocha/setup'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index successfully' do 
    #Act
    get '/home/index'

    #Assert
    assert_response :success
  end

  test 'should get index with root url successfully' do
    #Act
    get '/'

    #Assert
    assert_response :success
  end

  test 'should redirect back to index with failed credentials' do
    #Arrange
    GithubService.expects(:authenticate).with('test', 'test').returns(:unauthorized)

    #Act
    post '/home/login', params: { username: 'test', login: { password: 'test' }}

    #Assert
    assert_redirected_to '/'
    assert_equal 'Invalid GitHub username or password', flash[:alert]
  end

  test 'should redirect back to index if not apart of the msoe-sse github orginization' do
    #Arrange
    GithubService.expects(:authenticate).with('test', 'test').returns(:not_in_organization)

    #Act
    post '/home/login', params: { username: 'test', login: { password: 'test' }}
    
    #Assert
    assert_redirected_to '/'
    assert_equal 'The GitHub user provided is not apart of the msoe-sse GitHub orginization. Please contact the SSE Webmaster for assistance.', flash[:alert]
  end

  test 'should redirect to the post list view on successful authentication' do
    #Arrange
    GithubService.expects(:authenticate).with('test', 'test').returns('Some Response')

    #Act
    post '/home/login', params: { username: 'test', login: { password: 'test' }}

    #Assert
    assert_redirected_to :controller => 'post', :action => 'list'
  end
end
class PostControllerTest < BaseIntegrationTest
  test 'an authenticated user should be able to navigate to post/list successfully' do 
    # Arrange
    setup_session('access token', true)
    PostImageManager.instance.expects(:clear).once
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    post1 = create_post_model(title: 'title1', author: 'author1', hero: 'hero1', 
                              overlay: 'overlay1', contents: 'contents1', tags: ['tag1', 'tag2'])
    post2 = create_post_model(title: 'title2', author: 'author2', hero: 'hero2', 
                              overlay: 'overlay2', contents: 'contents2', tags: ['tag1', 'tag2'])
    pr_post = create_post_model(title: 'pr post', author: 'pr author', hero: 'pr hero',
                                overlay: 'pr overlay', contents: 'pr contents', tags: ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with('access token').returns([post1, post2])
    GithubService.expects(:get_all_posts_in_pr_for_user).with('access token').returns([pr_post])

    # Act
    get '/post/list'

    # Assert
    assert_response :success
  end

  test 'an authenticated user should be able to navigate to / successfully' do 
    # Arrange
    setup_session('access token', true)
    PostImageManager.instance.expects(:clear).once
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    post1 = create_post_model(title: 'title1', author: 'author1', hero: 'hero1', 
                              overlay: 'overlay1', contents: 'contents1', tags: ['tag1', 'tag2'])
    post2 = create_post_model(title: 'title2', author: 'author2', hero: 'hero2', 
                              overlay: 'overlay2', contents: 'contents2', tags: ['tag1', 'tag2'])
    pr_post = create_post_model(title: 'pr post', author: 'pr author', hero: 'pr hero',
                                overlay: 'pr overlay', contents: 'pr contents', tags: ['tag1', 'tag2'])
    GithubService.expects(:get_all_posts).with('access token').returns([post1, post2])
    GithubService.expects(:get_all_posts_in_pr_for_user).with('access token').returns([pr_post])

    # Act
    get '/'

    # Assert
    assert_response :success
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to post/list' do
    # Arrange
    auth_url = 'https://github.com/login/oauth/authorize?client_id=github client id&scope=public_repo+read%3Aorg'

    # Act
    get '/post/list'

    # Assert
    assert_redirected_to auth_url
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to /' do
    # Arrange
    auth_url = 'https://github.com/login/oauth/authorize?client_id=github client id&scope=public_repo+read%3Aorg'

    # Act
    get '/'

    # Assert
    assert_redirected_to auth_url
  end

  test 'an authenticated user should be able to navigate to post/edit successfully' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    # Act
    get '/post/edit'

    # Assert
    assert_response :success
  end

  test 'an authenticated user should be redirected to /GitHubOrgerror.html when navigating to post/eidt' do
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(false)
    
    # Act
    get '/post/edit'
    
    # Assert
    assert_redirected_to '/GitHubOrgError.html'
  end

  test 'an unauthenticated user should be redirected to GitHub when navigating to post/edit' do
    # Arrange
    auth_url = 'https://github.com/login/oauth/authorize?client_id=github client id&scope=public_repo+read%3Aorg'
    GithubService.expects(:check_sse_github_org_membership).never

    # Act
    get '/post/edit'

    # Assert
    assert_redirected_to  auth_url
  end

  test 'an authenticated user with an expired token should be redirected to GitHub when navigating to post/edit' do 
    # Arrange
    setup_session('access token', false)
    auth_url = 'https://github.com/login/oauth/authorize?client_id=github client id&scope=public_repo+read%3Aorg'
    GithubService.expects(:check_sse_github_org_membership).never

    # Act
    get '/post/edit'

    # Assert
    assert_redirected_to auth_url
  end

  test 'an authenticated user should be able to navigate to post/edit successfully with a title parameter' do
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    post = create_post_model(title: 'title', author: 'author', hero: 'hero', 
                              overlay: 'overlay', contents: 'contents',  tags: ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with('access token', 'title', nil).returns(post)

    # Act
    get '/post/edit?title=title'

    # Assert
    assert_response :success
  end

  test 'an authenticated user should be able to navigate to post/edit successfully with a title and ref parameter' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    post = create_post_model(title: 'title', author: 'author', hero: 'hero', 
                              overlay: 'overlay', contents: 'contents',  tags: ['tag1', 'tag2'])
    GithubService.expects(:get_post_by_title).with('access token', 'title', 'ref').returns(post)

    # Act
    get '/post/edit?title=title&ref=ref'

    # ASsert
  end

  test 'post/edit should create a post from the session if session[:post_stored] is true' do 
    # Arrange
    session = { access_token: 'access token', post_stored: true, author: 'Andy', title: 'My Post', 
                contents: '# hello', tags: 'Tag', overlay: 'red' }
    PostController.any_instance.expects(:session).at_least_once.returns(session)
    GithubService.expects(:check_access_token).with('access token').returns(true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    # Act
    get '/post/edit'

    # Assert
    assert_response :success
  end

  test 'post/preview should return a successful response' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    # Act
    get '/post/preview?text=#hello'

    # Assert
    assert_response :success
  end

  test 'post/submit should redirect back to the edit screen 
        with an error message if a post was submited without a title' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:submit_post).never
    KramdownService.expects(:create_jekyll_post_text).never

    # Act
    post '/post/submit', params: { title: '', author: 'author', 
                                   markdownArea: '# hello', tags: '', overlay: 'red' }

    # Assert
    assert_redirected_to '/post/edit'
    assert_equal 'A post cannot be submited with a blank title.', flash[:alert]
    assert_nil flash[:notice]
  end

  test 'post/submit should redirect back to the edit screen 
        with an error message if a post was submited without a author' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:submit_post).never
    KramdownService.expects(:create_jekyll_post_text).never
    
    # Act
    post '/post/submit', params: { title: 'title', author: '', 
                                   markdownArea: '# hello', tags: '', overlay: 'red' }
    
    # Assert
    assert_redirected_to '/post/edit'
    assert_equal 'A post cannot be submited without an author.', flash[:alert]
    assert_nil flash[:notice]
  end

  test 'post/submit should redirect back to the edit screen 
        with an error message if a post was submited without markdown' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:submit_post).never
    KramdownService.expects(:create_jekyll_post_text).never
        
    # Act
    post '/post/submit', params: { title: 'title', author: 'author', 
                                   markdownArea: '', tags: '', overlay: 'red' }
        
    # Assert
    assert_redirected_to '/post/edit'
    assert_equal 'A post cannot be submited with no markdown content.', flash[:alert]
    assert_nil flash[:notice]
  end

  test 'post/submit should redirect back to the edit screen with an
   error message if a post has a hero thats not an image.' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:submit_post).never
    KramdownService.expects(:create_jekyll_post_text).never
        
    # Act
    post '/post/submit', params: { title: 'title', author: 'author', 
                                   markdownArea: '# bonk', tags: '',
                                    overlay: 'red', hero: 'https://github.com/msoe-sse/msoe-sse.github.io' }
        
    # Assert
    assert_redirected_to '/post/edit'
    assert_equal 'The background image url must be an image.', flash[:alert]
    assert_nil flash[:notice]
  end

  test 'post/submit should redirect back to the edit screen with an
        error message if a post has a hero thats not a valid url.' do 
   # Arrange
   setup_session('access token', true)
   GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

   PostService.expects(:submit_post).never
   KramdownService.expects(:create_jekyll_post_text).never
       
   # Act
   post '/post/submit', params: { title: 'title', author: 'author', 
                                  markdownArea: '# bonk', tags: '',
                                   overlay: 'red', hero: 'bonk' }
       
   # Assert
   assert_redirected_to '/post/edit'
   assert_equal 'The background image must be a valid URL.', flash[:alert]
   assert_nil flash[:notice]
 end
  

  test 'post/submit should submit the new post to GitHub and redirect back to the list screen with a valid post' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:create_post).with('access token', 'post text', 'title').once
    PostService.expects(:is_valid_hero).with('https://source.unsplash.com/collection/145103/').returns(true)
    KramdownService.expects(:create_jekyll_post_text)
                   .with('# hello', 'author', 'title', 'tags', 'red',
                    'https://source.unsplash.com/collection/145103/').returns('post text')
            
    # Act
    post '/post/submit', params: { title: 'title', author: 'author', 
                                   markdownArea: '# hello', tags: 'tags', overlay: 'red',
                                    hero: 'https://source.unsplash.com/collection/145103/' }
            
    # Assert
    assert_redirected_to '/post/list'
    assert_nil flash[:alert]
    assert_equal 'Post Successfully Submited', flash[:notice]
  end

  test 'post/submit?path should submit the existing post to GitHub 
        and redirect back to the list screen with a valid post' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:edit_post).with('access token', 'post text', 'title', 'path.md').once
    KramdownService.expects(:create_jekyll_post_text)
                   .with('# hello', 'author', 'title', 'tags', 'red', '').returns('post text')

    # Act
    post '/post/submit?path=path.md', params: { title: 'title', author: 'author', 
                                                markdownArea: '# hello', tags: 'tags', overlay: 'red', hero: '' }

    # Assert
    assert_redirected_to '/post/list'
    assert_nil flash[:alert]
    assert_equal 'Post Successfully Submited', flash[:notice]
  end

  test 'post/submit?path&ref should submit the existing post to GitHub
        and redirect back to the list screen with a valid post' do 
    # Arrange
    setup_session('access token', true)
    GithubService.expects(:check_sse_github_org_membership).with('access token').returns(true)

    PostService.expects(:edit_post_in_pr).with('access token', 'post text', 'title', 'path.md', 'ref').once
    KramdownService.expects(:create_jekyll_post_text)
                   .with('# hello', 'author', 'title', 'tags', 'red', '').returns('post text')

    # Act
    post '/post/submit?path=path.md&ref=ref', params: { title: 'title', author: 'author', 
                                                        markdownArea: '# hello', tags: 'tags', 
                                                        overlay: 'red', hero: '' }
    
    # Assert
    assert_redirected_to '/post/list'
    assert_nil flash[:alert]
    assert_equal 'Post Successfully Submited', flash[:notice]
  end

  private
    def create_post_model(parameters)
      post_model = Post.new
      post_model.title = parameters[:title]
      post_model.author = parameters[:author]
      post_model.hero = parameters[:hero]
      post_model.overlay = parameters[:overlay]
      post_model.contents = parameters[:contents]
      post_model.tags = parameters[:tags]
      post_model
    end
end

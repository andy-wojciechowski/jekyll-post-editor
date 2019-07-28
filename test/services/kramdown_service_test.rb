require 'test_helper'
require 'mocha/setup'

class KramdownServiceTest < ActiveSupport::TestCase
  LEAD_BREAK_SECTION = "{: .lead}\r\n<!–-break-–>"

  test 'get_preview should convert markdown to html' do
    # Arrange
    markdown = %(#Andy is cool
Andy is nice)

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_not_nil result
  end
  
  test 'get_preview should not update the src atribute of image tags if no uploader exists in PostImageManager' do 
    # Arrange
    mock_uploader = create_mock_uploader('preview_no image.png', 'my cache', nil)
    preview_uploader = create_preview_uploader('no image.png', mock_uploader)

    PostImageManager.instance.expects(:uploaders).returns([ preview_uploader ])

    markdown = '![20170610130401_1.jpg](/assets/img/20170610130401_1.jpg)'

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_equal "<p><img src=\"/assets/img/20170610130401_1.jpg\" alt=\"20170610130401_1.jpg\" /></p>\n", result
  end

  test 'get_preview should update the src attribute of image tags if an uploader exists in PostImageManager' do 
    # Arrange
    mock_uploader = create_mock_uploader('preview_20170610130401_1.jpg', 'my cache/preview_20170610130401_1.jpg', nil)
    preview_uploader = create_preview_uploader('20170610130401_1.jpg', mock_uploader)

    PostImageManager.instance.expects(:uploaders).returns([ preview_uploader ])

    markdown = '![My Alt Text](/assets/img/20170610130401_1.jpg)'
    expected_html = "<p><img src=\"/uploads/tmp/my cache/preview_20170610130401_1.jpg\" alt=\"My Alt Text\" /></p>\n"

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_equal expected_html, result
  end

  test 'does_markdown_include_image should return false if the markdown doesnt 
        include an image with a given filename' do 
    # Arrange
    markdown = '![My Alt Text](/assets/img/20170610130401_1.jpg)'

    # Act
    result = KramdownService.does_markdown_include_image('my file.jpg', markdown)

    # Assert
    assert_not result
  end

  test 'does_markdown_include_image should return true if the markdown does include an image with a given filename' do 
    # Arrange
    markdown = '![My Alt Text](/assets/img/20170610130401_1.jpg)'

    # Act
    result = KramdownService.does_markdown_include_image('20170610130401_1.jpg', markdown)

    # Assert
    assert result
  end

  test 'create_jekyll_post_text should return text for a formatted post' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)

    # Act
    result = KramdownService.create_jekyll_post_text("#An H1 tag\r\n##An H2 tag", 'Andy Wojciechowski', 
                                                     'Some Post', '', 'Green')

    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should return a formatted post given valid post tags' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
tags:
  - announcement\r
  - info\r
  - hack n tell\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)
    # Act
    result = KramdownService.create_jekyll_post_text("#An H1 tag\r\n##An H2 tag",
                                                     'Andy Wojciechowski', 
                                                     'Some Post', 
                                                     'announcement, info,    hack n tell     ', 
                                                     'green')
    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should add a space after the # symbols indicating a header tag' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# H1 header\r
\r
## H2 header\r
\r
### H3 header\r
\r
#### H4 header\r
\r
##### H5 header\r
\r
###### H6 header)

    markdown_text = %(#H1 header\r
\r
##H2 header\r
\r
###H3 header\r
\r
####H4 header\r
\r
#####H5 header\r
\r
######H6 header)

    # Act
    result = KramdownService.create_jekyll_post_text(markdown_text, 'Andy Wojciechowski', 'Some Post', '', 'Green')

    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should only add one space after a header' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
tags:
  - announcement\r
  - info\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)
    # Act
    result = KramdownService.create_jekyll_post_text("# An H1 tag\r\n##An H2 tag",
                                                     'Andy Wojciechowski', 'Some Post', 'announcement, info', 'green')
    # Assert
    assert_equal expected_post, result
  end
end

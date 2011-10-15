=begin

My personal rules are:

  - Name categories with a plural.

  - Make tags with for both the singular and plural forms of a word, if possible.

  - Thumbnails do not have borders.  I will implement this with code.

  - Screenshots will be displayed in alpha-numeric order.

  - I have a verbose coding style, with lots of extra spaces, for improved readability.

  - Two-space tabs

---

Program changes:

  FIXME  Wasn't escape supposed to bring the user back to the main list?

  TODO  Why not keep the search bar when viewing the program's source?

  TODO  screenshotting support
          http://www.mail-archive.com/shoes@code.whytheluckystiff.net/msg02781.html

          If you are using Shoes 3 for Windows, try out the following.
          Red Shoes will save a snapshot into drawing.pdf file.

          Shoes.app do
            flag = nil
            motion do |x, y|
              b, x, y = mouse
              line @x, @y, x, y if b == 1
              @x, @y = x, y
            end
            button 'Take a snapshot' do
              _snapshot filename: './drawing.pdf', format: :pdf
            end
          end

          But this _snapshot() method is a trial. It's not always work good and doesn't
          work on other platforms so far, neither on Green Shoes. 

  TODO  Build categories into 'github:pages' - http://pages.github.com/

  TODO  Is there a simple 'reset' command, so I don't have to remember/execute a list of @object.remove ?

  TODO  When searching for tags, merge duplicate entries together

  TODO  When searching for tags, display the full keyword just like now, but bold the part of the keyword which is matched.

  TODO  Implement regular expressions in the search field?

  TODO  Don't ever remove what was typed in the search field.
          So when viewing a program, and the user goes back.. it returns to the previous state exactly.

  TODO  Media gallery.  (texts, images, videos)

  TODO  Be able to search within content.

  TODO  Be able to search by name.

  TODO  Complex searches of multiple mixed types.  tag: foo, content: bar, name: baz

  FIXME  When I scroll down the categories list, pick something, scroll down, view something, I am pre-scrolled-down in the view of the program's code  Hrmph.  Maybe I have to spawn a new window and then kill the previous one.

  TODO  When browsing:  main -> a category -> an item, ..  the 'back' should go back to the category view.  Right now it goes back to main.  That's too far.

  TODO  :margin_bottom => 5 on all the relevant stuff.

  TODO  hotkeys: Pageup/pagedown and space.

  TODO  Implement green shoes functionality.
      - Test browser.rb under green shoes.  If necessary, maintain two code bases for it.
      - Create a separate tag for every program to flag it for whatever types of shoes it can be run under.
      - Absorb the samples from https://github.com/ashbb/green_shoes/tree/master/samples, learning what changes were made.
      - Create a red-to-green shoes tutorial, highlighting differences.  There are a lot of changes, and I don't think the authors really know them all.  =)

---

Other projects to absorb (once this one can properly support all the necessary functionality):

  http://spiralofhope.com/shoes-tutorial.html
  
  http://shoesrb.com/tutorials
  
  http://shoesrb.com/manual/Hello.html
  
  https://github.com/shoes/shoes/tree/develop/samples
  
  http://the-shoebox.org
  
    Steve Klabnik is working on transferring the shoebox into his control.  Licensing for individual programs was never determined.  The website itself is MIT/BSD/Ruby licensed.
  
  http://shoes-tutorial-note.heroku.com
  
    forked: https://github.com/spiralofhope/shoes_tutorial_html

---

Problems with programs:

  TODO  pulsate.rb
          References an image that doesn't exist.
  TODO  download-and-save.rb
          References an image that should be locally cached and another that doesn't exist.
  TODO  class-book.rb
          Doesn't run.
  TODO  url-shoes-subclassing.rb
          Doesn't run.
  TODO  image-icon.rb
          References an image which should be locally cached.
  TODO  funnies.rb
          Doesn't work.  It's probably referencing online data which doesn't exist.
  TODO  debug.rb
          Doesn't work.
  TODO  bounce.rb
          References images which don't exist.
  TODO  form.rb
          References images which don't exist.
  TODO  video.rb
          Doesn't work.  It's probably referencing online data which doesn't exist.

  Tag all programs with 'unreviewed' and then remove the tag after reviewing each one.  Each program can be edited one-by-one from within the browser itself, by searching for the unreviewed tag.

    - Example / tutorial programs program should showcase only *one* feature and very clearly indicate it.  No other distracting features or functionality should exist!

    - Push toward SSCCEs - http://sscce.org

=end

# FIXME:  There are a bunch of solutions for this, but I didn't want to deal with any of it.  Consider investigating something philosophically superior.
$LOAD_PATH << File.join( File.dirname( __FILE__ ), 'lib' )
require 'lib-browser.rb'

#
# 0 - The list of categories.
# @content
# @search
# @search_button
def main()
  #
  def view_search( string )
    @content.clear
    # A basic limitation since a one or two-character search is too aggressive and not actually useful.
    return '' if string.length < 3
    view_search_hash = Hash.new
    @@tags_hash.each_key{ |k|
      view_search_hash["#{ k }"] = Array.new
      @@tags_hash[k].each{ |v|
        view_search_hash["#{ k }"] << v if /#{ string }/ =~ v
      }
    }
    view_search_hash.delete_if{ |k,v|
      view_search_hash[k] == []
    }
    view_search_hash.each_key{ |k|
      s = ''
      view_search_hash[k].each{ |v|
        s << v
      }
      view_program_summary( k, s )
    }
  end # view_search( string )
  #
  # TODO:  Can I  have the cursor automatically placed in the edit_line when the program launches?  Maybe toss a tab character at the keyboard?
  # @self.width doesn't understand a scroll bar!  TODO:  How can I know if a scroll bar is being painted or not?  How do I know the size of a scroll bar?
  @search = (
      # How can I have edit_line understand the proposed width of the button and adjust accordingly?
      edit_line( :width => self.width - 66, :margin_left => 10, :margin_top => 5 )
  )
  @search_button = (
    button( 'x', :margin_top => 5 ){ @search.text = '' }
  )
  #
  @content = flow{}
  view_categories_list()
  @search.change do |s|
    if s.text.empty?
      #view_all()
      view_categories_list()
    else
      view_search( s.text )
    end
  end
  #
end # main()

def view_program_summary( directory, *splat )
  if splat != [] then
    tags = splat[0]
    tags = " (#{ tags.to_s })"
    tags = '' if directory == splat[0]
  end
  @content.append do
    flow( :margin_top => 10 ) do
      background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
      stack( width: 155 ) do
        #para  # Blank line above the thumbnail.
        program_thumbnail( directory )
      end
      # Increasing this width provides a right margin for the description.
      flow( width: width-176 ) do
        para( link( directory ){ view_a_program( directory ) }, tags, "\n" )
        # TODO:  How would I have these buttons be on the same line as the program name (the line above this one) but be right-aligned?
        button( "Run" ) do
          program_run( directory )
        end
        #para( ' ' )
        button( "Edit", :margin_left => 5 ) do
          editor(
                  File.join( directory, directory + '.rb' )
                )
        end
        stack do
          para( program_description( directory ) )
        end
      end
    end
  end
end # view_program_summary( directory, *splat )

#
# 1 - This is the first thing that the user sees.
# @category
# @content
def view_categories_list()

  # See also rebuild_readme()
  def view_category_summary( category_name )
    #
    # This is largely cloned from program_thumbnail()
    def catgegory_thumbnail( category_name )
      dir = File.join( '..', 'categories' )
      i = File.join( '..', 'categories', 'default-thumbnail.png' )
      f = File.join( dir, "#{ category_name }.png" )
      i = f if File.exists?( f )
      f = File.join( dir, "#{ category_name }.jpg" )
      i = f if File.exists?( f )
      image(
        i,
        width: 150,
        height: 150,
        :margin_left => 10,
        :margin_bottom => 5,
        :margin_top => 5
      ).click{ view_a_category( category_name ) }
    end # catgegory_thumbnail( category_name )
    #
    @category = ''
    @content.append do
      flow( :margin_top => 10 ) do
        background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
        stack( width: 155 ) do
          #para  # Blank line above the thumbnail.
          catgegory_thumbnail( category_name )
        end
        flow( width: width-155 ) do
          para( link( category_name ){ view_a_category( category_name ) } )
          para( "\n" )
          para( category_description( category_name ) )
        end
      end
    end
  end # view_category_summary( category_name, *splat )

  @content.clear
  @content.append do
    flow( :margin_left => 10 ){
      para( 'Categories List > ' )
    }
  end
  @@categories_array.each{ |c|
    view_category_summary( c )
  }
end # view_categories_list()

def program_thumbnail( directory )
  # TODO:  This is a cumbersome way to do this.
  # TODO:  What image file types does Shoes support?
  # FIXME/TODO:  How would I get an animated image to appear?  I don't even know how to properly take those.  Do I have to manually animate the image by swapping out multiple images?  Eww!
  i = File.join( 'default-thumbnail.png' )
  f = File.join( directory, "thumbnail.png" )
  i = f if File.exists?( f )
  f = File.join( directory, "thumbnail.jpg" )
  i = f if File.exists?( f )
  # If the default thumbnail doesn't actually exist, then this would gracefully default to painting an empty space of the appropriate size (150 x 150px, margins, etc).
  image(
    i,
    width: 150,
    height: 150,
    :margin_left => 10,
    :margin_bottom => 5,
    :margin_top => 5
  ).click{ view_a_program( directory ) }
end # program_thumbnail( directory )

def program_run( directory )
  eval( File.open( File.join( directory, "#{ directory }.rb" ) ).read, TOPLEVEL_BINDING )
end # program_run( directory )

#
# 2 - Clicking on a category
def view_a_category( category_name )
  @content.clear
  @content.append do
    flow( :margin_left => 10 ){
      para(
        link( 'Categories List' ){ back_to_main() },
        ' > View a Category > ',
        strong( " #{ category_name }" )
      )
    }
  end
  # display all programs of category c
  @@categories_hash.each_key{ |k|
    @@categories_hash[k].each{ |v|
      if /#{ category_name }/ =~ v
        view_program_summary( k )
      end
    }
  }
end # view_a_category( category_name )

def back_to_main()
  @content.remove
  @search.remove
  @search_button.remove
  main()
end # back_to_main()

#
# 3 - Clicking on a program
def view_a_program( directory )
  @search.remove
  @search_button.remove
  @content.remove
  @content = stack{
   flow( :margin_left => 10 ){
      para(
        link( 'Categories List' ){ back_to_main() },
        ' > View a Program > ',
        strong( " #{ directory }" )
      )
    }
  }
  # Appends the program summary.
  view_program_summary( directory )
  @content.append{
    stack( :margin_left => 10, :margin_top => 5, :margin_right => 20, :margin_top => 5 ){
      para( program_contents( directory ) )
    }
  }
end # view_a_program( directory )

# TODO:  Syntax highlighting.  Somehow.
def program_contents( program_directory )
  # Just grabbing the first file for now..
  file = Dir.glob( File.join( program_directory, '*.rb' ) )[0]
  if file == [] or ! File.exists?( file ) then
    return ''
  end
  f = File.open( file, 'r' )
    string = f.read
  f.close
  return string
end # program_contents( program_directory )

Shoes.app(
            :title => "Program Browser",
            :width => 640,
            :height => 460,
            :resizeable => true
          ) do
  #alert "This is a pre-release version.\n\nThere are known bugs and a large to do list.  Read the code for details."
  background( darkgray )
  rebuild()
  rebuild_readme()
  main()
  keypress do |key|
    p key
    #
    # The main page
    #
    # Since @search may be removed
    if @search.inspect != nil then
      if key.inspect == ':escape' then
        @search.text = ''
      end
    end
    #
    # Category View
    #
    if @category.inspect != nil then
      if key.inspect == ':backspace' then
        back_to_main()
      end
    end
    #
    # Everywhere
    #
    exit if key.inspect == ':control_q' and confirm( "Quit?" )
  end
end # Shoes.app( ...

=begin
My personal rules are:
- Name categories with a plural.
- Make tags with for both the singular and plural forms of a word, if possible.
- Thumbnails do not have borders.  I will implement this with code.
- Screenshots will be displayed in alpha-numeric order.

# Build categories into github:pages - http://pages.github.com/
# TODO:  Is there a simple 'reset' command, so I don't have to remember/execute a list of @object.remove ?
# TODO:  When searching for tags, merge duplicate entries together
# TODO:  When searching for tags, display the full keyword just like now, but bold the part of the keyword which is matched.
# TODO:  Implement regular expressions in the search field?
# TODO:  Don't ever remove what was typed in the search field.  So when viewing a program, and the user goes back.. it returns to the previous state exactly.
# TODO:  Media gallery.  (texts, images, videos)
# TODO:  Be able to search within content.
# TODO:  Be able to search by name.
# TODO:  Complex searches of multiple mixed types.  tag: foo, content: bar, name: baz
# FIXME:  When I scroll down the categories list, pick something, scroll down, view something, I am pre-scrolled-down in the view of the program's code.  Hrmph.  Maybe I have to spawn a new window and then kill the previous one.
# TODO:  When browsing:  main -> a category -> an item, ..  the 'back' should go back to the category view.  Right now it goes back to main.  That's too far.
# TODO:  :margin_bottom => 5 on all the relevant stuff.
# TODO:  hotkeys: Pageup/pagedown and space.
=end

# FIXME:  There are a bunch of solutions for this, but I didn't want to deal with any of it.  Consider investigating something philosophically superior.
$LOAD_PATH << './lib'
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
  #
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
      stack( width: 150 ) do
        #para  # Blank line above the thumbnail.
        program_thumbnail( directory )
      end
      flow( width: width-150 ) do
        para( link( directory ){ view_a_program( directory ) }, tags, "\n" )
        # TODO:  How would I have this text be on the same line as the program name (the line above this one) and be right-aligned?
        button "Run" do
          program_run( directory )
        end
        button "Edit" do
          editor( directory )
        end
        # FIXME:  This text needs a right margin.  I can't find the documentation for that.  (RE-TEST)
        para( program_description( directory ) )
      end
    end
  end
end # view_program_summary( directory, *splat )

#
# 1 - This is the first thing that the user sees.
# @category
# @content
def view_categories_list()

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
        stack( width: 150 ) do
          #para  # Blank line above the thumbnail.
          catgegory_thumbnail( category_name )
        end
        flow( width: width-150 ) do
          para( link( category_name ){ view_a_category( category_name ) } )
        end
      end
    end
  end # view_category_summary( category_name, *splat )

  @content.clear
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
        link( 'Back' ){ back_to_main() },
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

def program_description( program_directory )
  # Just kludging it for now.
  # TODO:  I should use some recognized format for descriptions.  Intelligently parse the file and pull it out.  Maybe even look for a README, file_id.diz, descript.ion or some such?
  # TODO:  Automatically link() hyperlinks.
  # TODO:  Automatically markup text markup.
  # TODO:  If I change the description, then add a button to view the unaltered description.
  return 'aaaaa ' * 20
end # program_description( program_directory )

#
# 3 - Clicking on a program
def view_a_program( directory )
  @search.remove
  @search_button.remove
  @content.remove
  @content = stack{
   flow( :margin_left => 10 ){
      para(
        link( 'Back' ){ back_to_main() },
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

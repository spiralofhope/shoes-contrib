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
=end

# This is a little specific.. needs fallbacks and preferences.
# TODO:  Implement a configuration GUI, and store preferences in a plain text file (that's excluded from github)
def editor( filename )
  filename = File.join( filename, filename + '.rb' )
  system( '/usr/bin/geany', filename )
  rebuild()
end

def get_list( p, rx )
  file = File.join( p, "#{ p }.rb" )
  #
  return [ p ] if ! File.exists?( file )
  #
  f = File.open( file, 'r' )
    file_contents = f.read
  f.close
  file_contents.each_line{ |l|
    if l.match( rx ) != nil then
      tags = l[$~[0].length..-1].lstrip
      tags = tags.split( ',' )
      tags.each_index{ |e|
        tags[e].lstrip!
        tags[e].rstrip!
      }
      tags[-1].chomp!
      return tags
    end
  }
  return [p]
end

def program_tags( p )
  return get_list( p, %r{^(# tags:)}i )
end

def program_categories( p )
  return get_list( p, %r{^(# categories:)}i )
end

def rebuild()
  # This ignores dot directories.
  Dir.chdir( 'programs' )
  @@programs = Dir.glob( '*' )
  @@programs.delete_if { |x| File.ftype( x ) != 'directory' }
  @@programs.sort!

  @@tags_hash = Hash.new
  @@tags_array = Array.new
  @@programs.each{ |p|
    tags = program_tags( p )
    @@tags_hash["#{ p }"] = Array.new
    tags.each{ |k|
      @@tags_hash["#{ p }"] << k
      @@tags_array << k
    }
  }
  @@tags_array.sort!
  @@tags_array.uniq!

  @@categories_hash = Hash.new
  @@categories_array = Array.new
  @@programs.each{ |p|
    categories = program_categories( p )
    @@categories_hash["#{ p }"] = Array.new
    categories.each{ |k|
      @@categories_hash["#{ p }"] << k
      @@categories_array << k if k != p
    }
  }
  @@categories_array.sort!
  @@categories_array.uniq!
  # TODO:  This can probably be built into the initial hash assembly, above.  I'm just not so sure how to do that right now..
  @@categories_hash.delete_if{ |key,value|
    key == value[0]
  }
end

def program_thumbnail( directory )
  # TODO:  This is a cumbersome way to do this.
  # TODO:  What image file types does Shoes support?
  # FIXME/TODO:  How would I get an animated image to appear?  I don't even know how to properly take those.  Do I have to manually animate the image by swapping out multiple images?  Eww!
  i = File.join( '..', 'default-thumbnail.png' )
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
  ).click{ display_program( directory ) }
end

# This is largely cloned from program_thumbnail(), above.
def catgegory_thumbnail( category_name )
  i = File.join( '..', 'default-thumbnail.png' )
  f = File.join( '..', "#{ category_name }.png" )
  i = f if File.exists?( f )
  f = File.join( '..', "#{ category_name }.jpg" )
  i = f if File.exists?( f )
  image(
    i,
    width: 150,
    height: 150,
    :margin_left => 10,
    :margin_bottom => 5,
    :margin_top => 5
  ).click{ display_a_category( category_name ) }
end

def content( directory, *splat )
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
        para( link( directory ){ display_program( directory ) }, tags, "\n" )
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
end

def program_run( directory )
  eval( File.open( File.join( directory, "#{ directory }.rb" ) ).read, TOPLEVEL_BINDING )
end

def display_search( string )
  @content.clear
  # A basic limitation since a one or two-character search is too aggressive and not actually useful.
  return '' if string.length < 3
  display_search_hash = Hash.new
  @@tags_hash.each_key{ |k|
    display_search_hash["#{ k }"] = Array.new
    @@tags_hash[k].each{ |v|
      display_search_hash["#{ k }"] << v if /#{ string }/ =~ v
    }
  }
  display_search_hash.delete_if{ |k,v|
    display_search_hash[k] == []
  }
  display_search_hash.each_key{ |k|
    s = ''
    display_search_hash[k].each{ |v|
      s << v
    }
    content( k, s )
  }
end # display_search( string )

def display_a_category( category_name )
  @content.clear
  @content.append do
    flow( :margin_left => 10 ){
      para(
        back_to_main(),
        strong( " #{ category_name }" )
      )
    }
  end
  # display all programs of category c
  @@categories_hash.each_key{ |k|
    @@categories_hash[k].each{ |v|
      if /#{ category_name }/ =~ v
        content( k )
      end
    }
  }
end # display_a_category( category_name )

def category( category_name )
  @content.append do
    flow( :margin_top => 10 ) do
      background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
      stack( width: 150 ) do
        #para  # Blank line above the thumbnail.
        catgegory_thumbnail( category_name )
      end
      flow( width: width-150 ) do
        para( link( category_name ){ display_a_category( category_name ) } )
      end
    end
  end
end # category( category_name, *splat )

def display_categories_list()
  @content.clear
  @@categories_array.each{ |c|
    category( c )
  }
end # display_categories_list()
#def display_all()
  #@content.clear
  #@@programs.each do |p|
    #content( p )
  #end
#end # display_all()

def main()
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
  #display_all()
  display_categories_list()
  #
  @search.change do |s|
    if s.text.empty?
      #display_all()
      display_categories_list()
    else
      display_search( s.text )
    end
  end
  #
end # main()

def back_to_main()
  link( 'Back' ){
    @content.remove
    @search.remove
    @search_button.remove
    main()
  }
end

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

def program_description( program_directory )
  # Just kludging it for now.
  # TODO:  I should use some recognized format for descriptions.  Intelligently parse the file and pull it out.  Maybe even look for a README, file_id.diz, descript.ion or some such?
  # TODO:  Automatically link() hyperlinks.
  # TODO:  Automatically markup text markup.
  # TODO:  If I change the description, then add a button to view the unaltered description.
  return 'aaaaa ' * 20
end # program_description( program_directory )

def display_program( directory )
  @search.remove
  @search_button.remove
  @content.remove
  @content = stack{
    background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20, :margin_top => 5 )
    stack( :margin_left => 10, :margin_top => 5, :margin_right => 20, :margin_top => 5 ){
      para( back_to_main() )
      title( directory )
      button "Run" do
        program_run( directory )
      end
    }
    stack( :margin_left => 20 ){
    program_thumbnail( directory )
    para( program_contents( directory ) )
    }
  }
end # display_program( directory )

def rebuild_readme()
  filename = File.join( '..', 'README.md.prepend' )
  string = file_read( filename )
  @@categories_array.each{ |e|
    # Header
    a = "\n\n---\n### #{ e }\n"
    # Image
    i = "default-thumbnail.png"
    f = "#{ e }.png"
    i = f if File.exists?( f )
    f = "#{ e }.jpg"
    i = f if File.exists?( f )
    a.concat( "![#{ e }](#{ i })" )
    #
    string.concat( a )
  }
  string.concat( "\n\n" )
  filename = File.join( '..', 'README.md' )
  file_create( filename, string )
end

def file_create(
                  file,
                  file_contents=''
                )
  File.open( file, 'w+' ) { |f| # open file for update
    f.print file_contents       # write out the example description
  }                             # file is automatically closed
end

def file_read( file )
  # I suspect that there are issues reading files with a space in them.  I'm having a hard time tracking it down though.. TODO: I should adjust the test case.
  if ! File.exists?( file ) then
    puts "That file doesn't exist:  '#{ file.inspect }'"
    return
  end
  f = File.open( file, 'r' )
    string = f.read
  f.close
  return string
end

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
    # Everywhere
    #
    exit if key.inspect == ':control_q' and confirm( "Quit?" )
  end
end

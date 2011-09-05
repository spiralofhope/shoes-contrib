=begin
# TODO:  Is there a simple 'reset' command, so I don't have to remember/execute a list of @object.remove ?
# TODO:  When searching for keywords, merge duplicate entries together
# TODO:  When searching for keywords, display the full keyword just like now, but bold the part of the keyword which is matched.
# TODO:  Implement regular expressions in the search field?
# TODO:  Don't ever remove what was typed in the search field.  So when viewing a program, and the user goes back.. it returns to the previous state exactly.
# TODO:  Media gallery.  (texts, images, videos)
=end

# This ignores dot directories.
@@programs = Dir.glob( '*' )
@@programs.delete_if { |x| File.ftype( x ) != 'directory' }
@@programs.sort!

def program_tags( p )
  file = File.join( p, "#{p}.rb" )
  rx = %r{^(# tags:)}i
  #
  return [p] if ! File.exists?( file )
  #
  f = File.open( file, 'r' )
    file_contents = f.read
  f.close
  file_contents.each_line{ |l|
    if l.match( rx ) != nil then
      tags = l[$~[0].length..-1].lstrip
      tags = tags.split(',')
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

@@tags_hash = Hash.new
@@tags_array = Array.new
@@programs.each{ |p|
  keywords = program_tags( p )
  @@tags_hash["#{p}"] = Array.new
  keywords.each{ |k|
    @@tags_hash["#{p}"] << k
    @@tags_array << k
  }
}
@@tags_array.sort!
@@tags_array.uniq!

def thumbnail( p )
  # TODO:  This is a cumbersome way to do this.
  # TODO:  What image file types does Shoes support?
  i = ""
  f = File.join( 'default-thumbnail.png' )
  i = f if File.exists?( f )
  f = File.join( p, "#{p}.png" )
  i = f if File.exists?( f )
  f = File.join( p, "#{p}.jpg" )
  i = f if File.exists?( f )
  # If the default thumbnail doesn't actually exist, then this would gracefully default to painting an empty space of the appropriate size (150 x 150px, margins, etc).
  image(
    i,
    width: 150,
    height: 150,
    :margin_left => 10,
    :margin_bottom => 5
  ).click{ display_program( p ) }
end

def content( p, *splat )
  if splat != [] then
    keywords = splat[0]
    keywords = " (#{keywords.to_s})"
    keywords = '' if p == splat[0]
  end
  @content.append do flow( :margin_top => 10 ) do
    background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
      stack( width: 150 ) do
        para  # Blank line above the thumbnail.
        thumbnail( p )
      end
      flow( width: width-150 ) do
        para( link( p ){ display_program( p ) }, keywords, "\n" )
        # TODO:  How would I have this text be on the same line as the program name (the line above this one) and be right-aligned?
        button "Run" do
          program_run( p )
        end
        # FIXME:  This text needs a right margin.  I can't find the documentation for that.  (RE-TEST)
        para( program_description( p ) )
      end
    end
  end
end

def program_run( p )
  eval( File.open( File.join( p, "#{p}.rb" ) ).read, TOPLEVEL_BINDING )
end

# TODO/IDEA:  On the far right, do a KDE-style 'clear edit box' X.
def display_search( string )
  @content.clear
  @@tags_hash.each_key{ |k|
    @@tags_hash[k].each{ |v|
      if /#{ string }/ =~ v
        content( k, v )
      end
    }
  }
end # display_search( word )

def display_all()
  @content.clear
  @@programs.each do |p|
    content( p )
  end
end # display_all()

def main()
  # TODO:  Can I  have the cursor automatically placed in the edit_line when the program launches?
  # @self.width doesn't understand a scroll bar!  TODO:  How can I know if a scroll bar is being painted or not?  How do I know the size of a scroll bar?
  @search = edit_line( :width => self.width - 26, :margin_left => 10, :margin_top => 5 )
  @content = flow{}
  display_all()

  @search.change do |s|
    if s.text.empty?
      display_all()
    else
      display_search( s.text )
    end
  end
  #
end # main()

def back_to_main()
  link( 'Back' ){
    @content.remove
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
end

def program_description( program_directory )
  # Just kludging it for now.
  # TODO:  I should use some recognized format for descriptions.  Intelligently parse the file and pull it out.  Maybe even look for a README, file_id.diz, descript.ion or some such?
  # TODO:  Automatically link() hyperlinks.
  # TODO:  Automatically markup text markup.
  # TODO:  If I change the description, then add a button to view the unaltered description.
  return 'aaaaa ' * 20
end

def display_program( program_directory )
  @search.remove
  @content.remove
  @content = stack{
    background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
    stack( :margin_left => 10, :margin_top => 5, :margin_right => 20 ){
      para( back_to_main() )
      title( program_directory )
      button "Run" do
        program_run( program_directory )
      end
    }
    stack( :margin_left => 20 ){
    thumbnail( program_directory )
    para( program_contents( program_directory ) )
    }
  }
end # display_program()

Shoes.app(
            :title => "Program Browser",
            :width => 640,
            :height => 460,
            :resizeable => true
          ) do
  background( darkgray )
  main()
end

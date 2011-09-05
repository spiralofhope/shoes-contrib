=begin
#FIXME:  How do I enforce a margin when I'm "switching screens".
        #stack( :margin => 5 ) do
#TODO:  Can I add a right margin?
#TODO:  Is there a simple 'reset' command, so I don't have to remember/execute a list of @object.remove ?
=end

# This ignores dot directories.
@@programs = Dir.glob( '*' )
@@programs.delete_if { |x| File.ftype( x ) != 'directory' }
@@programs.sort!

def thumbnail( p )
  i = File.join( p, 'thumb.png' )
  if ! File.exists?( i ) then
    i = 'default-thumbnail.png'
  end
  image(
      i,
      width: 150,
      height: 150,
      :margin_left => 10,
      :margin_bottom => 5
    ).click{ display_program( p ) }
end

def content( p )
  @content.append do flow( :margin_top => 10 ) do
    background( lightyellow, :curve => 10, :margin_left => 5, :margin_right => 20 )
      stack( width: 150 ) do
        para  # Blank line above the thumbnail.
        thumbnail( p )
      end
      flow( width: width-150 ) do
        para( link( p ){ display_program( p ) }, "\n" )
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
  eval( File.open( File.join( p, 'circles.rb' ) ).read, TOPLEVEL_BINDING )
end

def display_search( string )
  @content.clear
  @@programs.each do |p|
    if /#{ string }/ =~ p
      content( p )
    end
  end
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

# TODO:  Syntax highlighting.
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

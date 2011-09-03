=begin
#FIXME:  How do I enforce a margin when I'm "switching screens".
        #stack( :margin => 5 ) do
#TODO:  Can I add a right margin?
#TODO:  Is there a simple 'reset' command, so I don't have to remember/execute a list of @whatever.remove ?
=end

# This ignores dot directories.
@@programs = Dir.glob( '*' )
@@programs.delete_if { |x| File.ftype( x ) != 'directory' }
@@programs.sort!

def thumbnail( p )
  # Doesn't work anyways, and if the image doesn't exist then things continue just fine..
  #return nil if ! File.exists( i )
  i = File.join( p, 'thumb.png' )
  image( i ).click do
    display_name( p )
  end
end

def content( p )
  @content.append do 
    flow( :margin_top => 5, :margin_right => 20, :margin_left => 5 ) do
      # FIXME:  Curve isn't working properly here, it's overridden by the flow above.
      background( lightyellow, :curve => 10 )
      thumbnail( p )
      para(
        link( p ){ display_name( p ) },
        "\n",
        program_description( p )
      )
    end
  end
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
  @search = edit_line( :width => self.width - 26 )
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
  link( "Back\n" ){
    @content.remove
    main()
  }
end

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

def display_name( program_directory )
  @search.remove
  @content.remove
  @content = stack{
    flow {
      para(
        back_to_main(),
        program_directory,
      )
    }
    para( program_contents( program_directory ) )
  }
end # display_name()

Shoes.app(
            :title => "Program Browser",
            :width => 640,
            :height => 460,
            :resizeable => true
          ) do
  background( darkgray )
  main()
end

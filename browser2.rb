=begin

FIXME:  How do I enforce a margin when I'm "switching screens" like this?
=end

# This ignores dot directories.
@@programs = Dir.glob( '*' )
@@programs.delete_if { |x| File.ftype( x ) != 'directory' }
@@programs.sort!

def do_search( word )
  @@programs.each do |p|
    if /#{word}/ =~ p
      @results.append do 
        stack( :margin_top => 5 ) do
          background( lightyellow, :curve => 6 )
          para link( p ){ display( p ) }
        end
      end
    end         
  end
end # do_search( word )

def display_all()
  @@programs.each do |p|
    @results.append do 
      stack( :margin_top => 5 ) do
        background( lightyellow, :curve => 6 )
        para link( p ){ display( p ) }
      end
    end         
  end
end # display_all()

def main()
  # TODO:  Can I add a right margin?
  #stack( :margin => 5 ) do
    # TODO:  Can I  have the cursor automatically placed in the edit_line when the program launches?
    # @self.width doesn't understand a scroll bar!  TODO:  How can I know if a scroll bar is being painted or not?  How do I know the size of a scroll bar?
    @search = edit_line( :width => self.width - 26 )
    @results = flow{}
  #end
  @results.clear{ display_all() }

  @search.change do |s|
    if s.text.empty?
      @results.clear{ display_all() }
    else
      @results.clear{ do_search( s.text ) }
    end
  end
  #
end # main()

def display( program_directory )
  @search.remove
  @results.remove

  #stack( :margin => 5 ) do
    @content = flow{}
  #end

  @content.clear{
    para(
      link( "Back\n" ){
        @content.remove
        main()
      },
      program_directory,
    )
  }
end # display()

Shoes.app(
            :title => "Program Browser",
            :width => 300,
            :height => 400
          ) do
  background( darkgray )
  main()
end

# This ignores dot directories.
files = Dir.glob( '*' )
files.delete_if { |x| File.ftype( x ) != 'directory' }
files.sort!

Shoes.app(
            :title => "shoes-contrib browser",
            :height => 75,
            :width => 355
          ) do
  stack do
    flow do
      para 'Choose a category:'
      @category_box = list_box( :items => files )
    end
    
    @example_flow = flow( :hidden => true ) do
      para 'Choose an example:'
      @example_box = list_box( :items => [] )
    end
    
    @category_box.change { |box|
      @example_flow.style( :hidden => false )
      @example_box.items = Dir.glob( "#{box.text}/*.rb" )
    }
    
    @example_box.change { |box|
      eval( File.open( box.text, 'rb' ).read, TOPLEVEL_BINDING )
    }
  end
end

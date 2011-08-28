# This ignores dot directories.
dirs = Dir.glob( '*' )
dirs.delete_if { |x| File.ftype( x ) != 'directory' }
dirs.sort!

Shoes.app(
            :title => "shoes-contrib browser",
            :height => 75,
            :width => 355
          ) do
  stack do
    flow do
      para 'Choose a category:'
      @category_box = list_box( :items => dirs )
    end
    
    @example_flow = flow( :hidden => true ) do
      para 'Choose an example:'
      @example_box = list_box( :items => [] )
    end
    
    @category_box.change { |box|
      @example_flow.style( :hidden => false )
      files = Dir.glob( "#{box.text}/*.rb" ).sort
      # TODO:  Display one thing and execute another.
      #files.each_index{ |i|
        # Remove the directory and the extension
        #files[i] = File.basename( files[i], '.rb' )
        # TODO:  Filenames with dashes should have a display name that has spaces instead.
      #}
      @example_box.items = files
    }
    
    @example_box.change { |box|
      eval( File.open( box.text, 'rb' ).read, TOPLEVEL_BINDING )
    }
  end
end

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

# TODO:  Left-align the image, and have the category text on the right to the top.
# TODO:  Category text:  categories/name.txt
def rebuild_readme()
  filename = File.join( '..', 'README.prepend' )
  string = file_read( filename )
  @@categories_array.each{ |e|
    # Header
    # On Github, <h2> ( ## string ) adds a horizontal rule above itself.
    a = "\n\n## #{ e }\n"
    # Image
    i = File.join( '..', 'default-thumbnail.png' )
    dir = File.join( '..', 'categories' )
    #
    f = File.join( dir, "#{ e }.png" )
    i = f if File.exists?( f )
    f = File.join( dir, "#{ e }.jpg" )
    i = f if File.exists?( f )
    i = i.split( File::Separator )[-1]
    #i = i[1..-1].join( '/' )
    # FIXME:  An absolute path like this will break mirrors.  Make it relative.
    i = 'https://github.com/spiralofhope/shoes-contrib/raw/master/categories/'.concat( i )
    #
    a.concat( "![#{ e }](#{ i })" )
    #
    string.concat( a )
  }
  string.concat( "\n\n" )
  filename = File.join( '..', 'README' )
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
  # TODO:  Investigate issues that with filenames which have a space.
  # FIXME:  There will be memory issues with reading large files.
  if ! File.exists?( file ) then
    puts "That file doesn't exist:  '#{ file.inspect }'"
    return
  end
  f = File.open( file, 'r' )
    string = f.read
  f.close
  return string
end
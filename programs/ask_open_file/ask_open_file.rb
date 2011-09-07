# tags: ask_open_file, File.read()
# categories: kernel

Shoes.app do
  filename = ask_open_file
  para File.read(filename)
end

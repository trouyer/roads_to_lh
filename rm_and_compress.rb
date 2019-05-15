EXPORT_DIR = '/path/to/export/dir'

(1..99).each do |dpt|
  # Get array of filename
  f_array = Dir.glob(EXPORT_DIR + dpt.to_s + "[0-9][0-9][0-9]_*.gpx")

  dirname = EXPORT_DIR + '%02d' % dpt.to_s
  Dir.mkdir dirname if not Dir.exists? dirname

  f_array.each do |file|
    text = File.read(file)
    new_content = text.gsub(/<time>[^<>]*<\/time>/, '')

    File.open(file, 'w') {|f| f.puts new_content }

    File.rename file, dirname + '/' + (File.basename file)
  end

  #Here compress dir
  `tgz #{dirname} #{dirname}`
  `rm -R #{dirname}`
end

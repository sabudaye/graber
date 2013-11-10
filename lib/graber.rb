require 'bundler/setup'
Bundler.require
require 'nokogiri'
require 'open-uri'

class Graber
  # TODO single responsobility
  def grab(url, dir  = "./tmp")

    make_dir(dir)

    uri = URI.parse(url)
    page = Nokogiri::HTML(read_uri(uri))

    images = []

    page.css('img').each do |img|
      begin
        images << to_url(uri, URI.parse(img.attributes['src']))
      rescue => e
        puts e.message
      end
    end

    threads = []
    count = images.length

    count.times do
      threads << Thread.new do
        while images.any?
          download(images.pop, dir)
        end
      end
    end

    threads.each { |t| t.join }
  end

  def read_uri(uri)
    uri.open.read
  end

  def make_dir(dir_name)
    Dir.mkdir(dir_name, 0700) unless Dir.exists?(dir_name)
  end

  def to_url(uri, string)
    string =~ URI::regexp(%w(http https)) ? string : URI.join(uri.to_s, string)
  end

  def download(image_url, dir)
    open(image_url) do |tmp|
      begin
        save_file(dir, image_url, tmp)
      rescue => e
        puts e.message
      end
    end
  end

  def save_file(dir, image_url, tmp_file)
    extension = get_extension(tmp_file)
    fullname = "#{dir}/#{filename}.#{extension}"
    begin
      File.open(fullname,"wb") do |file|
        file.puts tmp_file.read
      end
      puts "Downloaded #{image_url}, #{tmp_file.size} bytes"
      true
    rescue => e
      puts e.message
      false
    end
  end

  def get_extension(object)
    object.meta['content-type'].match(/^image\/([a-z]+);?/)[1]
  end

  def filename
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map{ o[rand(o.length)] }.join
  end
end

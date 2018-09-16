require 'nokogiri'
require 'fastimage'

process = Proc.new {|post|
    unless post.extname == '.xml'
      doc = Nokogiri::HTML.parse(post.output)
      # Stop if we could't parse with HTML
      return unless doc

      doc.css('img').each do |img|
        size = FastImage.size(File.expand_path File.dirname(__FILE__) + '/../' + img['src'])
        width = size[0]
        height = size[1]

        if width > 700
          multiplier = 700.0 / width
          width = (multiplier * width).round
          height = (multiplier * height).round
        end

        img['width'] = width
        img['height'] = height
      end

      post.output = doc.to_s
    end
}

Jekyll::Hooks.register :posts, :post_render do |post|
  process.call post
end

Jekyll::Hooks.register :pages, :post_render do |page|
  process.call page
end

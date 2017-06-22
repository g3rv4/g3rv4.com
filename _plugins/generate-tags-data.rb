# this plugin just loads the tag names in site.data["tags"]

Jekyll::Hooks.register :site, :post_read do |site|
  tags = {}
  site.collections['posts'].each do |post|
    post.data['tags'].each do |tag|
      unless tags.key? tag
        tags[tag] = {'tag' => tag, 'articles' => 0}
      end
      tags[tag]['articles']+=1
    end
  end
  tags = tags.values.select { |tag| tag['articles'] > 0 }.sort_by { |tag| -tag['articles'] }

  site.data["tags"] = tags
  site.data["linkedTags"] = tags.map { |tag| tag['tag'] }
end


Jekyll::Hooks.register :site, :post_read do |site|
  if site.config['build_only_this'] and site.config['build_only_this']['enabled']
    posts = site.data['build_only_this']['posts'].map do |post|
      '_posts/' + post + '.md'
    end

    pages = site.data['build_only_this']['pages']

    site.collections['posts'].docs = site.collections['posts'].docs.select do |val|
      posts.include? val.relative_path
    end

    site.pages = site.pages.select do |page|
      pages.include? page.name
    end
  end
end

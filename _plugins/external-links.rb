# Jekyll ExtLinks plugin
# Adds custom attributes like rel="nofollow" to all external links.
#
# 1. Install: put it in your _plugins folder inside your Jekyll project
# source root. Install nokogiri (gem install nokogiri).
#
# 2. Configure plugin in _config.yml. Notice the indentation matters. Example:
#
# extlinks:
#   attributes: {rel: nofollow, target: _blank}
#   rel_exclude: ['host1.com', 'host2.net']
#
# (attributes are required - at least one of them, rel_exclude is optional)
# Relative links will not be processed.
# Links to hosts listed in rel_exclude will not have the 'rel' attribute set.
# Links which have the 'rel' attribute already will keep it unchanged, like
# this one in Markdown:
# [Link text](http://someurl.com){:rel="dofollow"}
#
# 3. Use in layouts: {{ content | extlinks }}
#
# Developed by Dmitry Ogarkov - http://ogarkov.com/jekyll/plugins/extlinks/
# Based on http://dev.mensfeld.pl/2014/12/rackrails-middleware-that-will-ensure-relnofollow-for-all-your-links/

require 'nokogiri'
require 'net/http'

module Jekyll
  module ExtLinks
    @@already_checked = []

    # Access plugin config in _config.yml
    def config
      @context.registers[:site].config['extlinks']
    end

    # Checks if str contains any fragment of the fragments array
    def contains_any(str, fragments)
      return false unless Regexp.union(fragments) =~ str
      true
    end

    def extlinks(content, page)
      # Process configured link attributes and whitelisted hosts
      if config
        if config['attributes']
          attributes = Array(config['attributes'])
        end
        if config['rel_exclude']
          rel_exclude = Array(config['rel_exclude'])
        end
      end
      # Stop if no attributes were specified
      return content unless attributes

      doc = Nokogiri::HTML.parse(content)
      # Stop if we could't parse with HTML
      return content unless doc

      doc.css('a').each do |a|
        # If this is a local link don't change it
        next unless a.get_attribute('href') =~ /\Ahttp/i

        if config['check_links'] and not @@already_checked.include?(a.get_attribute('href'))
          @@already_checked << a.get_attribute('href')

          Process.fork do
            begin
              uri = URI(a.get_attribute('href'))
              unless config['check_exclude'].include?(uri.host)
                # verify that the link is good
                r = Net::HTTP.get_response(uri)

                # disregard SE redirects, I WANT to use this version so that they track my referers
                # blogpost also redirects to their local version
                if r.code == '302' and (uri.path =~ /\/[aq]\/[0-9]+\/[0-9]+/ or uri.host.end_with?("blogspot.com"))
                  # It's all good
                elsif r.code != "200"
                  print 'ERROR! Returned code ' + r.code + ' in file ' + page["path"] + ' when linking to ' + a.get_attribute('href') + "\n"
                else
                  # print 'OK!'
                end
              end
            rescue
              print 'ERROR! File ' + page["path"] + ' points to ' + a.get_attribute('href') + "\n"
            end
          end
        end

        attributes.each do |attr, value|
          if attr.downcase == 'rel'
            # If there's a rel already don't change it
            next unless !a.get_attribute('rel') || a.get_attribute('rel').empty?
            # Skip whitelisted hosts for the 'rel' attribute
            next if rel_exclude && contains_any(a.get_attribute('href'), rel_exclude)
          end
          a.set_attribute(attr, value)
        end
      end

      doc.to_s
    end

  end
end
Liquid::Template.register_filter(Jekyll::ExtLinks)

Jekyll::Hooks.register :site, :post_write do |site|
  Process.waitall
end

#!/bin/bash
docker run --rm -v /Users/gervasio/g3rv4.com:/var/site-content g3rv4/blog-builder /root/.rbenv/shims/jekyll build

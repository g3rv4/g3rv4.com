#!/bin/bash
docker run --rm -p 4000:4000 -v /Users/gervasio/g3rv4.com:/var/site-content g3rv4/blog-builder /root/.rbenv/shims/jekyll serve -p 4000 --host=0.0.0.0 -w

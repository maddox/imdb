require 'iconv'

module StringPatches
  def unescape_html
    Iconv.conv("UTF-8", 'ISO-8859-1', CGI::unescapeHTML(self))
  end

  def strip_tags
    gsub(/<\/?[^>]*>/, "")
  end
end

String.send :include, StringPatches

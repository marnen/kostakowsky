require 'nokogiri'

module MusicXmlHelpers
  def id(filename)
    filename.gsub(%r{\.[^.]+$}, '').split('_').last
  end

  def title(filename, full: false)
    xml = Nokogiri::XML File.new(filename)
    title = xml.at_xpath('//work/work-title').text
    subtitle = xml.at_xpath('//work/work-number')&.text if full
    [title, subtitle].compact.join ' '
  end
end

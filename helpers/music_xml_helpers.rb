require 'nokogiri'

module MusicXmlHelpers
  def title(filename)
    xml = Nokogiri::XML File.new(filename)
    xml.at_xpath('//work/work-title').text
  end
end

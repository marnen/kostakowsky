require 'nokogiri'

module MusicXmlHelpers
  def id(filename)
    filename.gsub(%r{\.[^.]+$}, '').split('_').last
  end

  def title(filename)
    xml = Nokogiri::XML File.new(filename)
    xml.at_xpath('//work/work-title').text
  end
end

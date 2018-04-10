require 'nokogiri'

module MusicXmlHelpers
  MAJOR_KEYS = {
    -7 => 'Cb',
    -6 => 'Gb',
    -5 => 'Db',
    -4 => 'Ab',
    -3 => 'Eb',
    -2 => 'Bb',
    -1 => 'F',
    0 => 'C',
    1 => 'G',
    2 => 'D',
    3 => 'A',
    4 => 'E',
    5 => 'B',
    6 => 'F#',
    7 => 'C#',
    8 => 'G#',
    9 => 'D#',
    10 => 'A#'
  }


  def id(filename)
    filename.gsub(%r{\.[^.]+$}, '').split('_').last
  end

  def key(filename)
    xml = xml(filename)
    key = xml.at_xpath('//key')
    fifths = key.at_xpath('./fifths').text.to_i
    mode = key.at_xpath('./mode').text
    case mode
    when 'major'
      MAJOR_KEYS[fifths]
    when 'minor'
      "#{MAJOR_KEYS[fifths + 3]}m"
    end
  end

  def title(filename, full: false)
    xml = xml(filename)
    title = xml.at_xpath('//work/work-title').text
    subtitle = xml.at_xpath('//work/work-number')&.text if full
    [title, subtitle].compact.join ' '
  end

  private

  def xml(filename)
    @xml ||= {}
    filename = File.absolute_path filename
    @xml[filename] ||= Nokogiri::XML(File.new filename)
  end
end

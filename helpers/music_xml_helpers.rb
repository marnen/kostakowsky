require 'nokogiri'

module MusicXmlHelpers
  MAJOR_KEYS = {
    -7 => 'C♭',
    -6 => 'G♭',
    -5 => 'D♭',
    -4 => 'A♭',
    -3 => 'E♭',
    -2 => 'B♭',
    -1 => 'F',
    0 => 'C',
    1 => 'G',
    2 => 'D',
    3 => 'A',
    4 => 'E',
    5 => 'B',
    6 => 'F♯',
    7 => 'C♯',
    8 => 'G♯',
    9 => 'D♯',
    10 => 'A♯'
  }

  MODES = {
    'major' => {adjust: 0, suffix: ''},
    'minor' => {adjust: 3, suffix: 'm'},
    'dorian' => {adjust: 2, suffix: 'dor'},
  }


  def id(filename)
    filename.gsub(%r{\.[^.]+$}, '').split('_').last
  end

  def key(filename)
    xml = xml(filename)
    xml.xpath('//key').map do |key|
      fifths = key.at_xpath('./fifths').text.to_i
      mode = key.at_xpath('./mode')&.text || 'major'
      key_name fifths, mode: mode
    end.join ', '
  end

  def title(filename, full: false)
    xml = xml(filename)
    title = xml.at_xpath('//work/work-title').text
    subtitle = xml.at_xpath('//work/work-number')&.text if full
    [title, subtitle].compact.join ' '
  end

  private

  def key_name(fifths, mode: 'major')
    mode = MODES[mode] || raise(ArgumentError, "Unknown mode: #{inspect mode}. Recognized modes are: {MODES.keys.join ', '}.")
    adjusted_fifths = fifths + mode[:adjust]
    MAJOR_KEYS[adjusted_fifths] + mode[:suffix]
  end

  def xml(filename)
    @xml ||= {}
    filename = File.absolute_path filename
    @xml[filename] ||= Nokogiri::XML(File.new filename)
  end
end

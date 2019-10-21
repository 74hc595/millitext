#!/usr/bin/env ruby
# 
# 'millitext' subpixel-text renderer
# Matt Sarnoff (matt.sarnoff@gmail.com)
# October 22, 2008
# www.msarnoff.org

require 'rmagick'
include Magick

#### colors
$intensity = 1
$contrast = 0
COLORS = {'.' => 'black','b' => 'blue','g' => 'lime','c' => 'cyan','r' => 'red',
'm' => 'magenta','y' => 'yellow','w' => 'white'}

#### fonts
$fontwidth = 1
$font = nil
$center = true
CHAR_W  = 2
CHAR_H  = 5
SPACE_W = 1
LINESEP = 1
BORDER_W = 1
FONT1X5 = {
'0' => 'wmmmw.....', '1' => 'ygggw.....', '2' => 'wbwrw.....',
'3' => 'wbwbw.....', '4' => 'mmwbb.....', '5' => 'wrwbw.....',
'6' => 'wrwmw.....', '7' => 'wmbbb.....', '8' => 'wmwmw.....',
'9' => 'wmwbw.....', 'A' => 'wmwmm.....', 'B' => 'ymymy.....',
'C' => 'wrrrw.....', 'D' => 'ymmmy.....', 'E' => 'wrwrw.....',
'F' => 'wrwrr.....', 'G' => 'wrmmw.....', 'H' => 'mmwmm.....',
'I' => 'wgggw.....', 'J' => 'bbbbw.....', 'K' => 'mmymm.....',
'L' => 'rrrrw.....', 'M' => 'mwwmm.....', 'N' => 'ymmmm.....',
'O' => 'gmmmg.....', 'P' => 'ymyrr.....', 'Q' => 'gmmwc.....',
'R' => 'ymymm.....', 'S' => 'crgby.....', 'T' => 'wgggg.....',
'U' => 'mmmmw.....', 'V' => 'mmmcb.....', 'W' => 'mmwwm.....',
'X' => 'mmgmm.....', 'Y' => 'mmggg.....', 'Z' => 'wbgrw.....',
'!' => 'ggg.g.....', '"' => 'mm........', '#' => 'cwcwc.....',
'$' => 'wywcw.....', '%' => 'mbgrm.....', '&' => '.gwg......',
"'" => 'gg........', '(' => 'bgggb.....', ')' => 'rgggr.....',
'*' => '.www......', '+' => '.gwg......', ',' => '...gr.....',
'-' => '..w.......', '.' => '....g.....', '/' => 'bbgrr.....',
':' => '.g.g......', ';' => '.g.gr.....', '<' => 'bgrgb.....',
'=' => '.w.w......', '>' => 'rgbgr.....', '?' => 'wbc.g.....',
'@' => 'wwwrw.....', '[' => 'cgggc.....', '\\'=> 'rrgbb.....',
']' => 'ygggy.....', '^' => 'gm........', '_' => '....w.....',
'`' => 'gb........', '{' => 'cgrgc.....', '|' => 'ggggg.....',
'}' => 'ygbgy.....', '~' => '.cy.......', ' ' => '..........'
}

FONT2X5 = {
'0' => 'crmycryggr', '1' => 'bcbbc....r', '2' => 'w.crwrgr.y',
'3' => 'w.c.wrgrgr', '4' => 'rrw..rryrr', '5' => 'wrw.wy.rgr',
'6' => 'crwrcr.rgr', '7' => 'w..bbygr..', '8' => 'crcrcrgrgr',
'9' => 'crc.crgygr', 'A' => 'crwrrrgygg', 'B' => 'wrwrwrgrgr',
'C' => 'crrrcy...y', 'D' => 'wrrrwrgggr', 'E' => 'wrwrwy.r.y',
'F' => 'wrwrry.r..', 'G' => 'crmrcy.ygy', 'H' => 'rrwrrggygg',
'I' => 'cbbbcr...r', 'J' => '...rcggggr', 'K' => 'rrwrrgr.rg',
'L' => 'rrrrw....y', 'M' => 'rymrrgyggg', 'N' => 'rymrrgggyg',
'O' => 'crrrcrgggr', 'P' => 'wrwrrrgr..', 'Q' => 'crrrcrggrg',
'R' => 'wrwrrrgrgg', 'S' => 'crc.wy.rgr', 'T' => 'wbbbby....',
'U' => 'rrrrcggggr', 'V' => 'rrrgbgggr.', 'W' => 'rrmyrgggyg',
'X' => 'rgbgrgr.rg', 'Y' => 'rgbbbgr...', 'Z' => 'w.bgwyr..y',
'!' => 'bbb.b.....', '"' => 'gg...rr...', '#' => 'gwgwgryryr',
'$' => 'cmcbwy.rgr', '%' => 'r.bgrgr..g', '&' => 'crcrc..grg',
"'" => 'bb........', '(' => '.bbb.r...r', ')' => 'gbbbg.....',
'*' => 'bmcmb.grg.', '+' => 'bbwbb..y..', ',' => '...bg.....',
'-' => '..w....y..', '.' => '....b.....', '/' => '..bgrgr...',
':' => '.b.b......', ';' => '.b.bg.....', '<' => '.bgb.r...r',
'=' => '.w.w..y.y.', '>' => 'gb.bg..r..', '?' => 'crb.b.r...',
'@' => 'crmrcryy.y', '[' => 'bbbbbr...r', '\\'=> 'rgb.....rg',
']' => 'cbbbc.....', '^' => 'bgr...rg..', '_' => '....w....y',
'`' => 'b.....r...', '{' => 'bbgbbr...r', '|' => 'bbbbb.....',
'}' => 'cb.bc..r..', '~' => '.gm....gr.', ' ' => '..........'
}

#### string functions
class String
  def img_line_width
    w = 0
    self.each_byte do |c|
      w += (c.chr == ' ') ? SPACE_W : CHAR_W
    end
    if w > 0 then
      w -= (CHAR_W - $fontwidth) if self[-1].chr != 'c'
    end
    return w
  end

  def img_dims
    w = 0
    h = 0
    self.each_line do |l|
      h += CHAR_H + LINESEP
      lw = l.chomp.img_line_width
      w = lw if lw > w
    end
    h -= LINESEP if h > 0
    return [w, h]
  end
  
  def pixmap
    pstr = $font[self]
    pstr = $font[' '] unless pstr
    pixels = []
    (0..CHAR_H-1).each do |y|
     (0..CHAR_W-1).each do |x|
       color = COLORS[pstr[(x*CHAR_H)+y].chr]
       color = "black" unless color
       px = Pixel.from_color(color)
       px.decontrast! $contrast
       px.scale! $intensity
       px.invert! if $invert
       pixels << px
     end
    end
    
    return pixels
  end
end

#### image functions
class Pixel
  def scale!(factor)
    self.red *= factor
    self.green *= factor
    self.blue *= factor
    return self
  end
  
  def decontrast!(factor)
    self.red = [self.red+factor, 65535].min
    self.green = [self.green+factor, 65535].min
    self.blue = [self.blue+factor, 65535].min
    self
  end
  
  def invert!
    self.red = 65535 - self.red
    self.green = 65535 - self.green
    self.blue = 65535 - self.blue
  end
end

def create_blank_image(w,h)
  Image.new(w,h) {
    if $invert then
      self.background_color = "white"
    else
      self.background_color = "black"
    end
  }
end

def render_text(img, str)
  y = BORDER_W
  str.each_line do |line|
    x = BORDER_W
    if $center then
      x = (img.columns - line.chomp.img_line_width) / 2
    end
    line.chomp.each_byte do |c|
      if c.chr == ' ' then
        x += SPACE_W
      else
        img.store_pixels(x, y, CHAR_W, CHAR_H, c.chr.pixmap)
        x += CHAR_W
      end
    end
    y += CHAR_H + LINESEP
  end
end

#### main
def create_image(str)
  w, h = str.img_dims
  return nil if w <= 0 or h <= 0
  
  w += BORDER_W * 2
  h += BORDER_W * 2
  img = create_blank_image(w,h)
  render_text(img, str)
  return img
end

def millitext(str, fw, ctr, inv, tr, br)
  $fontwidth = fw
  $fontwidth = 1 if $fontwidth != 2
  if $fontwidth == 1 then
    $font = FONT1X5
  else
    $font = FONT2X5
  end

  $center = ctr
  $invert = inv
  $transparent = tr
  $intensity = br
  
  str = str.slice(0,1000)
  str.upcase!

  return create_image(str)
end

#begin
#if !ARGV[1] then
#  puts "usage: milligen text outfile [font]"
#  exit
#end
#
#$fontwidth = ARGV[2].to_i
#$fontwidth = 1 if $fontwidth != 2
#
#if $fontwidth == 1
#  $font = FONT1X5
#elsif $fontwidth == 2
#  $font = FONT2X5
#end
#
#create_image(ARGV[0].upcase).write(ARGV[1])


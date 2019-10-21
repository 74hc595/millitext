// base 64 code //
var _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_";

function utf8encode(string)
{
  string = string.replace(/\r\n/g,"\n");
  var utftext = "";

  for (var n = 0; n < string.length; n++)
  {
    var c = string.charCodeAt(n);
    if (c < 128) {
      utftext += String.fromCharCode(c);
    }
    else if((c > 127) && (c < 2048)) {
      utftext += String.fromCharCode((c >> 6) | 192);
      utftext += String.fromCharCode((c & 63) | 128);
    } else {
      utftext += String.fromCharCode((c >> 12) | 224);
      utftext += String.fromCharCode(((c >> 6) & 63) | 128);
      utftext += String.fromCharCode((c & 63) | 128);
    }
  }
  return utftext;
}

function base64encode(input)
{
  var output = "";
  var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
  var i = 0;
  input = utf8encode(input);
  while (i < input.length)
  {
    chr1 = input.charCodeAt(i++);
    chr2 = input.charCodeAt(i++);
    chr3 = input.charCodeAt(i++);

    enc1 = chr1 >> 2;
    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
    enc4 = chr3 & 63;

    if (isNaN(chr2)) {
      enc3 = enc4 = 64;
    } else if (isNaN(chr3)) {
      enc4 = 64;
    }
    output = output +
    _keyStr.charAt(enc1) + _keyStr.charAt(enc2) +
    _keyStr.charAt(enc3) + _keyStr.charAt(enc4);
  }
  return output;
}

// main code //
function encodeOptions(o1, o2, o3)
{
  var options = 0;
  options |= (o1) ? 1 : 0;
  options |= (o2) ? 2 : 0;
  options |= (o3) ? 4 : 0;
  return options;
}

function encodeBrightness(val)
{
  if (val < 0 || val > 63)
    val = 63;
  return _keyStr.charAt(val);
}

function getImage(url)
{
  document.getElementById("outinfo").style.display = "block";
  document.getElementById("msg").innerHTML = 
    "The text is in the box below. Look closely!";
    
  document.getElementById("outimg").src = url;

  var outlink = document.getElementById("outlink");
  outlink.value = "http://msarnoff.org/millitextgen/" + url;  
}

function create()
{
  var text = document.getElementById("text").value;
  if (!text)
    return false;
    
  text = text.substring(0,1000);
  var base64 = base64encode(text);

  var font = document.getElementById("font").value == 2;
  var center = document.getElementById("center").checked;
  var invert = document.getElementById("invert").checked;
  var options = encodeOptions(font, center, invert);
  
  var bright = document.getElementById("bright").value;
  bright = encodeBrightness(parseInt(bright));
  
  var url = "mt.rb?t=" + base64 + "&o=" + options + "&b=" + bright;
  
  getImage(url);
}

function toggleInfo()
{
  document.getElementById("infolink").style.display = "none";
  document.getElementById("info").style.display = "block";
}

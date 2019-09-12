alt=60-- altitude du point de mesure

sda, scl = 2, 1
local sla = 0x3c
i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
bme280.setup()
status = tsl2561.init(sda, scl, tsl2561.ADDRESS_FLOAT, tsl2561.PACKAGE_T_FN_CL)


gpio.mode(12,gpio.INPUT)
local testsortie
testsortie = 0

--demarrage tsl2561
if status == tsl2561.TSL2561_OK then
    ch0, ch1 = tsl2561.getrawchannels()
    print("Raw values: "..ch0, ch1)
    lux = tsl2561.getlux()
    print("Illuminance: "..lux.." lx")
end
--demarrage bme280
T=0
while T == 0 do
T, P, H, QNH = bme280.read(alt)
end
local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
print(string.format("T=%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100))
print(string.format("QFE=%d.%03d", P/1000, P%1000))
print(string.format("QNH=%d.%03d", QNH/1000, QNH%1000))
print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
D = bme280.dewpoint(H, T)
local Dsgn = (D < 0 and -1 or 1); D = Dsgn*D
print(string.format("dew_point=%s%d.%02d", Dsgn<0 and "-" or "", D/100, D%100))

-- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
P = bme280.baro()
curAlt = bme280.altitude(P, QNH)
local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
print(string.format("altitude=%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100))



function init_display()
disp = u8g.ssd1306_128x64_i2c(sla)
  font = u8g.font_6x10
end

local function setLargeFont()
  disp:setFont(font)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop()
end

function updateDisplay(func)
local function drawPages()
    func()
    if (disp:nextPage() == true) then
      node.task.post(drawPages)
    end
  end
  -- Restart the draw loop and start drawing pages
  disp:firstPage()
  node.task.post(drawPages)
end

--bme280
function drawbme()
T = 0
while T == 0 do
 T, P, H, QNH = bme280.read(alt)
 end
local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
D = 0
while D == 0 do
D = bme280.dewpoint(H, T)
end
local Dsgn = (D < 0 and -1 or 1); D = Dsgn*D
P = 0
while P == 0 do
P = bme280.baro()
end
curAlt = bme280.altitude(P, QNH)
local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
-- affichage ecran
     if T ~="" then
     setLargeFont()
     disp:drawStr(15,0, (string.format("T=%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100)))
     disp:drawStr(15,11,(string.format("QFE=%d.%03d", P/1000, P%1000)))
     disp:drawStr(15,22,(string.format("QNH=%d.%03d", QNH/1000, QNH%1000)))
     disp:drawStr(15,33,(string.format("humidité=%d.%03d%%", H/1000, H%1000)))
     disp:drawStr(15,44,(string.format("pt_rosée=%s%d.%02d", Dsgn<0 and "-" or "", D/100, D%100)))
     disp:drawStr(15,56,(string .format("altitude=%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100)))
     end

end


--tsl2561
 function drawtsl()
  if status == tsl2561.TSL2561_OK then
ch0, ch1 = tsl2561.getrawchannels()
   disp:drawStr(5,22, (string .format("val brutes: %s %s ",ch0, ch1)))
 lux = tsl2561.getlux()
  setLargeFont()
  disp:drawStr(5,44, (string .format("luminosité: %s lx",lux)))
end
end


function senddata()
 conn=net.createConnection(net.TCP,0)
conn:on("receive", function(conn, pl) print("response: ",pl) end)
conn:on("connection",function(conn, payload)
conn:send("POST /dweet/for/imkael?temperature=" .. T/100 .. "&hum=" .. H/1000 .. "&ptrosee=" .. D/100 .. "&curalt=" .. curAlt/100 .. "&lux=" .. lux .. "&pat=" .. P/1000 .. " HTTP/1.1\r\nHost: dweet.io\r\n".."Connection: close\r\nAccept: */*\r\n\r\n")
end)
conn:connect(80,"dweet.io")
end

-- ecran
 local drawmeteo = { drawbme, drawtsl }

 function demometeo()
  -- Start the draw loop with one of the demo functions
  local f = table.remove(drawmeteo,1)
  updateDisplay(f)
  table.insert(drawmeteo,f)
  senddata()
sleepecr()
end

function sleepecr()
local testbouton
testbouton =  gpio.read(12)
print("etatbouton " .. testbouton )
print ("testsortie " .. testsortie)
     if testbouton == 1 then
     print ("testbouton2")
          if  testsortie == 1 then
           disp:sleepOn()
           testsortie = 0
print ("testsortie " .. testsortie)
          else
           disp:sleepOff()
           testsortie = 1
print ("testsortie " .. testsortie)
          end
     end
end

init_display()
demometeo()
tmr.alarm(4, 15000, 1, demometeo)

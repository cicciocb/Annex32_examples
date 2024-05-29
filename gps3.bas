'Test program using a GPS NEO-6M-0-001
'date 26-05-2024 by cicciocb
' Demo with extensive use of the regex functions
'
'GGA —Global Positioning System Fixed Data
'                UTC Time    Latitude   N/S   Longitude   E/W   Fix  Nb Sat  HDOP     MSL Altit.  M   Geoid Sep  M
GGA$ = "%$GPGGA,(%d+%.%d+),(%d+%.%d+),([NS]),(%d+%.%d+),([EW]),(%d+),(%d+),(%d+%.%d+),(%d+%.%d+),(M),(%d+%.%d+),(M)"

'GLL—Geographic Position - Latitude/Longitude
'                 Latitude   N/S   Longitude   E/W   UTC Time  Status  Mode
GLL$ = "%$GPGLL,(%d+%.%d+),([NS]),(%d+%.%d+),([EW]),(%d+%.%d+),([AV]),([ADE])"

'GSA—GNSS DOP and Active Satellites
'                Mode1  Mode2  SAT1  SAT2  SAT3  SAT4  SAT5  SAT6  SAT7  SAT8  SAT9  SAT10 SAT11 SAT12   PDOP        HDOP      VDOP
GSA$ = "%$GPGSA,([AM]),([123]),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d*),(%d+%.%d+),(%d+%.%d+),(%d+%.%d+)"

'RMC—Recommended Minimum Specific GNSS Data
'                UTC Time  Status   Latitude   N/S   Longitude   E/W  Speed(Kts)  Course(°)   Date   MagVar       E W    Mode
RMC$ = "%$GPRMC,(%d+%.%d+),([AV]),(%d+%.%d+),([NS]),(%d+%.%d+),([EW]),(%d*%.*%d*),(%d*%.*%d*),(%d+),(%d*%.*%d*),([EW]*),([ADE])"

'VTG—Course Over Ground and Ground Speed
'                Course(°)  T  Course(°)  M  Speed(Kts) N  Speed(Kph) K  Mode
VTG$ = "%$GPVTG,(%d*%.*%d*),T,(%d*%.*%d*),M,(%d*%.*%d*),N,(%d*%.*%d*),K,([ADE]"

UTCtime$ = ""
Status$ = ""
Latitude$ = ""
Longitude$ = ""
Speed$ = ""
Course$ = ""
UTCdate$ = ""
Mode$ = ""
NBsat$ = ""
HDOP$ = ""
Altitude$ = ""
  
count = 0
serial2.mode 9600, 2, 1, 8, 0, 1, 256,1024', 1024, 1024 'updated serial mode with bufferTX, BufferRX,
onserial2 gps_received
OnHtmlReload webPage
gosub webPage

wait

gps_received:
'pause 200
r$ = serial2.input$
print r$, count
'RMC—Recommended Minimum Specific GNSS Data
' UTC Time  Status   Latitude   N/S   Longitude   E/W  Speed(Kts)  Course(°)   Date   MagVar       E W    Mode
le = regex.match(r$, RMC$, m$())
if (le) then
  x = regex.match(m$(0),"(%d%d)(%d%d)(%d%d).(%d+)", x$()) ' time
  UTCtime$ = x$(0) + ":" + x$(1) + ":" + x$(2) + "." + x$(3)
  x = regex.match(m$(8),"(%d%d)(%d%d)(%d%d)", x$()) 'date
  UTCdate$ = x$(0) + "/" + x$(1) + "/" + x$(2)
  Status$ = m$(1)
  x = regex.match(m$(2),"(%d%d)(%d%d%.%d+)", x$()) 'latitude
  lat = val(x$(0)) + val(x$(1))/60 
  Latitude$ = str$(lat) + m$(3)
  x = regex.match(m$(4),"(%d%d%d)(%d%d%.%d+)", x$()) 'longitude
  long = val(x$(0)) + val(x$(1))/60 
  Longitude$ = str$(long) + m$(5)
  Speed$ = m$(6)
  Course$ = m$(7) 
  Mode$ = m$(11)
else
  Status$ = "NOT VALID"
endif

le = regex.match(r$, GGA$, m$())
if (le) then
  'UTC Time    Latitude   N/S   Longitude   E/W   Fix  Nb Sat  HDOP     MSL Altit.  M   Geoid Sep  M
  NBsat$ = m$(6)
  HDOP$ = m$(7)
  Altitude$ = m$(8)
endif
incr count

return

webPage:
cls
a$ = ""
a$=a$ + "Latitude" + textbox$(Latitude$) + " Longitude" +  textbox$(Longitude$) + " Altitude" + textbox$(Altitude$) + "<br>"
a$=a$ + "Nb Sat" + textbox$(NBsat$) + " HDOP" +  textbox$(HDOP$) + " Status" + textbox$(Status$) + "<br>"
a$=a$ + "UTC Time" + textbox$(UTCtime$) + " UTC Date" +  textbox$(UTCdate$) +  " Mode" + textbox$(Mode$) + "<br>"
a$=a$ + "Speed(Kts)" + textbox$(Speed$) + " Course(°)" +  textbox$(Course$) + "<br>"
html a$
a$ = ""
autorefresh 500
return

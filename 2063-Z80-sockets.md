
## IC Sockets

You can buy fancy expensive ones, or you can buy cheap ones.
I used the cheap ones.  

Alternately, you can just solder the chips into the PCB.

As a tinkerer, the thing that is wrong with that is that it makes it very hard to 
recycle/repurpose the chips for something else in the future.  And with the 2021
chip-shortage in full-force on as I type this, being able to recycle chips is 
VERY appealing!

Be honest with yourself before sinking more money into sockets than the cost of the chips 
that go into them.  I expect the cheap ones to last for at least a decade or two.  Cheap
sockets in my hobby projects from 30 years ago are still doing fine.

Gold plating is better than tin.  Machined pins (see the oscillator sockets) are better then
stamped spring-metal pins. 


Ref | Qty | Value | Digikey | Datasheet | Description
----|-----|-------|---------|-----------|------------
U1,U5 | 2 | Socket | AE10008-ND | http://www.assmann-wsw.com/uploads/datasheets/ASS_0810_CO.pdf | DIP-40
U2,U3 | 2 | Socket | 2057-ICS-632-T-ND | https://app.adam-tech.com/products/download/data_sheet/199581/ics-6xx-t-data-sheet.pdf | DIP-32
U4 | 1 | Socket | 2057-ICS-628-T-ND | https://app.adam-tech.com/products/download/data_sheet/199581/ics-6xx-t-data-sheet.pdf | DIP-28
U10,U13,U11 | 3 | Socket | 2057-ICS-314-T-ND | https://app.adam-tech.com/products/download/data_sheet/199582/ics-3xx-t-data-sheet.pdf | DIP-14
U9,U12 | 2 | Socket | 2057-ICS-316-T-ND | https://app.adam-tech.com/products/download/data_sheet/199582/ics-3xx-t-data-sheet.pdf | DIP-16
U6,U7,U8 | 3 | Socket | 2057-ICS-320-T-ND | https://app.adam-tech.com/products/download/data_sheet/199582/ics-3xx-t-data-sheet.pdf | DIP-20

# Sockets for the Oscillators

Metal can oscillators have wires for pins.  In my experience they tend to sit loosely in 
regular sockets and do better in machined-pin sockets.

For these 4-pin parts you have two options.  Either order a relatively expensive pair of 
sockets ready to solder in as-is or order a pair with extra pins and remove the ones you don't
want and then solder in. 

I went the latter route because I already had several 8-pin sockets on hand.

To remove the extra pins from the fully loaded sockets, use a small pliers to grab the pins 
to be removed from the bottom of the socket and push them out the top.

Look at the photos of each type and you'll see what I mean.

Ref | Qty | Value | Digikey | Datasheet | Description
----|-----|-------|---------|-----------|------------
X1,X2 | 2 | Socket | ED90427-ND | https://www.mill-max.com/catalog/download/2017-11:134.pdf | OSC-4 (a whopping $1.50 each!)
X1,X2 | 2 | Socket | AE10011-ND | http://www.assmann-wsw.com/uploads/datasheets/ASS_4852_CO.pdf | DIP-8 ($.50 each)


## Shorting Blocks

These are for selecting the clock sources for the SIO, user jumper, and 
RS-232 TX/RX pin number selection.

Ref | Qty | Value | Digikey | Datasheet | Description
----|-----|-------|---------|-----------|------------
J11,J9,J1,J8 | 7 | S9337-ND | https://s3.amazonaws.com/catalogspreads-pdf/PAGE128-129%20.100%20JUMPER.pdf | Shorting Block | Shorting Jumper

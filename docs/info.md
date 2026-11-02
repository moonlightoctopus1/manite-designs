## How it works

The chip is the digital core of a small magnetic bead ("manite"). A comparator outside the chip turns a 13.56 MHz radio carrier into an on/off stream on `RX`. The chip decodes 48-bit frames sent as bursts of carrier: each burst is 1 unit (T = 16 clock cycles) long, and the time from the start of one burst to the start of the next carries one bit (2T = 0, 4T = 1). A frame is a 4-bit type, a 32-bit address, an 8-bit action code and 4 bits of parity.

Commands are addressed either to a **zone** (layer, x, y, group, with wildcards) or to a 32-bit **ID** (24 bits fixed in the chip, 8 bits from the strap pins `uio[7:0]`), or broadcast. Actions: sleep and wake, LED off / on / blink, latch release and close pulses (3 ms), run one of eight stored move programs. A key (64 bits, sent in two UNLOCK frames) and a SELECT allow the host to load the zone, group and move programs. While the bead moves it does not listen. The LED command is always remembered, but the LED output is on only while `SUPPLY_OK` is high and the bead is not moving.

## How to test

Clock 1 MHz. Hold `ui[2]` (SUPPLY_OK) high. Send frames on `ui[0]`, see the Verilog test bench `test/test.py` for the frame timing. Outputs: `uo[0]` LED, `uo[1]` latch A pulse, `uo[2]` latch B pulse, `uo[3]` moving, `uo[4]` frame received with good parity, `uo[5]` last ID frame matched, `uo[6]` last zone frame matched.

## External hardware

A comparator (made from the tank coil and a detector, or a signal generator and a comparator chip) to produce `RX`; a 1 MHz clock; an LED with a resistor on `uo[0]`; jumpers or switches on `uio[7:0]` for the ID.

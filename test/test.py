import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

K = 0x4D414E4954455F31
IDR = 0xA5C3E1
ST = 0x05
MID = (IDR << 8) | ST
T = 16

LED, LA, LB, MV, FG, IH, ZH = range(7)

def mk(t, a, c):
    b = (t << 40) | (a << 8) | c
    p = 0
    for i in range(11):
        p ^= (b >> (4 * i)) & 0xF
    return (b << 4) | p

class B:
    def __init__(s, d):
        s.d = d
        s.sup = 1

    async def pl(s, v, n):
        s.d.ui_in.value = (s.sup << 2) | v
        await ClockCycles(s.d.clk, n)

    async def send(s, f, sc=1.0):
        t = int(T * sc)
        await s.pl(1, 4 * t)
        await s.pl(0, t)
        await s.pl(1, t)
        for i in range(47, -1, -1):
            n = 4 * t if (f >> i) & 1 else 2 * t
            await s.pl(0, n - t)
            await s.pl(1, t)
        await s.pl(0, 120)

    async def cid(s, a):
        await s.send(mk(2, MID, a))

    async def unlock(s):
        await s.send(mk(3, K >> 32, 0))
        await s.send(mk(3, K & 0xFFFFFFFF, 1))

    def out(s, b):
        return (int(s.d.uo_out.value) >> b) & 1

async def start(d):
    cocotb.start_soon(Clock(d.clk, 1, unit="us").start())
    d.ena.value = 1
    d.ui_in.value = 0b100
    d.uio_in.value = ST
    d.rst_n.value = 0
    await ClockCycles(d.clk, 10)
    d.rst_n.value = 1
    await ClockCycles(d.clk, 10)
    return B(d)

@cocotb.test()
async def t_led(d):
    b = await start(d)
    assert int(d.uio_oe.value) == 0
    await b.cid(0x11)
    assert b.out(LED) == 1
    await b.cid(0x10)
    assert b.out(LED) == 0

@cocotb.test()
async def t_bad(d):
    b = await start(d)
    await b.send(mk(2, MID, 0x11) ^ 1)
    assert b.out(LED) == 0
    await b.send(mk(2, MID ^ 1, 0x11))
    assert b.out(LED) == 0

@cocotb.test()
async def t_sup(d):
    b = await start(d)
    b.sup = 0
    await b.cid(0x11)
    assert b.out(LED) == 0
    b.sup = 1
    await b.pl(0, 5)
    assert b.out(LED) == 1

@cocotb.test()
async def t_zone(d):
    b = await start(d)
    await b.unlock()
    await b.cid(0x04)
    await b.send(mk(4, (0x01 << 24) | (3 << 16) | (7 << 8) | 9, 0))
    await b.send(mk(5, 0, 0))
    z = (3 << 27) | (7 << 19) | (9 << 11)
    await b.send(mk(1, z, 0x11))
    assert b.out(LED) == 1 and b.out(ZH) == 1
    await b.send(mk(1, z | 0x7, 0x10))
    assert b.out(LED) == 0
    n = {"a": 0, "b": 0}

    async def watch():
        while True:
            await ClockCycles(d.clk, 1)
            n["a"] += b.out(LA)
            n["b"] += b.out(LB)

    w = cocotb.start_soon(watch())
    await b.send(mk(2, MID, 0x21))
    await ClockCycles(d.clk, 3500)
    w.cancel()
    assert 2990 <= n["a"] <= 3010 and n["b"] == 0

`default_nettype none
module tt_um_manite_s1 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    wire led, la, lb, mv, fg, ih, zh;
    bead_core c (
        .ck(clk), .rn(rst_n),
        .rx(ui_in[0]), .ok(ui_in[2]), .slw(ui_in[1]), .st(uio_in),
        .led(led), .la(la), .lb(lb), .mv(mv),
        .fg(fg), .ih(ih), .zh(zh)
    );
    assign uo_out  = {1'b0, zh, ih, fg, mv, lb, la, led};
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0;
    wire _unused = &{ena, ui_in[7:3], 1'b0};
endmodule

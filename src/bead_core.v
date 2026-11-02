`default_nettype none
module bead_core #(
    parameter TC     = 16,
    parameter MC    = 1000,
    parameter MS    = 32,
    parameter LM   = 3,
    parameter [23:0] IDR  = 24'hA5C3E1,
    parameter [63:0] KEY = 64'h4D414E4954455F31
) (
    input  wire       ck,
    input  wire       rn,
    input  wire       rx,
    input  wire       ok,
    input  wire       slw,
    input  wire [7:0] st,
    output wire       led,
    output reg        la,
    output reg        lb,
    output wire       mv,
    output reg        fg,
    output reg        ih,
    output reg        zh
);
    localparam SMN = (5 * TC) / 2;
    localparam SMX = 8 * TC;
    localparam IMN  = (5 * TC) / 4;
    localparam ITH  = 3 * TC;
    localparam IMX  = (11 * TC) / 2;
    localparam TOC  = 7 * TC;
    localparam [3:0] TZ = 4'd1, TI = 4'd2, TU = 4'd3, TL = 4'd4, TK = 4'd5;
    reg        mvr;
    reg [12:0] mcn;
    reg [3:0]  lcn;
    reg [9:0]  msc;
    reg        r1, r2, r3;
    assign mv = mvr;
    reg ef;
    always @(negedge ck or negedge rn) begin
        if (!rn) ef <= 1'b1;
        else        ef <= ~mvr;
    end
    wire cf = ck & ef;
    localparam [1:0] SI = 2'd0, SW = 2'd1, SR = 2'd2;
    reg [1:0]  ds;
    reg [9:0]  hc, sn;
    reg [5:0]  nb;
    reg [47:0] sh;
    reg        fr;
    reg        sl, sel, unl, kh;
    reg        lo;
    reg [1:0]  bk;
    reg        ph;
    reg [9:0]  bc;
    reg [4:0]  zl;
    reg [7:0]  zx, zy, gp;
    reg [15:0] m0, m1, m2, m3, m4, m5, m6, m7;
    wire rs = r2 & ~r3;
    wire fl = ~r2 & r3;
    wire mt = (msc >= (slw ? MS - 1 : MC - 1));
    wire [3:0]  ft = sh[47:44];
    wire [31:0] fa = sh[43:12];
    wire [7:0]  fc  = sh[11:4];
    wire [3:0]  pr = sh[47:44] ^ sh[43:40] ^ sh[39:36] ^ sh[35:32] ^ sh[31:28] ^ sh[27:24] ^ sh[23:20] ^ sh[19:16]
                    ^ sh[15:12] ^ sh[11:8] ^ sh[7:4];
    wire        po = (pr == sh[3:0]);
    wire [31:0] mid = {IDR, st};
    wire        hid = (fa == mid) || (fa == 32'hFFFFFFFF);
    wire [4:0]  al = fa[31:27];
    wire [7:0]  ax     = fa[26:19];
    wire [7:0]  ay     = fa[18:11];
    wire [7:0]  ag   = fa[10:3];
    wire        wl = fa[2], wx = fa[1], wy = fa[0];
    wire        hz = (wl || al == zl) && (wx || ax == zx) && (wy || ay == zy)
                           && (ag == 8'hFF || ag == gp);
    reg [15:0] msl;
    always @* begin
        case (fc[2:0])
            3'd0: msl = m0; 3'd1: msl = m1; 3'd2: msl = m2; 3'd3: msl = m3;
            3'd4: msl = m4; 3'd5: msl = m5; 3'd6: msl = m6; default: msl = m7;
        endcase
    end
    wire lbz = (lcn != 4'd0);
    wire ht        = (ft == TZ) ? hz : hid;
    wire ao     = ht && (!sl || fc == 8'h02);
    wire cn    = fr && po && (ft == TZ || ft == TI) && ao;
    wire sm  = cn && (fc[7:3] == 5'b01000) && ok && (msl[12:0] != 13'd0);
    wire sa     = cn && (fc == 8'h21) && !lbz;
    wire sb     = cn && (fc == 8'h22) && !lbz;
    assign led = lo & ok & ~mvr & ((bk == 2'd0) | ph);
    always @(posedge ck or negedge rn) begin
        if (!rn) begin
            r1 <= 1'b0; r2 <= 1'b0; r3 <= 1'b0;
            mvr <= 1'b0; mcn <= 13'd0; lcn <= 4'd0; la <= 1'b0; lb <= 1'b0; msc <= 10'd0;
        end else begin
            r1 <= rx; r2 <= r1; r3 <= r2;
            if (mt) msc <= 10'd0; else msc <= msc + 10'd1;
            if (mvr && mt) begin
                if (mcn <= 13'd1) mvr <= 1'b0;
                mcn <= mcn - 13'd1;
            end
            if (sm) begin mvr <= 1'b1; mcn <= msl[12:0]; msc <= 10'd0; end
            if (lbz && mt) begin
                lcn <= lcn - 4'd1;
                if (lcn == 4'd1) begin la <= 1'b0; lb <= 1'b0; end
            end
            if (sa) begin la <= 1'b1; lcn <= LM; msc <= 10'd0; end
            if (sb) begin lb <= 1'b1; lcn <= LM; msc <= 10'd0; end
        end
    end
    always @(posedge cf or negedge rn) begin
        if (!rn) begin
            ds <= SI; hc <= 10'd0; sn <= 10'd0; nb <= 6'd0; sh <= 48'd0; fr <= 1'b0;
            sl <= 1'b0; sel <= 1'b0; unl <= 1'b0; kh <= 1'b0;
            lo <= 1'b0; bk <= 2'd0; ph <= 1'b0; bc <= 10'd0;
            zl <= 5'd0; zx <= 8'd0; zy <= 8'd0; gp <= 8'd0;
            m0 <= 16'd0; m1 <= 16'd0; m2 <= 16'd0; m3 <= 16'd0; m4 <= 16'd0; m5 <= 16'd0; m6 <= 16'd0; m7 <= 16'd0;
            fg <= 1'b0; ih <= 1'b0; zh <= 1'b0;
        end else begin
            fr  <= 1'b0;
            fg <= 1'b0;
            case (ds)
                SI: begin
                    if (r2 && hc != 10'h3FF) hc <= hc + 10'd1;
                    if (fl) begin
                        if (hc >= SMN && hc <= SMX) begin ds <= SW; sn <= 10'd0; end
                        hc <= 10'd0;
                    end
                end
                SW: begin
                    sn <= sn + 10'd1;
                    if (rs) begin ds <= SR; sn <= 10'd1; nb <= 6'd0; end
                    else if (sn >= TOC) ds <= SI;
                end
                SR: begin
                    sn <= sn + 10'd1;
                    if (rs) begin
                        if (sn >= IMN && sn <= IMX) begin
                            sh <= {sh[46:0], (sn >= ITH)};
                            sn <= 10'd1;
                            nb <= nb + 6'd1;
                            if (nb == 6'd47) begin fr <= 1'b1; ds <= SI; end
                        end else ds <= SI;
                    end else if (sn >= TOC) ds <= SI;
                end
                default: ds <= SI;
            endcase
            if (bk == 2'd0) begin bc <= 10'd0; ph <= 1'b1; end
            else if (mt) begin
                if (bc == ((bk == 2'd1) ? 10'd499 : 10'd124)) begin bc <= 10'd0; ph <= ~ph; end
                else bc <= bc + 10'd1;
            end
            if (fr && po) begin
                fg <= 1'b1;
                if (ft != TU) kh <= 1'b0;
                case (ft)
                    TZ, TI: begin
                        if (ft == TI) ih <= hid; else zh <= hz;
                        if (fc == 8'h04) sel <= ht;
                        if (ao) begin
                            case (fc)
                                8'h01: sl <= 1'b1;
                                8'h02: sl <= 1'b0;
                                8'h05: sel <= 1'b0;
                                8'h10: begin lo <= 1'b0; bk <= 2'd0; end
                                8'h11: begin lo <= 1'b1; bk <= 2'd0; end
                                8'h12: begin lo <= 1'b1; bk <= 2'd1; end
                                8'h13: begin lo <= 1'b1; bk <= 2'd2; end
                                default: ;
                            endcase
                        end
                    end
                    TU: begin
                        if (fc == 8'h00) kh <= (fa == KEY[63:32]);
                        else if (fc == 8'h01) begin
                            if (kh && fa == KEY[31:0]) unl <= 1'b1;
                            kh <= 1'b0;
                        end else kh <= 1'b0;
                    end
                    TL: begin
                        if (unl && sel) begin
                            if (fa[31:24] == 8'h01) begin zl <= fa[20:16]; zx <= fa[15:8]; zy <= fa[7:0]; end
                            else if (fa[31:24] == 8'h02) gp <= fa[7:0];
                            else if (fa[31:27] == 5'b00010) begin
                                case (fa[26:24])
                                    3'd0: m0 <= fa[15:0]; 3'd1: m1 <= fa[15:0]; 3'd2: m2 <= fa[15:0]; 3'd3: m3 <= fa[15:0];
                                    3'd4: m4 <= fa[15:0]; 3'd5: m5 <= fa[15:0]; 3'd6: m6 <= fa[15:0]; default: m7 <= fa[15:0];
                                endcase
                            end
                        end
                    end
                    TK: begin unl <= 1'b0; sel <= 1'b0; end
                    default: ;
                endcase
            end
        end
    end
endmodule
`default_nettype wire

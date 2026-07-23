module FP_Adder(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out
);

    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
    wire [23:0] frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};
    
    reg sign_res;
    reg [7:0] exp_res;
    reg [24:0] frac_res; 
    
    reg [23:0] frac_a_aligned, frac_b_aligned;
    reg [7:0] exp_diff;
    
    always @(*) begin
        if (a == 0) begin
            sign_res = sign_b;
            exp_res = exp_b;
            frac_res = {1'b0, frac_b};
        end else if (b == 0) begin
            sign_res = sign_a;
            exp_res = exp_a;
            frac_res = {1'b0, frac_a};
        end else begin
            if (exp_a > exp_b) begin
                exp_diff = exp_a - exp_b;
                frac_a_aligned = frac_a;
                frac_b_aligned = frac_b >> exp_diff;
                exp_res = exp_a;
                sign_res = sign_a;
            end else if (exp_a < exp_b) begin
                exp_diff = exp_b - exp_a;
                frac_a_aligned = frac_a >> exp_diff;
                frac_b_aligned = frac_b;
                exp_res = exp_b;
                sign_res = sign_b;
            end else begin
                frac_a_aligned = frac_a;
                frac_b_aligned = frac_b;
                exp_res = exp_a;
                if (frac_a >= frac_b) sign_res = sign_a;
                else sign_res = sign_b;
            end
            
            if (sign_a == sign_b) begin
                frac_res = frac_a_aligned + frac_b_aligned;
            end else begin
                if (frac_a_aligned >= frac_b_aligned) begin
                    frac_res = frac_a_aligned - frac_b_aligned;
                end else begin
                    frac_res = frac_b_aligned - frac_a_aligned;
                end
            end
            
            if (frac_res[24]) begin
                frac_res = frac_res >> 1;
                exp_res = exp_res + 1;
            end else if (frac_res[23] == 0) begin
                if (frac_res[22]) begin frac_res = frac_res << 1; exp_res = exp_res - 1; end
                else if (frac_res[21]) begin frac_res = frac_res << 2; exp_res = exp_res - 2; end
                else if (frac_res[20]) begin frac_res = frac_res << 3; exp_res = exp_res - 3; end
                else if (frac_res[19]) begin frac_res = frac_res << 4; exp_res = exp_res - 4; end
                else if (frac_res[18]) begin frac_res = frac_res << 5; exp_res = exp_res - 5; end
                else if (frac_res[17]) begin frac_res = frac_res << 6; exp_res = exp_res - 6; end
                else if (frac_res[16]) begin frac_res = frac_res << 7; exp_res = exp_res - 7; end
                else if (frac_res[15]) begin frac_res = frac_res << 8; exp_res = exp_res - 8; end
                else if (frac_res[14]) begin frac_res = frac_res << 9; exp_res = exp_res - 9; end
                else if (frac_res[13]) begin frac_res = frac_res << 10; exp_res = exp_res - 10; end
                else if (frac_res[12]) begin frac_res = frac_res << 11; exp_res = exp_res - 11; end
                else if (frac_res[11]) begin frac_res = frac_res << 12; exp_res = exp_res - 12; end
                else if (frac_res[10]) begin frac_res = frac_res << 13; exp_res = exp_res - 13; end
                else if (frac_res[9]) begin frac_res = frac_res << 14; exp_res = exp_res - 14; end
                else if (frac_res[8]) begin frac_res = frac_res << 15; exp_res = exp_res - 15; end
                else if (frac_res[7]) begin frac_res = frac_res << 16; exp_res = exp_res - 16; end
                else if (frac_res[6]) begin frac_res = frac_res << 17; exp_res = exp_res - 17; end
                else if (frac_res[5]) begin frac_res = frac_res << 18; exp_res = exp_res - 18; end
                else if (frac_res[4]) begin frac_res = frac_res << 19; exp_res = exp_res - 19; end
                else if (frac_res[3]) begin frac_res = frac_res << 20; exp_res = exp_res - 20; end
                else if (frac_res[2]) begin frac_res = frac_res << 21; exp_res = exp_res - 21; end
                else if (frac_res[1]) begin frac_res = frac_res << 22; exp_res = exp_res - 22; end
                else if (frac_res[0]) begin frac_res = frac_res << 23; exp_res = exp_res - 23; end
                else begin exp_res = 0; frac_res = 0; sign_res = 0; end
            end
        end
    end
    
    assign out = (exp_res == 0 && frac_res == 0) ? 32'b0 : {sign_res, exp_res, frac_res[22:0]};

endmodule
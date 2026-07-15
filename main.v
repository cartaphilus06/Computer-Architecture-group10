module main (
    input Clk,
    input Rst,
    input [31:0] InstrIn,
    input [31:0] DataIn,
    output [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31,
    output [31:0] InstrAddr,
    output [31:0] DataAddr,
    output DataWrite,
    output [31:0] DataOut,
    output [31:0] D_PC,
    output [31:0] D_Instr,
    output D_Valid,
    output [31:0] D_Rs,
    output D_RsValid,
    output [31:0] D_Rt,
    output D_RtValid,
    output [15:0] D_Imm,
    output D_ImmValid,
    output [25:0] D_Address,
    output D_AddressValid,
    output [31:0] E_PC,
    output [31:0] E_Instr,
    output E_Valid,
    output E_ResValid,
    output [31:0] E_Res,
    output [31:0] W_PC,
    output [31:0] W_Instr,
    output W_Valid
);

    reg [31:0] registers [0:31];
    reg [31:0] F_PC;

    reg D_Valid_reg;
    reg [31:0] D_PC_reg;
    reg [31:0] D_Instr_reg;

    reg E_Valid_reg;
    reg [31:0] E_PC_reg, E_Instr_reg;
    reg [31:0] E_Rs_val, E_Rt_val;
    reg [15:0] E_Imm_reg;
    reg [4:0] E_rs_idx, E_rt_idx, E_rd_idx;
    reg [5:0] E_opcode, E_funct;
    reg E_RegDst_reg, E_ALUSrc_reg, E_RegWrite_reg, E_MemRead_reg, E_MemWrite_reg, E_Branch_reg, E_Jal_reg;
    reg [1:0] E_MemtoReg_reg;

    reg M_Valid_reg;
    reg [31:0] M_PC_reg, M_Instr_reg;
    reg [31:0] M_BranchTarget_reg, M_ALUOut_reg, M_Rt_val_reg;
    reg [4:0] M_DestReg_reg;
    reg M_RegWrite_reg, M_MemRead_reg, M_MemWrite_reg, M_Branch_reg, M_Zero_reg;
    reg [1:0] M_MemtoReg_reg;

    reg W_Valid_reg;
    reg [31:0] W_PC_reg, W_Instr_reg;
    reg [31:0] W_MemData_reg, W_ALUOut_reg;
    reg [4:0] W_DestReg_reg;
    reg W_RegWrite_reg;
    reg [1:0] W_MemtoReg_reg;

    wire [31:0] W_WriteData = (W_MemtoReg_reg == 2'd2) ? W_PC_reg + 32'd4 :
                              (W_MemtoReg_reg == 2'd1) ? W_MemData_reg :
                              W_ALUOut_reg;

    assign R0 = 32'b0;
    assign R1 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd1) ? W_WriteData : registers[1];
    assign R2 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd2) ? W_WriteData : registers[2];
    assign R3 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd3) ? W_WriteData : registers[3];
    assign R4 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd4) ? W_WriteData : registers[4];
    assign R5 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd5) ? W_WriteData : registers[5];
    assign R6 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd6) ? W_WriteData : registers[6];
    assign R7 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd7) ? W_WriteData : registers[7];
    assign R8 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd8) ? W_WriteData : registers[8];
    assign R9 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd9) ? W_WriteData : registers[9];
    assign R10 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd10) ? W_WriteData : registers[10];
    assign R11 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd11) ? W_WriteData : registers[11];
    assign R12 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd12) ? W_WriteData : registers[12];
    assign R13 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd13) ? W_WriteData : registers[13];
    assign R14 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd14) ? W_WriteData : registers[14];
    assign R15 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd15) ? W_WriteData : registers[15];
    assign R16 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd16) ? W_WriteData : registers[16];
    assign R17 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd17) ? W_WriteData : registers[17];
    assign R18 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd18) ? W_WriteData : registers[18];
    assign R19 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd19) ? W_WriteData : registers[19];
    assign R20 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd20) ? W_WriteData : registers[20];
    assign R21 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd21) ? W_WriteData : registers[21];
    assign R22 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd22) ? W_WriteData : registers[22];
    assign R23 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd23) ? W_WriteData : registers[23];
    assign R24 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd24) ? W_WriteData : registers[24];
    assign R25 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd25) ? W_WriteData : registers[25];
    assign R26 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd26) ? W_WriteData : registers[26];
    assign R27 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd27) ? W_WriteData : registers[27];
    assign R28 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd28) ? W_WriteData : registers[28];
    assign R29 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd29) ? W_WriteData : registers[29];
    assign R30 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd30) ? W_WriteData : registers[30];
    assign R31 = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == 5'd31) ? W_WriteData : registers[31];

    wire [5:0] D_opcode = D_Instr_reg[31:26];
    wire [4:0] D_rs_idx = D_Instr_reg[25:21];
    wire [4:0] D_rt_idx = D_Instr_reg[20:16];
    wire [4:0] D_rd_idx = D_Instr_reg[15:11];
    wire [5:0] D_funct = D_Instr_reg[5:0];
    wire [15:0] D_imm_val = D_Instr_reg[15:0];
    wire [25:0] D_address_val = D_Instr_reg[25:0];

    wire is_r_type = (D_opcode == 6'b000000);
    wire is_lw = (D_opcode == 6'b100011);
    wire is_sw = (D_opcode == 6'b101011);
    wire is_addi = (D_opcode == 6'b001000);
    wire is_subi = (D_opcode == 6'b001001);
    wire is_lui = (D_opcode == 6'b001111);
    wire is_beq = (D_opcode == 6'b000100);
    wire is_j = (D_opcode == 6'b000010);
    wire is_jal = (D_opcode == 6'b000011);
    wire is_jr = is_r_type & (D_funct == 6'b001000);

    wire D_RegWrite = (is_r_type & ~is_jr) | is_lw | is_addi | is_subi | is_lui | is_jal;
    wire D_MemRead = is_lw;
    wire D_MemWrite = is_sw;
    wire D_ALUSrc = is_lw | is_sw | is_addi | is_subi | is_lui;
    wire D_RegDst = is_r_type;
    wire D_Branch = is_beq;
    wire D_Jump = is_j | is_jal | is_jr;
    wire D_Jal = is_jal;
    wire [1:0] D_MemtoReg = is_jal ? 2'd2 : is_lw ? 2'd1 : 2'd0;

    wire [31:0] D_Rs_val_comb = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == D_rs_idx && D_rs_idx != 5'd0) ? W_WriteData : registers[D_rs_idx];
    wire [31:0] D_Rt_val_comb = (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg == D_rt_idx && D_rt_idx != 5'd0) ? W_WriteData : registers[D_rt_idx];

    assign D_PC = {2'b00, D_PC_reg[31:2]};
    assign D_Instr = D_Instr_reg;
    assign D_Valid = D_Valid_reg;
    assign D_Rs = D_Rs_val_comb;
    assign D_RsValid = is_r_type | is_lw | is_sw | is_addi | is_subi | is_beq;
    assign D_Rt = D_Rt_val_comb;
    assign D_RtValid = (is_r_type & ~is_jr) | is_sw | is_beq;
    assign D_Imm = D_imm_val;
    assign D_ImmValid = is_lw | is_sw | is_addi | is_subi | is_lui | is_beq;
    assign D_Address = D_address_val;
    assign D_AddressValid = is_j | is_jal;

    wire [31:0] D_PC_plus_4 = D_PC_reg + 32'd4;
    wire [31:0] D_JumpTarget = is_jr ? D_Rs_val_comb : {D_PC_plus_4[31:28], D_address_val, 2'b00};

    wire [4:0] E_DestReg = E_Jal_reg ? 5'd31 : (E_RegDst_reg ? E_rd_idx : E_rt_idx);

    wire D_depends_rs = D_RsValid & (D_rs_idx != 5'd0);
    wire D_depends_rt = D_RtValid & (D_rt_idx != 5'd0);

    wire E_writes_rs = E_RegWrite_reg & (E_DestReg == D_rs_idx) & E_Valid_reg & (D_rs_idx != 5'd0);
    wire M_writes_rs = M_RegWrite_reg & (M_DestReg_reg == D_rs_idx) & M_Valid_reg & (D_rs_idx != 5'd0);

    wire E_writes_rt = E_RegWrite_reg & (E_DestReg == D_rt_idx) & E_Valid_reg & (D_rt_idx != 5'd0);
    wire M_writes_rt = M_RegWrite_reg & (M_DestReg_reg == D_rt_idx) & M_Valid_reg & (D_rt_idx != 5'd0);

    wire data_stall = (D_depends_rs & (E_writes_rs | M_writes_rs)) |
                      (D_depends_rt & (E_writes_rt | M_writes_rt));

    wire E_is_r_type = (E_opcode == 6'b000000);
    wire E_is_add = E_is_r_type & (E_funct == 6'b100000);
    wire E_is_sub = E_is_r_type & (E_funct == 6'b100010);
    wire E_is_mul = E_is_r_type & (E_funct == 6'b011000);
    wire E_is_div = E_is_r_type & (E_funct == 6'b011010);
    wire E_is_lui = (E_opcode == 6'b001111);
    wire E_is_lw = (E_opcode == 6'b100011);
    wire E_is_sw = (E_opcode == 6'b101011);
    wire E_is_addi = (E_opcode == 6'b001000);
    wire E_is_subi = (E_opcode == 6'b001001);

    wire [31:0] sign_ext_imm = {{16{E_Imm_reg[15]}}, E_Imm_reg};
    wire [31:0] alu_in1 = E_Rs_val;
    wire [31:0] alu_in2 = E_ALUSrc_reg ? sign_ext_imm : E_Rt_val;

    reg [31:0] E_alu_result;
    reg E_alu_zero;

    always @(*) begin
        E_alu_result = 32'b0;
        E_alu_zero = 1'b0;

        if (E_is_add | E_is_lw | E_is_sw | E_is_addi) begin
            E_alu_result = alu_in1 + alu_in2;
        end else if (E_is_sub | E_Branch_reg | E_is_subi) begin
            E_alu_result = alu_in1 - alu_in2;
            if (E_alu_result == 32'b0) E_alu_zero = 1'b1;
        end else if (E_is_lui) begin
            E_alu_result = {E_Imm_reg, 16'b0};
        end else if (E_is_mul) begin
            E_alu_result = alu_in1 * alu_in2;
        end else if (E_is_div) begin
            E_alu_result = (alu_in2 != 32'b0) ? (alu_in1 / alu_in2) : 32'b0;
        end
    end

    reg [5:0] mul_div_counter;
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            mul_div_counter <= 6'b0;
        end else begin
            if ((E_is_mul | E_is_div) && E_Valid_reg && mul_div_counter != 6'd31) begin
                mul_div_counter <= mul_div_counter + 6'd1;
            end else begin
                mul_div_counter <= 6'b0;
            end
        end
    end

    wire E_stall_req = (E_is_mul | E_is_div) & E_Valid_reg & (mul_div_counter != 6'd31);
    wire E_BranchTaken = E_Branch_reg & E_alu_zero & E_Valid_reg;
    wire [31:0] E_BranchTarget = E_PC_reg + 32'd4 + (sign_ext_imm << 2);

    assign E_PC = {2'b00, E_PC_reg[31:2]};
    assign E_Instr = E_Instr_reg;
    assign E_Valid = E_Valid_reg;
    assign E_ResValid = E_Valid_reg & (E_RegWrite_reg | E_MemWrite_reg | E_MemRead_reg | E_Branch_reg);
    assign E_Res = E_alu_result;

    wire stall_E = E_stall_req;
    wire stall_D = data_stall | stall_E;

    assign W_PC = {2'b00, W_PC_reg[31:2]};
    assign W_Instr = W_Instr_reg;
    assign W_Valid = W_Valid_reg;

    assign InstrAddr = {2'b00, F_PC[31:2]};

    integer j;
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            F_PC <= 32'b0;
            
            D_Valid_reg <= 1'b0;
            D_PC_reg <= 32'b0;
            D_Instr_reg <= 32'b0;

            E_Valid_reg <= 1'b0;
            E_PC_reg <= 32'b0;
            E_Instr_reg <= 32'b0;
            E_Rs_val <= 32'b0;
            E_Rt_val <= 32'b0;
            E_Imm_reg <= 16'b0;
            E_rs_idx <= 5'b0;
            E_rt_idx <= 5'b0;
            E_rd_idx <= 5'b0;
            E_opcode <= 6'b0;
            E_funct <= 6'b0;
            E_RegDst_reg <= 1'b0;
            E_ALUSrc_reg <= 1'b0;
            E_RegWrite_reg <= 1'b0;
            E_MemRead_reg <= 1'b0;
            E_MemWrite_reg <= 1'b0;
            E_Branch_reg <= 1'b0;
            E_Jal_reg <= 1'b0;
            E_MemtoReg_reg <= 2'b0;

            M_Valid_reg <= 1'b0;
            M_PC_reg <= 32'b0;
            M_Instr_reg <= 32'b0;
            M_BranchTarget_reg <= 32'b0;
            M_ALUOut_reg <= 32'b0;
            M_Rt_val_reg <= 32'b0;
            M_DestReg_reg <= 5'b0;
            M_RegWrite_reg <= 1'b0;
            M_MemRead_reg <= 1'b0;
            M_MemWrite_reg <= 1'b0;
            M_Branch_reg <= 1'b0;
            M_Zero_reg <= 1'b0;
            M_MemtoReg_reg <= 2'b0;

            W_Valid_reg <= 1'b0;
            W_PC_reg <= 32'b0;
            W_Instr_reg <= 32'b0;
            W_MemData_reg <= 32'b0;
            W_ALUOut_reg <= 32'b0;
            W_DestReg_reg <= 5'b0;
            W_RegWrite_reg <= 1'b0;
            W_MemtoReg_reg <= 2'b0;

            for (j = 0; j < 32; j = j + 1) begin
                registers[j] <= 32'b0;
            end
        end else begin
            if (W_RegWrite_reg && W_Valid_reg && W_DestReg_reg != 5'd0) begin
                registers[W_DestReg_reg] <= W_WriteData;
            end

            if (E_BranchTaken) begin
                F_PC <= E_BranchTarget;
            end else if (!stall_D) begin
                if (D_Jump && D_Valid_reg) begin
                    F_PC <= D_JumpTarget;
                end else begin
                    F_PC <= F_PC + 32'd4;
                end
            end

            if (E_BranchTaken) begin
                D_Valid_reg <= 1'b0;
            end else if (stall_D) begin
            end else if (D_Jump && D_Valid_reg) begin
                D_Valid_reg <= 1'b0;
            end else begin
                D_Valid_reg <= 1'b1;
                D_PC_reg <= F_PC;
                D_Instr_reg <= InstrIn;
            end

            if (stall_E) begin
            end else if (stall_D || E_BranchTaken) begin
                E_Valid_reg <= 1'b0;
            end else begin
                E_Valid_reg <= D_Valid_reg;
                E_PC_reg <= D_PC_reg;
                E_Instr_reg <= D_Instr_reg;
                E_Rs_val <= D_Rs_val_comb;
                E_Rt_val <= D_Rt_val_comb;
                E_Imm_reg <= D_imm_val;
                E_rs_idx <= D_rs_idx;
                E_rt_idx <= D_rt_idx;
                E_rd_idx <= D_rd_idx;
                E_opcode <= D_opcode;
                E_funct <= D_funct;
                E_RegDst_reg <= D_RegDst;
                E_ALUSrc_reg <= D_ALUSrc;
                E_RegWrite_reg <= D_RegWrite;
                E_MemRead_reg <= D_MemRead;
                E_MemWrite_reg <= D_MemWrite;
                E_Branch_reg <= D_Branch;
                E_Jal_reg <= D_Jal;
                E_MemtoReg_reg <= D_MemtoReg;
            end

            if (stall_E) begin
                M_Valid_reg <= 1'b0;
            end else begin
                M_Valid_reg <= E_Valid_reg;
                M_PC_reg <= E_PC_reg;
                M_Instr_reg <= E_Instr_reg;
                M_BranchTarget_reg <= E_BranchTarget;
                M_ALUOut_reg <= E_alu_result;
                M_Rt_val_reg <= E_Rt_val;
                M_DestReg_reg <= E_DestReg;
                M_RegWrite_reg <= E_RegWrite_reg;
                M_MemRead_reg <= E_MemRead_reg;
                M_MemWrite_reg <= E_MemWrite_reg;
                M_Branch_reg <= E_Branch_reg;
                M_Zero_reg <= E_alu_zero;
                M_MemtoReg_reg <= E_MemtoReg_reg;
            end

            W_Valid_reg <= M_Valid_reg;
            W_PC_reg <= M_PC_reg;
            W_Instr_reg <= M_Instr_reg;
            W_MemData_reg <= DataIn;
            W_ALUOut_reg <= M_ALUOut_reg;
            W_DestReg_reg <= M_DestReg_reg;
            W_RegWrite_reg <= M_RegWrite_reg;
            W_MemtoReg_reg <= M_MemtoReg_reg;
        end
    end

    assign DataAddr = {2'b00, M_ALUOut_reg[31:2]};
    assign DataWrite = M_MemWrite_reg & M_Valid_reg;
    assign DataOut = M_Rt_val_reg;

endmodule
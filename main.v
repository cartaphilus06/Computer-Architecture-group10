module main(
    input Clk,
    input Rst,
    input [31:0] InstrIn,
    input [31:0] DataIn,
    output [31:0] InstrAddr,
    output [31:0] DataAddr,
    output DataWrite,
    output [31:0] DataOut
);

    reg [31:0] PC;
    reg [31:0] D_PC, D_Instr;
    reg D_Valid;
    reg [31:0] E_PC, E_Instr;
    reg [31:0] E_Rs_val, E_Rt_val, E_Imm_val;
    reg [4:0] E_Dest;
    reg E_RegWrite, E_MemRead, E_MemWrite;
    reg [3:0] E_ALUOp;
    reg E_ALUSrc;
    reg E_Valid;
    reg E_is_vector_reg;
    reg E_is_vsetvl_reg;
    reg [31:0] M_PC, M_Instr, M_ALU_res, M_Rt_val;
    reg [4:0] M_Dest;
    reg M_RegWrite, M_MemRead, M_MemWrite;
    reg M_Valid;
    reg [31:0] W_PC, W_Instr, W_ALU_res, W_Mem_data;
    reg [4:0] W_Dest;
    reg W_RegWrite, W_MemToReg;
    reg W_Valid;
    reg [31:0] Registers [0:31];
    reg [31:0] CSR_VectorLength;

    wire [5:0] D_Opcode = D_Instr[31:26];
    wire [4:0] D_Rs = D_Instr[25:21];
    wire [4:0] D_Rt = D_Instr[20:16];
    wire [4:0] D_Rd = D_Instr[15:11];
    wire [5:0] D_Funct = D_Instr[5:0];
    wire [15:0] D_Imm = D_Instr[15:0];

    wire D_is_R_type = (D_Opcode == 6'b000000);
    wire D_is_I_type = (D_Opcode == 6'b001000 || D_Opcode == 6'b001001 || D_Opcode == 6'b001100 || D_Opcode == 6'b001101 || D_Opcode == 6'b001110);
    wire D_is_load   = (D_Opcode == 6'b100011);
    wire D_is_store  = (D_Opcode == 6'b101011);
    wire D_is_branch = (D_Opcode == 6'b000100 || D_Opcode == 6'b000101);
    
    wire D_is_vector = (D_Opcode == 6'b111011) && (D_Funct != 6'b000100);
    wire D_is_vsetvl = (D_Opcode == 6'b111011) && (D_Funct == 6'b000100);
    wire D_is_vload  = D_is_vector && (D_Funct == 6'b000010);
    wire D_is_vstore = D_is_vector && (D_Funct == 6'b000011);

    wire D_RsValid = D_is_R_type | D_is_I_type | D_is_load | D_is_store | D_is_branch | D_is_vload | D_is_vstore | D_is_vsetvl;
    wire D_RtValid = D_is_R_type | D_is_store | D_is_branch;

    wire hazard = (D_RsValid && ((E_RegWrite && E_Valid && E_Dest == D_Rs && E_Dest != 0) ||
                                 (M_RegWrite && M_Valid && M_Dest == D_Rs && M_Dest != 0) ||
                                 (W_RegWrite && W_Valid && W_Dest == D_Rs && W_Dest != 0))) ||
                  (D_RtValid && ((E_RegWrite && E_Valid && E_Dest == D_Rt && E_Dest != 0) ||
                                 (M_RegWrite && M_Valid && M_Dest == D_Rt && M_Dest != 0) ||
                                 (W_RegWrite && W_Valid && W_Dest == D_Rt && W_Dest != 0)));

    wire VPU_Busy;
    wire VPU_Mem_Busy;
    wire VPU_ALU_Busy;
    wire VPU_Ready;
    wire VPU_Done;
    wire VPU_MemReq_signal;
    wire VPU_MemRead;
    wire VPU_MemWrite;
    wire [31:0] VPU_MemAddr;
    wire [31:0] VPU_MemDataOut;

    wire D_is_vpu_mem = D_is_vload | D_is_vstore;
    wire D_is_vpu_alu = D_is_vector & ~D_is_vpu_mem;
    wire vpu_busy_for_D = (D_is_vpu_mem & VPU_Mem_Busy) | 
                          (D_is_vpu_alu & VPU_ALU_Busy) | 
                          (D_is_vsetvl & (VPU_Mem_Busy | VPU_ALU_Busy));

    wire vpu_stall_req = (D_is_vector | D_is_vsetvl) & (vpu_busy_for_D | (E_is_vector_reg & E_Valid));
    
    wire CPU_MemReq_signal = (M_MemRead | M_MemWrite) & M_Valid;
    wire stall_M = CPU_MemReq_signal & VPU_MemReq_signal;
    wire stall_E = stall_M;
    wire stall_D = hazard | vpu_stall_req | stall_E;
    wire stall_F = stall_D;
    
    wire branch_taken = D_is_branch && D_Valid && (Registers[D_Rs] != Registers[D_Rt]);

    wire [31:0] VPU_BaseAddr = E_Rs_val;
    wire [31:0] VPU_VectorLength = CSR_VectorLength;
    wire [5:0] VPU_Opcode = E_Instr[5:0];
    wire [4:0] vd_idx = E_Instr[15:11];
    wire [4:0] vs1_idx = E_Instr[25:21];
    wire [4:0] vs2_idx = E_Instr[20:16];
    wire VPU_Start = E_is_vector_reg & E_Valid & ~stall_M;

    integer i;

    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            PC <= 0;
            D_Valid <= 0;
            E_Valid <= 0;
            M_Valid <= 0;
            W_Valid <= 0;
            CSR_VectorLength <= 8;
            for (i=0; i<32; i=i+1) Registers[i] <= 0;
        end else begin
            if (W_Valid && W_RegWrite && W_Dest != 0) begin
                Registers[W_Dest] <= W_MemToReg ? W_Mem_data : W_ALU_res;
            end
            
            if (!stall_F) begin
                if (branch_taken) begin
                    PC <= D_PC + 4 + {{14{D_Imm[15]}}, D_Imm, 2'b00};
                    D_Valid <= 0;
                end else begin
                    PC <= PC + 4;
                    D_PC <= PC;
                    D_Instr <= InstrIn;
                    D_Valid <= 1;
                end
            end
            
            if (!stall_E) begin
                if (stall_D || branch_taken) begin
                    E_Valid <= 0;
                    E_is_vector_reg <= 0;
                    E_is_vsetvl_reg <= 0;
                end else begin
                    E_PC <= D_PC;
                    E_Instr <= D_Instr;
                    E_Rs_val <= Registers[D_Rs];
                    E_Rt_val <= Registers[D_Rt];
                    E_Imm_val <= {{16{D_Imm[15]}}, D_Imm};
                    E_Dest <= D_is_R_type ? D_Rd : D_Rt;
                    E_RegWrite <= D_is_R_type | D_is_I_type | D_is_load;
                    E_MemRead <= D_is_load;
                    E_MemWrite <= D_is_store;
                    E_ALUSrc <= D_is_I_type | D_is_load | D_is_store;
                    if (D_is_R_type) E_ALUOp <= 4'b0010;
                    else if (D_is_branch) E_ALUOp <= 4'b0110;
                    else E_ALUOp <= 4'b0000;
                    E_is_vector_reg <= D_is_vector;
                    E_is_vsetvl_reg <= D_is_vsetvl;
                    E_Valid <= D_Valid;
                end
            end
            
            if (!stall_M) begin
                if (E_is_vsetvl_reg && E_Valid) begin
                    CSR_VectorLength <= E_Rs_val;
                end
                M_PC <= E_PC;
                M_Instr <= E_Instr;
                M_ALU_res <= (E_ALUOp == 4'b0010) ? (E_Rs_val + E_Rt_val) : (E_Rs_val + (E_ALUSrc ? E_Imm_val : E_Rt_val));
                M_Rt_val <= E_Rt_val;
                M_Dest <= E_Dest;
                M_RegWrite <= E_RegWrite;
                M_MemRead <= E_MemRead;
                M_MemWrite <= E_MemWrite;
                M_Valid <= E_Valid & ~E_is_vector_reg & ~E_is_vsetvl_reg;
            end
            
            if (stall_M) begin
                W_Valid <= 0;
                W_RegWrite <= 0;
            end else begin
                W_PC <= M_PC;
                W_Instr <= M_Instr;
                W_ALU_res <= M_ALU_res;
                W_Mem_data <= DataIn;
                W_Dest <= M_Dest;
                W_RegWrite <= M_RegWrite;
                W_MemToReg <= M_MemRead;
                W_Valid <= M_Valid;
            end
        end
    end
    
    assign InstrAddr = PC;
    assign DataAddr = VPU_MemReq_signal ? VPU_MemAddr : M_ALU_res;
    assign DataWrite = VPU_MemReq_signal ? VPU_MemWrite : (M_MemWrite & M_Valid & ~stall_M);
    assign DataOut = VPU_MemReq_signal ? VPU_MemDataOut : M_Rt_val;

    VPU_Core vpu_inst (
        .Clk(Clk),
        .Rst(Rst),
        .VPU_Start(VPU_Start),
        .BaseAddr(VPU_BaseAddr),
        .VectorLength(VPU_VectorLength),
        .Opcode(VPU_Opcode),
        .vd_idx(vd_idx),
        .vs1_idx(vs1_idx),
        .vs2_idx(vs2_idx),
        .MemDataIn(DataIn),
        .VPU_Busy(VPU_Busy),
        .VPU_Mem_Busy(VPU_Mem_Busy),
        .VPU_ALU_Busy(VPU_ALU_Busy),
        .VPU_Ready(VPU_Ready),
        .VPU_Done(VPU_Done),
        .MemRead(VPU_MemRead),
        .MemWrite(VPU_MemWrite),
        .MemAddr(VPU_MemAddr),
        .MemDataOut(VPU_MemDataOut)
    );
    
    assign VPU_MemReq_signal = VPU_MemRead | VPU_MemWrite;

endmodule
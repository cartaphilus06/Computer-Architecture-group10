module VPU_Core(
    input Clk,
    input Rst,
    input VPU_Start,
    input [31:0] BaseAddr,
    input [31:0] VectorLength,
    input [5:0] Opcode,
    input [4:0] vd_idx,
    input [4:0] vs1_idx,
    input [4:0] vs2_idx,
    input [31:0] MemDataIn,
    output VPU_Busy,
    output VPU_Mem_Busy,
    output VPU_ALU_Busy,
    output reg VPU_Ready,
    output reg VPU_Done,
    output reg MemRead,
    output reg MemWrite,
    output reg [31:0] MemAddr,
    output reg [31:0] MemDataOut
);

    reg [31:0] vector_registers [0:2047];
    
    reg mem_busy;
    reg alu_busy;
    reg [31:0] mem_counter;
    reg [31:0] alu_counter;
    
    reg [5:0] mem_opcode;
    reg [2:0] mem_vd;
    reg [31:0] mem_vl;
    reg [31:0] mem_base_addr;
    
    reg [5:0] alu_opcode;
    reg [2:0] alu_vd;
    reg [2:0] alu_vs1;
    reg [2:0] alu_vs2;
    reg [31:0] alu_vl;

    assign VPU_Mem_Busy = mem_busy;
    assign VPU_ALU_Busy = alu_busy;
    assign VPU_Busy = mem_busy | alu_busy;

    wire is_mem_inst = (Opcode == 6'b000010 || Opcode == 6'b000011);
    wire is_alu_inst = (Opcode == 6'b000000 || Opcode == 6'b000001 || Opcode == 6'b000101);

    wire mem_is_vload = (mem_opcode == 6'b000010);
    wire dependency_vs1 = mem_busy && mem_is_vload && (mem_vd == alu_vs1);
    wire dependency_vs2 = mem_busy && mem_is_vload && (mem_vd == alu_vs2);
    wire dependency_vd  = mem_busy && mem_is_vload && (mem_vd == alu_vd);
    
    wire alu_must_stall = (dependency_vs1 | dependency_vs2 | dependency_vd) && (mem_counter <= alu_counter);

    wire [31:0] fpu_in_a = vector_registers[{alu_vs1, alu_counter[7:0]}];
    wire [31:0] fpu_in_b = vector_registers[{alu_vs2, alu_counter[7:0]}];
    wire [31:0] fpu_out;
    
    FP_Adder fpu_unit(
        .a(fpu_in_a),
        .b(fpu_in_b),
        .out(fpu_out)
    );

    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            mem_busy <= 0;
            alu_busy <= 0;
            mem_counter <= 0;
            alu_counter <= 0;
            VPU_Done <= 0;
            VPU_Ready <= 1;
            mem_opcode <= 0; mem_vd <= 0; mem_vl <= 0; mem_base_addr <= 0;
            alu_opcode <= 0; alu_vd <= 0; alu_vs1 <= 0; alu_vs2 <= 0; alu_vl <= 0;
        end else begin
            VPU_Done <= 0;
            VPU_Ready <= ~(mem_busy & alu_busy); 

            if (VPU_Start && VectorLength > 0) begin
                if (is_mem_inst && !mem_busy) begin
                    mem_busy <= 1;
                    mem_counter <= 0;
                    mem_opcode <= Opcode;
                    mem_vd <= vd_idx[2:0];
                    mem_vl <= VectorLength;
                    mem_base_addr <= BaseAddr;
                end else if (is_alu_inst && !alu_busy) begin
                    alu_busy <= 1;
                    alu_counter <= 0;
                    alu_opcode <= Opcode;
                    alu_vd <= vd_idx[2:0];
                    alu_vs1 <= vs1_idx[2:0];
                    alu_vs2 <= vs2_idx[2:0];
                    alu_vl <= VectorLength;
                end
            end

            if (mem_busy) begin
                if (mem_opcode == 6'b000010) begin 
                    vector_registers[{mem_vd, mem_counter[7:0]}] <= MemDataIn;
                end

                if (mem_counter == mem_vl - 1) begin
                    mem_busy <= 0;
                    VPU_Done <= 1;
                end else begin
                    mem_counter <= mem_counter + 1;
                end
            end

            if (alu_busy) begin
                if (!alu_must_stall) begin 
                    if (alu_opcode == 6'b000000) begin 
                        vector_registers[{alu_vd, alu_counter[7:0]}] <= fpu_in_a + fpu_in_b;
                    end else if (alu_opcode == 6'b000001) begin 
                        vector_registers[{alu_vd, alu_counter[7:0]}] <= fpu_in_a * fpu_in_b;
                    end else if (alu_opcode == 6'b000101) begin 
                        vector_registers[{alu_vd, alu_counter[7:0]}] <= fpu_out;
                    end

                    if (alu_counter == alu_vl - 1) begin
                        alu_busy <= 0;
                        VPU_Done <= 1;
                    end else begin
                        alu_counter <= alu_counter + 1;
                    end
                end
            end
        end
    end

    always @(*) begin
        MemRead = 0;
        MemWrite = 0;
        MemAddr = 0;
        MemDataOut = 0;
        if (mem_busy) begin
            if (mem_opcode == 6'b000010) begin 
                MemRead = 1;
                MemAddr = mem_base_addr + (mem_counter << 2);
            end else if (mem_opcode == 6'b000011) begin 
                MemWrite = 1;
                MemAddr = mem_base_addr + (mem_counter << 2);
                MemDataOut = vector_registers[{mem_vd, mem_counter[7:0]}];
            end
        end
    end

endmodule
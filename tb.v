module tb;

    reg Clk;
    reg Rst;
    
    reg [31:0] InstMem [0:255];
    reg [31:0] DataMem [0:4095];
    
    wire [31:0] InstrAddr;
    wire [31:0] DataAddr;
    wire DataWrite;
    wire [31:0] DataOut;
    
    wire [31:0] InstrIn = InstMem[InstrAddr >> 2];
    wire [31:0] DataIn = DataMem[DataAddr >> 2];
    
    integer i;
    integer scalar_cycles = 0;
    integer vector_cycles = 0;
    integer total_cycles = 0;
    real speedup;

    main uut (
        .Clk(Clk),
        .Rst(Rst),
        .InstrIn(InstrIn),
        .DataIn(DataIn),
        .InstrAddr(InstrAddr),
        .DataAddr(DataAddr),
        .DataWrite(DataWrite),
        .DataOut(DataOut)
    );

    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end

    initial begin
        scalar_cycles = 0;
        vector_cycles = 0;
        total_cycles = 0;
        
        for(i = 0; i < 256; i = i + 1) InstMem[i] = 0;
        for(i = 0; i < 4096; i = i + 1) DataMem[i] = 0;

        for(i = 0; i < 256; i = i + 1) begin
            DataMem[i] = i + 1;             
            DataMem[256 + i] = (i + 1) * 10; 
        end
        
        DataMem[1536] = 32'h40200000; 
        DataMem[1537] = 32'h40A00000; 

        InstMem[0] = 32'h00000820; 
        InstMem[1] = 32'h00001020; 
        InstMem[2] = 32'h20030400; 
        InstMem[3] = 32'h20040800; 
        InstMem[4] = 32'h20050100; 
        InstMem[5] = 32'h8c460000; 
        InstMem[6] = 32'h8c670000; 
        InstMem[7] = 32'h00c74020; 
        InstMem[8] = 32'h01064020; 
        InstMem[9] = 32'h01074020; 
        InstMem[10]= 32'h01064020; 
        InstMem[11]= 32'h01074020; 
        InstMem[12]= 32'h01064020; 
        InstMem[13]= 32'h01074020; 
        InstMem[14]= 32'h01064020; 
        InstMem[15]= 32'h01074020; 
        InstMem[16]= 32'h01064020; 
        InstMem[17]= 32'h01074020; 
        InstMem[18]= 32'h01064020; 
        InstMem[19]= 32'h01074020; 
        InstMem[20]= 32'hac880000; 
        InstMem[21]= 32'h20420004; 
        InstMem[22]= 32'h20630004; 
        InstMem[23]= 32'h20840004; 
        InstMem[24]= 32'h20210001; 
        InstMem[25]= 32'h1425FFEB; 

        InstMem[26] = 32'h20010100; 
        InstMem[27] = 32'hEC200004; 
        InstMem[28] = 32'h00001020; 
        InstMem[29] = 32'hEC400002; 
        InstMem[30] = 32'h20030400; 
        InstMem[31] = 32'hEC600802; 
        InstMem[32] = 32'hEC011000; 
        InstMem[33] = 32'hEC401000; 
        InstMem[34] = 32'hEC411000; 
        InstMem[35] = 32'hEC401000; 
        InstMem[36] = 32'hEC411000; 
        InstMem[37] = 32'hEC401000; 
        InstMem[38] = 32'hEC411000; 
        InstMem[39] = 32'hEC401000; 
        InstMem[40] = 32'hEC411000; 
        InstMem[41] = 32'hEC401000; 
        InstMem[42] = 32'hEC411000; 
        InstMem[43] = 32'hEC401000; 
        InstMem[44] = 32'hEC411000; 
        InstMem[45] = 32'h20040C00; 
        InstMem[46] = 32'hEC801003; 

        InstMem[47] = 32'hEC011801; 
        InstMem[48] = 32'h20051000; 
        InstMem[49] = 32'hECA01803; 

        InstMem[50] = 32'h20010001; 
        InstMem[51] = 32'hEC200004; 
        InstMem[52] = 32'h20061800; 
        InstMem[53] = 32'hECC02002; 
        InstMem[54] = 32'h20071804; 
        InstMem[55] = 32'hECE02802; 
        InstMem[56] = 32'hEC853005; 
        InstMem[57] = 32'h20081808; 
        InstMem[58] = 32'hED003003; 

        InstMem[59] = 32'h20010100; 
        InstMem[60] = 32'hEC200004; 
        InstMem[61] = 32'h00004820; 
        InstMem[62] = 32'hED203802; 
        InstMem[63] = 32'h200A03E7; 
        InstMem[64] = 32'h200B180C; 
        InstMem[65] = 32'hAD6A0000; 
        
        InstMem[66] = 32'h08000042; 
        InstMem[67] = 32'h08000042; 

        Rst = 0;
        #2 Rst = 1;
        #10 Rst = 0;
    end

    always @(posedge Clk) begin
        if (!Rst) total_cycles = total_cycles + 1;
    end

    always @(posedge Clk) begin
        if (DataWrite) begin
            DataMem[DataAddr >> 2] <= DataOut;
        end
    end

    always @(posedge Clk) begin
        if (uut.W_PC == 32'd104 && uut.W_Valid && scalar_cycles == 0) begin
            scalar_cycles = total_cycles;
        end
        if (uut.W_PC == 32'd264 && uut.W_Valid) begin
            vector_cycles = total_cycles - scalar_cycles;
            speedup = $itor(scalar_cycles) / $itor(vector_cycles);
            
            $display("\n=================================================");
            $display("#          BENCHMARK & VERIFICATION RESULTS      ");
            $display("=================================================");
            
            for(i=0; i<256; i=i+1) begin
                if(DataMem[512+i] !== (i+1)*77 || DataMem[768+i] !== DataMem[512+i])
                    $display("ERROR at Add Index %0d: Expected %0d | Scalar: %0d | Vector: %0d", i, (i+1)*77, DataMem[512+i], DataMem[768+i]);
            end
            
            for(i=0; i<256; i=i+1) begin
                if(DataMem[1024+i] !== (i+1) * ((i+1)*10))
                    $display("ERROR at Mul Index %0d: Expected %0d | Got: %0d", i, (i+1) * ((i+1)*10), DataMem[1024+i]);
            end
            
            if(DataMem[1538] !== 32'h40F00000)
                $display("ERROR in Float Add: Expected 40F00000, Got %h", DataMem[1538]);
            
            if(DataMem[1539] !== 999)
                $display("ERROR in Memory Arbiter: Scalar SW failed. Expected 999, Got %0d", DataMem[1539]);

            $display("-------------------------------------------------");
            $display("#  Scalar Execution Cycles : %0d", scalar_cycles);
            $display("#  Vector Execution Cycles : %0d", vector_cycles);
            $display("#  SPEEDUP (Scalar / Vector) : %f", speedup);
            $display("=================================================\n");
            $finish;
        end
    end

endmodule
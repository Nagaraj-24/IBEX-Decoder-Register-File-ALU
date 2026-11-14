// ============================================================
// TESTBENCH
// Verification of Decoder + Register File + ALU
// ============================================================

module tb;

    // ========================================================
    // Signals
    // ========================================================

    logic clk;
    logic rst;

    logic [31:0] instr;
    logic [31:0] wdata_i;

    logic wb_from_alu_i;

    logic [31:0] rdata_a_o;
    logic [31:0] rdata_b_o;

    logic [3:0] alu_operator_o;
    logic rf_we_o;

    logic [31:0] alu_result_o;

    // ========================================================
    // DUT
    // ========================================================

    decoder_register_file DUT (

        .clk(clk),
        .rst(rst),

        .instr(instr),

        .wdata_i(wdata_i),

        .wb_from_alu_i(wb_from_alu_i),

        .rdata_a_o(rdata_a_o),
        .rdata_b_o(rdata_b_o),

        .alu_operator_o(alu_operator_o),

        .rf_we_o(rf_we_o),

        .alu_result_o(alu_result_o)

    );

    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    // ========================================================
    // VCD
    // ========================================================

    initial begin

        $dumpfile("decoder_register_file.vcd");
        $dumpvars(0, tb);

    end

    // ========================================================
    // R-TYPE INSTRUCTION GENERATOR
    // ========================================================

    function automatic [31:0] make_r_type;

        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;

        begin

            make_r_type = {
                funct7,
                rs2,
                rs1,
                funct3,
                rd,
                7'b0110011
            };

        end

    endfunction

    // ========================================================
    // DISPLAY TASK
    // ========================================================

    task display_result;

        input [127:0] name;

        begin

            $display("");
            $display("================================================");
            $display("%s", name);
            $display("================================================");

            $display("Instruction = %h", instr);

            $display("rs1 address = %0d",
                     DUT.u_decoder.rf_raddr_a_o);

            $display("rs2 address = %0d",
                     DUT.u_decoder.rf_raddr_b_o);

            $display("rd address  = %0d",
                     DUT.u_decoder.rf_waddr_o);

            $display("Operand A   = %0d", rdata_a_o);

            $display("Operand B   = %0d", rdata_b_o);

            case (alu_operator_o)

                4'b0000:
                    $display("ALU Operation = ADD");

                4'b0001:
                    $display("ALU Operation = SUB");

                4'b0010:
                    $display("ALU Operation = AND");

                4'b0011:
                    $display("ALU Operation = OR");

                4'b0100:
                    $display("ALU Operation = XOR");

                default:
                    $display("ALU Operation = UNKNOWN");

            endcase

            $display("ALU Result       = %0d", alu_result_o);

            $display("RF Write Enable  = %b", rf_we_o);

            $display("Write-back Data  = %0d",
                     DUT.rf_wdata);

        end

    endtask

    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        // Initial values
        instr = 32'b0;
        wdata_i = 32'b0;

        wb_from_alu_i = 1'b0;

        rst = 1'b1;

        // ====================================================
        // RESET
        // ====================================================

        #12;

        rst = 1'b0;

        $display("");
        $display("****************************************");
        $display("*          RESET COMPLETED             *");
        $display("****************************************");

        // ====================================================
        // WRITE x1 = 10
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd0,
            5'd0,
            3'b000,
            5'd1
        );

        wdata_i = 32'd10;

        // Use external write data
        wb_from_alu_i = 1'b0;

        #2;

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[1] == 32'd10)
            $display("x1 = 10 -> WRITE PASSED");
        else
            $display("x1 WRITE FAILED");

        // ====================================================
        // WRITE x2 = 20
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd0,
            5'd0,
            3'b000,
            5'd2
        );

        wdata_i = 32'd20;

        wb_from_alu_i = 1'b0;

        #2;

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[2] == 32'd20)
            $display("x2 = 20 -> WRITE PASSED");
        else
            $display("x2 WRITE FAILED");

        // ====================================================
        // READ x1 AND x2
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd2,
            5'd1,
            3'b000,
            5'd0
        );

        #2;

        $display("");
        $display("REGISTER READ TEST");
        $display("Read x1 = %0d", rdata_a_o);
        $display("Read x2 = %0d", rdata_b_o);

        if ((rdata_a_o == 32'd10) &&
            (rdata_b_o == 32'd20))
            $display("REGISTER READ -> PASSED");
        else
            $display("REGISTER READ -> FAILED");

        // ====================================================
        // ALU WRITE-BACK ENABLE
        // ====================================================

        wb_from_alu_i = 1'b1;

        // ====================================================
        // TEST 1 : ADD x5, x1, x2
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd2,
            5'd1,
            3'b000,
            5'd5
        );

        #2;

        display_result("TEST 1 : ADD x5, x1, x2");

        if (alu_result_o == 32'd30)
            $display("ADD RESULT -> PASSED");
        else
            $display("ADD RESULT -> FAILED");

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[5] == 32'd30)
            $display("x5 = 30 -> WRITE-BACK PASSED");
        else
            $display("x5 WRITE-BACK FAILED");

        // ====================================================
        // TEST 2 : SUB x6, x2, x1
        // ====================================================

        instr = make_r_type(
            7'b0100000,
            5'd1,
            5'd2,
            3'b000,
            5'd6
        );

        #2;

        display_result("TEST 2 : SUB x6, x2, x1");

        if (alu_result_o == 32'd10)
            $display("SUB RESULT -> PASSED");
        else
            $display("SUB RESULT -> FAILED");

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[6] == 32'd10)
            $display("x6 = 10 -> WRITE-BACK PASSED");
        else
            $display("x6 WRITE-BACK FAILED");

        // ====================================================
        // TEST 3 : AND x7, x1, x2
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd2,
            5'd1,
            3'b111,
            5'd7
        );

        #2;

        display_result("TEST 3 : AND x7, x1, x2");

        if (alu_result_o == 32'd0)
            $display("AND RESULT -> PASSED");
        else
            $display("AND RESULT -> FAILED");

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[7] == 32'd0)
            $display("x7 = 0 -> WRITE-BACK PASSED");
        else
            $display("x7 WRITE-BACK FAILED");

        // ====================================================
        // TEST 4 : OR x8, x1, x2
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd2,
            5'd1,
            3'b110,
            5'd8
        );

        #2;

        display_result("TEST 4 : OR x8, x1, x2");

        if (alu_result_o == 32'd30)
            $display("OR RESULT -> PASSED");
        else
            $display("OR RESULT -> FAILED");

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[8] == 32'd30)
            $display("x8 = 30 -> WRITE-BACK PASSED");
        else
            $display("x8 WRITE-BACK FAILED");

        // ====================================================
        // TEST 5 : XOR x9, x1, x2
        // ====================================================

        instr = make_r_type(
            7'b0000000,
            5'd2,
            5'd1,
            3'b100,
            5'd9
        );

        #2;

        display_result("TEST 5 : XOR x9, x1, x2");

        if (alu_result_o == 32'd30)
            $display("XOR RESULT -> PASSED");
        else
            $display("XOR RESULT -> FAILED");

        @(posedge clk);

        #1;

        if (DUT.u_register_file.registers[9] == 32'd30)
            $display("x9 = 30 -> WRITE-BACK PASSED");
        else
            $display("x9 WRITE-BACK FAILED");

        // ====================================================
        // x0 TEST
        // ====================================================

        $display("");
        $display("****************************************");
        $display("*             x0 TEST                  *");
        $display("****************************************");

        if (DUT.u_register_file.registers[0] == 32'd0)
            $display("x0 = 0 -> PASSED");
        else
            $display("x0 -> FAILED");

        // ====================================================
        // FINAL
        // ====================================================

        $display("");
        $display("****************************************");
        $display("*       ALL TESTS COMPLETED            *");
        $display("****************************************");

        #10;

        $finish;

    end

endmodule

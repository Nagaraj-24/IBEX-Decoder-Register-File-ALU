// ============================================================
// DECODER + REGISTER FILE + ALU
// ============================================================

module decoder (

    input  logic [31:0] instr,

    // Register addresses
    output logic [4:0] rf_raddr_a_o,
    output logic [4:0] rf_raddr_b_o,
    output logic [4:0] rf_waddr_o,

    // Register write enable
    output logic rf_we_o,

    // ALU control
    output logic [3:0] alu_operator_o,

    // ALU operands
    input logic [31:0] alu_operand_a_i,
    input logic [31:0] alu_operand_b_i,

    // ALU result
    output logic [31:0] alu_result_o
);

    // ========================================================
    // Instruction fields
    // ========================================================

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Register addresses
    assign rf_raddr_a_o = instr[19:15];   // rs1
    assign rf_raddr_b_o = instr[24:20];   // rs2
    assign rf_waddr_o   = instr[11:7];    // rd

    // ========================================================
    // ALU operation codes
    // ========================================================

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;

    // ========================================================
    // DECODER
    // ========================================================

    always_comb begin

        // Default values
        rf_we_o        = 1'b0;
        alu_operator_o = ALU_ADD;

        // R-type opcode
        case (opcode)

            7'b0110011: begin

                rf_we_o = 1'b1;

                case (funct3)

                    // ADD / SUB
                    3'b000: begin

                        if (funct7 == 7'b0100000)
                            alu_operator_o = ALU_SUB;
                        else
                            alu_operator_o = ALU_ADD;

                    end

                    // XOR
                    3'b100:
                        alu_operator_o = ALU_XOR;

                    // OR
                    3'b110:
                        alu_operator_o = ALU_OR;

                    // AND
                    3'b111:
                        alu_operator_o = ALU_AND;

                    default: begin
                        rf_we_o        = 1'b0;
                        alu_operator_o = ALU_ADD;
                    end

                endcase

            end

            default: begin
                rf_we_o        = 1'b0;
                alu_operator_o = ALU_ADD;
            end

        endcase

    end

    // ========================================================
    // ALU
    // ========================================================

    always_comb begin

        case (alu_operator_o)

            ALU_ADD:
                alu_result_o = alu_operand_a_i + alu_operand_b_i;

            ALU_SUB:
                alu_result_o = alu_operand_a_i - alu_operand_b_i;

            ALU_AND:
                alu_result_o = alu_operand_a_i & alu_operand_b_i;

            ALU_OR:
                alu_result_o = alu_operand_a_i | alu_operand_b_i;

            ALU_XOR:
                alu_result_o = alu_operand_a_i ^ alu_operand_b_i;

            default:
                alu_result_o = 32'b0;

        endcase

    end

endmodule


// ============================================================
// REGISTER FILE
// ============================================================

module register_file (

    input logic clk,
    input logic rst,

    // Read Port A
    input logic [4:0] raddr_a_i,
    output logic [31:0] rdata_a_o,

    // Read Port B
    input logic [4:0] raddr_b_i,
    output logic [31:0] rdata_b_o,

    // Write Port
    input logic [4:0] waddr_a_i,
    input logic [31:0] wdata_a_i,
    input logic we_a_i

);

    // 32 registers, each 32 bits
    logic [31:0] registers [0:31];

    integer i;

    // ========================================================
    // WRITE
    // ========================================================

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;

        end

        else begin

            // x0 cannot be written
            if (we_a_i && (waddr_a_i != 5'd0))
                registers[waddr_a_i] <= wdata_a_i;

        end

    end

    // ========================================================
    // READ PORTS
    // ========================================================

    always_comb begin

        // Read Port A
        if (raddr_a_i == 5'd0)
            rdata_a_o = 32'b0;
        else
            rdata_a_o = registers[raddr_a_i];

        // Read Port B
        if (raddr_b_i == 5'd0)
            rdata_b_o = 32'b0;
        else
            rdata_b_o = registers[raddr_b_i];

    end

endmodule


// ============================================================
// TOP MODULE
// Decoder + Register File + ALU + Write-back
// ============================================================

module decoder_register_file (

    input logic clk,
    input logic rst,

    input logic [31:0] instr,

    // External data used only for register initialization
    input logic [31:0] wdata_i,

    // 0 = external wdata
    // 1 = ALU result
    input logic wb_from_alu_i,

    // Register read data
    output logic [31:0] rdata_a_o,
    output logic [31:0] rdata_b_o,

    // ALU control
    output logic [3:0] alu_operator_o,

    // Register write enable
    output logic rf_we_o,

    // ALU result
    output logic [31:0] alu_result_o

);

    // ========================================================
    // Internal signals
    // ========================================================

    logic [4:0] rf_raddr_a;
    logic [4:0] rf_raddr_b;
    logic [4:0] rf_waddr;

    logic [31:0] rf_wdata;

    // ========================================================
    // WRITE-BACK MUX
    // ========================================================

    // 0 -> use external data
    // 1 -> use ALU result

    assign rf_wdata = wb_from_alu_i ?
                      alu_result_o :
                      wdata_i;

    // ========================================================
    // DECODER + ALU
    // ========================================================

    decoder u_decoder (

        .instr(instr),

        .rf_raddr_a_o(rf_raddr_a),
        .rf_raddr_b_o(rf_raddr_b),
        .rf_waddr_o(rf_waddr),

        .rf_we_o(rf_we_o),

        .alu_operator_o(alu_operator_o),

        .alu_operand_a_i(rdata_a_o),
        .alu_operand_b_i(rdata_b_o),

        .alu_result_o(alu_result_o)

    );

    // ========================================================
    // REGISTER FILE
    // ========================================================

    register_file u_register_file (

        .clk(clk),
        .rst(rst),

        .raddr_a_i(rf_raddr_a),
        .rdata_a_o(rdata_a_o),

        .raddr_b_i(rf_raddr_b),
        .rdata_b_o(rdata_b_o),

        .waddr_a_i(rf_waddr),

        // Write-back data
        .wdata_a_i(rf_wdata),

        .we_a_i(rf_we_o)

    );

endmodule

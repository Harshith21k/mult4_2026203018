
module mult_array (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output reg  [7:0] p
);

    // 1. Input Registers
    reg [3:0] a_reg, b_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 4'b0;
            b_reg <= 4'b0;
        end else begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    // 2. Partial Products Generation
    wire pp0[3:0], pp1[3:0], pp2[3:0], pp3[3:0];
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_pp
            assign pp0[i] = a_reg[i] & b_reg[0];
            assign pp1[i] = a_reg[i] & b_reg[1];
            assign pp2[i] = a_reg[i] & b_reg[2];
            assign pp3[i] = a_reg[i] & b_reg[3];
        end
    endgenerate

    // 3. Array Adder Network (12 Full Adders)
    // Row 0 Outputs
    wire [3:0] r0;
    assign r0 = {1'b0, pp0[3], pp0[2], pp0[1]};

    // Row 1 Full Adders
    wire [3:0] s1;
    wire [4:0] c1;
    assign c1[0] = 1'b0;

    generate
        for (i = 0; i < 4; i = i + 1) begin : row1
            full_adder fa1 (
                .a(pp1[i]),
                .b(r0[i]),
                .cin(c1[i]),
                .sum(s1[i]),
                .cout(c1[i+1])
            );
        end
    endgenerate

    wire [3:0] r1 = {c1[4], s1[3], s1[2], s1[1]};

    // Row 2 Full Adders
    wire [3:0] s2;
    wire [4:0] c2;
    assign c2[0] = 1'b0;

    generate
        for (i = 0; i < 4; i = i + 1) begin : row2
            full_adder fa2 (
                .a(pp2[i]),
                .b(r1[i]),
                .cin(c2[i]),
                .sum(s2[i]),
                .cout(c2[i+1])
            );
        end
    endgenerate

    wire [3:0] r2 = {c2[4], s2[3], s2[2], s2[1]};

    // Row 3 Full Adders
    wire [3:0] s3;
    wire [4:0] c3;
    assign c3[0] = 1'b0;

    generate
        for (i = 0; i < 4; i = i + 1) begin : row3
            full_adder fa3 (
                .a(pp3[i]),
                .b(r2[i]),
                .cin(c3[i]),
                .sum(s3[i]),
                .cout(c3[i+1])
            );
        end
    endgenerate

    // Unregistered Combinational Result Assembly
    wire [7:0] p_comb;
    assign p_comb[0]   = pp0[0];
    assign p_comb[1]   = s1[0];
    assign p_comb[2]   = s2[0];
    assign p_comb[3]   = s3[0];
    assign p_comb[7:4] = {c3[4], s3[3], s3[2], s3[1]};

    // 4. Output Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p <= 8'b0;
        end else begin
            p <= p_comb;
        end
    end

endmodule

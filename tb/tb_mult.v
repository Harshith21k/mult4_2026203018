`timescale 1ns/1ps

module tb_mult;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;
    reg  [7:0] expected;

    integer i_a, i_b;
    integer errors = 0;
    integer vectors_checked = 0;

    // Design under test
    mult_array dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin

        // initialise
        clk   = 0;
        rst_n = 0;
        a     = 0;
        b     = 0;

	$dumpfile("mult.vcd");
	$dumpvars(0, tb_mult);

        // hold reset low for the first 2 clock cycles
        repeat (2) @(posedge clk);
        rst_n = 1;

        // exhaustive test: 256 combinations
        for (i_a = 0; i_a < 16; i_a = i_a + 1) begin
            for (i_b = 0; i_b < 16; i_b = i_b + 1) begin
                // apply inputs on the falling edge, away from the capturing edge
                @(negedge clk);
                a = i_a;
                b = i_b;
                expected = a * b;     // * is allowed in the testbench only

                // edge 1 captures a and b, edge 2 captures the product (latency = 2)
                repeat (2) @(posedge clk);
		#2;


                if (p !== expected) begin
                    $display("MISMATCH: a=%0d, b=%0d | Expected=%0d, Got=%0d",
                             a, b, expected, p);
                    errors = errors + 1;
                end
                vectors_checked = vectors_checked + 1;
            end
        end

        // summary
        if (errors == 0)
            $display("PASS: %0d vectors checked, %0d errors", vectors_checked, errors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", vectors_checked, errors);

        $finish;
    end

endmodule

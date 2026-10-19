`timescale 1ns/1ps

module tb_mult;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;

    integer i_a, i_b;
    integer errors = 0;
    integer vectors_checked = 0;

    // Instantiate Design Under Test (DUT)
    mult_array dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );

    // 10 ns Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Setup Waveform Dump
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        // Initialize Signals
        clk   = 0;
        rst_n = 0;
        a     = 0;
        b     = 0;

        // Hold Reset active for 2 clock cycles
        repeat (2) @(posedge clk);
        #1;
        rst_n = 1;

        // Exhaustive Test Loop (256 Combinations)
        for (i_a = 0; i_a < 16; i_a = i_a + 1) begin
            for (i_b = 0; i_b < 16; i_b = i_b + 1) begin
                @(posedge clk);
                #1;
                a = i_a;
                b = i_b;

                // Wait 2 clock cycles for pipeline delay
                repeat (2) @(posedge clk);
                #1;

                // Verify output
                if (p !== (a * b)) begin
                    $display("MISMATCH: a=%d, b=%d | Expected=%d, Got=%d", a, b, (a * b), p);
                    errors = errors + 1;
                end
                vectors_checked = vectors_checked + 1;
            end
        end

        // Final Summary Display
        if (errors == 0) begin
            $display("PASS: %0d vectors checked, %0d errors", vectors_checked, errors);
        end else begin
            $display("FAIL: %0d vectors checked, %0d errors", vectors_checked, errors);
        end

        $finish;
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: deFEEST
// Engineer: Paul Honig
// 
// Create Date: 11/03/2020 09:46:48 PM
// Design Name: 
// Module Name: sim_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_toptb(

    );
    
    initial #50 $stop;
    
	// Input registers
	reg clk = 1'b0;
	reg clk_pixel = 1'b0;
	reg videoblank = 1'b0;
	reg vsync = 1'b0;
	reg hsync = 1'b0;
	reg [23:0] data = 24'hAADBFF;

	// Output registers
	wire clk_pixel_out;
	wire de_out;
	wire vsync_out;
	wire hsync_out;
	wire [11:0] data_out;

	// Video blank generation to check timing
	always #9 videoblank = !videoblank;
	always #18 hsync = !hsync;
	always #36 vsync = !vsync;

	always #1 clk = !clk;

	reg clk_pixel_div=0;
	always @(posedge clk) begin
		clk_pixel_div <= ~clk_pixel_div;
		if (clk_pixel_div) begin
			clk_pixel <= !clk_pixel;
		end
	end

	always @(posedge clk_pixel) begin
		data = ~data;
	end

    adv_ddr my_adv_ddr (
            .clk_ddr(clk),			// DDR clock at 4xpixel clock
    
            // INPUT
            .clk_pixel(clk_pixel),        // Pixel clock 1/4 of the logic clock
            .videoblank(videoblank),		// Used to generate DE
            .vsync(vsync),
            .hsync(hsync),
            .data(data),     // Pixel data in 24-bpp
    
            // OUTPUT
            .clk_pixel_out(clk_pixel_out),   // Output pixel clock after synchronization to clk_ddr
            .de_out(de_out),			// Data enable signal
            .vsync_out(vsync_out), 
            .hsync_out(hsync_out),
            .data_out(data_out)  // DDR data stream out [11:0]
    );


    
endmodule

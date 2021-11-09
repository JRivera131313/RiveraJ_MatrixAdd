
// Mark W. Welker
// HDL 4321 Spring 2021
// execution engine assignment top module
//
//
//
module top ();

logic [255:0] InstructDataOut;
logic [255:0] MemDataOut;
logic [255:0] ExeDataOut;
logic nRead,nWrite,nReset,Clk;
logic [15:0] address;

InstructionMemory  U1(Clk,InstructDataOut, address, nRead,nReset);

MainMemory  U2(Clk,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);

Execution  U3(Clk,InstructDataOut,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);

TestExe  UTest(Clk,nReset);

  initial begin //. setup to allow waveforms for edaplayground
   $dumpfile("dump.vcd");
   $dumpvars(1);
 end

endmodule


	
	


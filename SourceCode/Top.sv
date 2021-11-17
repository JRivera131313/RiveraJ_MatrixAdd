
// Mark W. Welker
// HDL 4321 Spring 2021
// Matrix addition assignment top module
//
// Main memory MUST be allocated in the mainmemory module as per teh next line.
//  logic [255:0]MainMemory[12]; // this is the physical memory
//
//This top module is simple shoved on top of the ?finished??? top module I used while developing the final Project
// It is commeted out instead of deleted so that it may be refrenced by myself.
module top ();

logic [255:0] InstructDataOut;
logic [255:0] MemDataOut;
logic [255:0] ExeDataOut;
logic [255:0] MatrixDataOut;
logic nRead,nWrite,nReset,Clk;
logic [15:0] address;


InstructionMemory  U1(Clk,InstructDataOut, address, nRead,nReset);

MainMemory  U2(Clk,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);

Execution  U3(Clk,InstructDataOut,MemDataOut,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);

MatrixAlu  U4(Clk,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);

TestMatrix  UTest(Clk,nReset);

  initial begin //. setup to allow waveforms for edaplayground
   $dumpfile("dump.vcd");
   $dumpvars(1);
 end



endmodule

// ///////////////////////////////
//
// // Mark W. Welker
// // HDL 4321 Spring 2021
// // Final Project Top Module as edited by JESUS RIVERA III
// //
// //
// //
// module top ();
//
// logic [255:0] InstructDataOut;
// logic [255:0] MemDataOut;
// logic [255:0] ExeDataOut;
// logic [255:0] MatrixDataOut;
// logic [255:0] IntDataOut;
// logic nRead,nWrite,nReset,Clk;
// logic [15:0] address;
//
// InstructionMemory  U1(Clk,InstructDataOut, address, nRead,nReset);
//
// MainMemory  U2(Clk,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);
//
// Execution  U3(Clk,InstructDataOut,MemDataOut,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);
//
// MatrixALU Matrix(Clk, ExeDataOut, MatrixDataOut, address, nRead, nWrite, nReset);
//
// IntegerALU Integer(Clk, ExeDataOut,IntDataOut, address, nRead, nWrite, nReset);
//
// TestExe  UTest(Clk,nReset);
//
//   initial begin //. setup to allow waveforms for edaplayground
//    $dumpfile("dump.vcd");
//    $dumpvars(1);
//  end
//
// endmodule

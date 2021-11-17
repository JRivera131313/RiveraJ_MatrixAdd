/////////////////////////////////////////
// FILE: MemModual.sv                  //
// LastEdited 10/14/2021               //
// Created by: JESUS RIVERA III        //
/////////////////////////////////////////
//
// The address bus is large enough that each module can contain a local address decode. This will save on multiple enables.
// for now have each module dedicated to an address line. A more generic solution would be to decode the upper bits and have a specific range. Use all 4 address bits [15:12] in decode.
// bits 15:12 are used to memory map each peripheral

// 0 = main memory
// 1 = Instruction memory
// 2 = Matrix ALU
// 3 = Integer ALU
// 4 = Internal Register
// 5 = execution engine

// bit 11-0 are for addressing inside each unit.
// nWrite = 0 means databus is being written into on the falling edge of write
// nRead = 0 means it is expected to drive the databus while this signal is low and the address is correct until the nRead goes high independent of address bus.

// instruction: OPcode :: dest :: src1 :: src2 Each section is 8 bits.
// Stop::FFh::00::00::00
// MMult::00h::Reg/mem::Reg/mem::Reg/mem
// Madd::01h::Reg/mem::Reg/mem::Reg/mem
// Msub::02h::Reg/mem::Reg/mem::Reg/mem
// Mtranspose::03h::Reg/mem::Reg/mem::Reg/mem
// MScale::04h::Reg/mem::Reg/mem::Reg/mem
// MScaleImm::05h:Reg/mem::Reg/mem::Immediate
// IntAdd::10h::Reg/mem::Reg/mem::Reg/mem
// IntSub::11h::Reg/mem::Reg/mem::Reg/mem
// IntMult::12h::Reg/mem::Reg/mem::Reg/mem
// IntDiv::13h::Reg/mem::Reg/mem::Reg/mem



//Instruction Mem
module InstructionMemory(Clk, DataOut, address, nRead, nReset);
   input logic nRead, nReset, Clk;
   input logic [15:0] address;
   output logic [255:0] DataOut;
   reg [31:0]instructMem[9:0];


   // add the data at location 0 to the data at location 1 and place result in location 2
   parameter Instruct1 = 32'h 01_02_00_01;  // ADD matrix at memory location 0 to memory location 1 store in memory location 2
   parameter Instruct2 = 32'h FF_00_00_00;
   parameter Instruct3 = 32'h 00_04_00_01;//32'h 00_04_00_01;
   //Transpose the result from step 1 store in memory
   parameter Instruct4 = 32'h 03_05_00_00;
   //Scale the result in step 3 by the result from step 2 store in a matrix register
   parameter Instruct5 = 32'h 04_06_00_01;
   //Multiply the result from step 4 by the result in step 3, store in memory.
   parameter Instruct6 = 32'h 05_07_00_64;
   //Multiply memory location 0 to location 1. Store it in memory location 0A
   parameter Instruct7 = 32'h FF_0A_00_01;
   //Subtract Memory 01 from memory location 0A and store it in a register
   parameter Instruct8 = 32'h 11_0A_01_81;
   //Divide Memory location 0A by the register in step 8 and store it in location B
   parameter Instruct9 = 32'h 13_0B_0A_81;
   //STOP
   parameter Instruct10 = 32'h ff_ff_ff_ff;
   //Sets the Address select for Instuction Memory Modual
   parameter InstuctionSelect = 4'b 0001;
   //////////////////////////////////////////////////////////////////
   always @ ( negedge nReset) begin
      if (nReset == 0) begin
         instructMem[0] <= Instruct1;
         instructMem[1] <= Instruct2;
         instructMem[2] <= Instruct3;
         instructMem[3] <= Instruct4;
         instructMem[4] <= Instruct5;
         instructMem[5] <= Instruct6;
         instructMem[6] <= Instruct7;
         instructMem[7] <= Instruct8;
         instructMem[8] <= Instruct9;
         instructMem[9] <= Instruct10;
      end
   end

   always_ff @ (posedge Clk) begin
      if (address[15:12] == InstuctionSelect && nRead == 0) begin   //If The InsturctMem is being commanded by the address
         DataOut <= instructMem[address[11:0]];
      end
   end
endmodule

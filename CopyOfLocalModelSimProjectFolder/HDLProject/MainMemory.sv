////////////////////////////////////////////////////////////////////
// FILE: MainMemory.sv                                            //
// LastEdited 10/15/2021                                          //
// Created by: JESUS RIVERA III                                   //
////////////////////////////////////////////////////////////////////
//                           Internal Adress Decodeing            //
// Address [15:12] (4bits) Module select                          //
// Address [11-0] (12bits) are the memory Location                //
// EX: adress =0000_000000000101 woud be                          //
//     [Main memory]_[Matrix 5]_[specifc matrix Location]         //
//     address = 0000_000000001001 woud be                        //
//     [Main memory]_[Matrix 7]                                   //
//Memory Structure!!!!//////////////////////////////////////////////
// mainMemArray [0] = matrix 1
// mainMemArray [1] = matrix 2
// mainMemArray [2] = matrix Result 1
// mainMemArray [3] = matrix Result 2
// mainMemArray [4] = matrix Result 3
// mainMemArray [5] = matrix Result 4
// mainMemArray [6] = matrix Result 5
// mainMemArray [7] = matrix Result 6
// mainMemArray [8] = Interger Data 1
// mainMemArray [9] = Interger Data 2
// mainMemArray [10] = Interger Result
// mainMemArray [11] = Interger Result
// mainMemArray [12] = Interger Result
// mainMemArray [13] = Interger Result
// mainMemArray [14] = Extra
// mainMemArray [15] = Extra

//Main Mem
module MainMemory(Clk, DataOut,DataIn, address, nRead, nWrite, nReset);

   parameter matrixMemory0 = 256'h0001_0002_0003_0004_0005_0006_0007_0008_0009_000a_000b_000c_000d_000e_000f_0010;
   parameter matrixMemory1 = 256'h0020_001f_001e_001d_001c_001b_001a_0019_0018_0017_0016_0015_0014_0013_0012_0011;

   input logic nRead, nWrite, nReset, Clk;
   input logic [15:0] address;
   input logic [255:0] DataIn;
   output logic [255:0] DataOut;
   int typeMemAccess,memLocation,row,column;
   //reg [3:0][3:0][15:0]mainMemArray[15:0];  //16 4x4x16 bit arrays total of 256bits
   logic [255:0]MainMemory[12]; // this is the physical memory For matrixALU Asignmet
   always @ (address) begin
      memLocation = address[11:0];
   end

   // allows for simtnous read and write access, I think this is neccesary for
   //   the pipe lineing I plan for the project. Can easily be changed to not
   //   allow both read and write at the same time.
   always_ff @ ( negedge nReset or posedge Clk) begin
      if (nReset == 0) begin
         //mainMemArray[0] <= matrixMemory0;
		   //mainMemArray[1] <= matrixMemory1;
         MainMemory[0] <= matrixMemory0;
         MainMemory[1] <= matrixMemory1;
         DataOut <= 0;
      end

      if (address[15:12] == 0 && nReset != 0 ) begin
         //read Commands
         if (nRead == 0) begin
            //Read data out of a chosen Matrix
            //DataOut <= mainMemArray[memLocation];
            DataOut <= MainMemory[memLocation];
         end
         //Write commands
         if (nWrite == 0) begin
               //mainMemArray[memLocation] <= DataIn;
               MainMemory[memLocation] <= DataIn;
         end
      end //if
   end //always
endmodule

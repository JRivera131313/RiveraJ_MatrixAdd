///////////////////////////////////////
// FILE: ExcutionEngin.sv            //
// LastEdited 11/2/2021              //
// Created by: JESUS RIVERA III      //
///////////////////////////////////////
//	On Reset, loads in 1 instuctions. Loads in next instuction
//	in place of instuction that was last ran after that.
//
//
///////////////////////////////////////
// opCode Definition 32'h xx_xx_xx_xx
//					operation_dest_src1_src2
// 	Address is determined by dest, src1, or src2. If src1 is 0004,
//	then Adress will translate that to a 12 bit 000000000004
//
module Execution (Clk,InstructDataOut,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);
   parameter  FetchInstuction = 1;
   parameter  DecodeInstuction= 2;
   parameter  ReadInstuction = 3;
   parameter  ExcuteInstruction = 4;
   parameter  Clear = 5;

   //opCode instuctions
   parameter  Stop = 8'h FF;  //Stop the processer
   parameter matrixAdd = 8'h 01;
   parameter matrixSub = 8'h 02;
   parameter matrixTranspose = 8'h 03;
   parameter matrixScale = 8'h 04;
   parameter matrixScaleImmediate = 8'h 05;
   parameter intAdd = 8'h 10;
   parameter intSub = 8'h 11;
   parameter intMultiply = 8'h 12;
   parameter intDiv = 8'h 13;
   //Extra for expanding operations
   //parameter Extra1 = 8'h A1;
   //parameter Extra2 = 8'h A2;
   //parameter Extra3 = 8'h A3;


	output logic nRead,nWrite;
	output logic [15:0] address;
	output logic [255:0] ExeDataOut;
	input logic nReset,Clk;
	input logic [255:0] InstructDataOut;
	input logic [255:0] MemDataOut;
	logic [7:0] clkCounter;	//counts amount of clock cycles for timing
	logic complete; //Unused for now, planed use in final project is to recive complete bit from ALU's
	reg [3:0] currentOperation;

	reg [7:0] PC;	//Program counter, counts which instruction is on
	reg [31:0] opCode;	//could just use specific bits in opCode, but breaking it into other regs makes for easier reading and logic
	reg [7:0] operation;
	reg [7:0] destAddress;
	reg [7:0] src1Address;
	reg [7:0] src2Address;
	///////////////////////////////////////////////////////////////////
	// Sudo ALU code. A ALU should be doing this in the project but
	// for this asignment it is done inside the excution since the ALU
	// Doesnt exist yet.
	reg [255:0] Result;
	reg [255:0] src1Data;
	reg [255:0] src2Data;

	//////////////////////////////////////
	////////RESET CONDITION///////////////
	//////////////////////////////////////


	always_ff @ ( negedge nReset or posedge Clk) begin

		if (nReset == 0) begin   //Reset case
			nRead <= 1;
			nWrite <= 1;
			ExeDataOut <= 0;
			clkCounter <= 0;
			complete <= 0;
			PC <= 0;
         currentOperation <= 0;
		end
   end

   always_ff @(posedge Clk) begin

      if (nReset != 0 && complete == 0) begin //load instuction in not compleate

         if (clkCounter == 0) begin //Sets to get instcutins
            currentOperation = FetchInstuction;
         end

         case (currentOperation)
            FetchInstuction: begin
               case (clkCounter)
                  0: begin //Prepares to get instuction data
                     nRead = 0;
                     nWrite = 1;
                     address = 16'h 8000 + PC;
                  end
                  2: opCode = InstructDataOut;  //Gets instuction data
                  3: begin //Sets for next operation
                     nRead = 1;
                     currentOperation = DecodeInstuction;
                     clkCounter = 0;
                  end
               endcase
               clkCounter++;
            end

            DecodeInstuction: begin       //Breakes opCode into more readable chunks
               operation = opCode[31:24];
               destAddress = opCode[23:16];
               src1Address = opCode[15:8];
               src2Address = opCode[7:0];
               currentOperation = ExcuteInstruction;
            end

            ExcuteInstruction: begin
               case (operation)
                  Stop: $stop;

                  matrixAdd:begin
                     //nothing yet
                  end

                  matrixSub:begin
                     //nothing yet
                  end

                  matrixTranspose:begin
                     //nothing yet
                  end

                  matrixScale:begin
                     //nothing yet
                  end

                  matrixScaleImmediate:begin
                     //nothing yet
                  end

                  intAdd:begin
                     case (clkCounter)
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end
                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           address = 16'h 0000 + src2Address;
                        end
                        5: begin    //Get src2 Data and prepare to write to Destination
                           src2Data = MemDataOut;
                           nRead = 1;
                           address = 16'h 0000 + destAddress;
                        end
                        6:begin  //Computation and put out data
                           Result = src1Data + src2Data;
                           ExeDataOut = Result;
                           nWrite = 0;
                        end
                     8:begin  //end add case
                        nWrite = 1;
                        PC++;
                        clkCounter = 0;   //Sets to get the next instruction
                        ExeDataOut = 256'b x;   //Stop outputing data
                        $display ("Sorce 1:%d\n",src1Data);
                        $display ("Sorce 2:%d\n",src2Data);
                        $display ("Result is :%d\n",Result);
                     end//8
                  endcase//intAdd

                  if (clkCounter != 0) begin
                     clkCounter++;
                  end
               end

               intSub: begin
                  //nothing yet
               end

               intMultiply:begin
                  //nothing yet
               end

               intDiv:begin
                  //nothing yet
               end //intDiv
            endcase//operation
         end //ExcuteInstruction
         default: ;//default case does nothing
      endcase //currentOperation
   end ////(nReset != 0 && complete == 0)
end //always_ff @(posedge Clk)

endmodule

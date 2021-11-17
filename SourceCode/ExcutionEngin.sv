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
module Execution (Clk,InstructDataOut,MemDataOut,MatrixDataOut,/*IntDataOut,*/ExeDataOut, address, nRead,nWrite, nReset);
	parameter  FETCHINSTUCTION = 0;
	parameter  DECODEINSTUCTION= 1;
	parameter  EXCUTEINSTUCTION = 2;
	parameter  CLEAR = 3;

	//opCode instuctions
	parameter STOP = 8'h FF;  //STOP the processer
	parameter MATRIXMULTIPLY = 8'h 00;
	parameter MATRIXADD = 8'h 01;
	parameter MATRIXSUB = 8'h 02;
	parameter MATRIXTRANSPOSE = 8'h 03;
	parameter MATRIXSCALE = 8'h 04;
	parameter MATRIXSCALEIMMEDIATE = 8'h 05;
	parameter INTADD = 8'h 10;
	parameter INTSUB = 8'h 11;
	parameter INTMULTIPLY = 8'h 12;
	parameter INTDIV = 8'h 13;
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
	input logic [255:0] MatrixDataOut;

	logic [7:0] clkCounter;	//counts amount of clock cycles for timing
	logic complete; 	   //Unused for now, planed use in final project is to recive complete bit from ALU's

	reg [3:0] currentOperation;
	reg [7:0] PC;		   //Program counter, counts which instruction is on
	reg [31:0] opCode;	//could just use specific bits in opCode, but breaking it into other regs makes for easier reading and logic
	reg [7:0] operation;
	reg [7:0] destAddress;
	reg [7:0] src1Address;
	reg [7:0] src2Address;

	//////////////////////////////////////
	///////ONBOARD MEMORY/////////////////
	//////////////////////////////////////
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
            currentOperation = FETCHINSTUCTION;
         end

         case (currentOperation)

            FETCHINSTUCTION: begin
               case (clkCounter)
                  0: begin //Prepares to get instuction data
                     nRead = 0;
                     nWrite = 1;
                     address = 16'h 1000 + PC;
                  end

                  2: opCode = InstructDataOut;  //Gets instuction data

                  3: begin //Sets for next operation
                     nRead = 1;
                     currentOperation = DECODEINSTUCTION;
                     clkCounter = 0;
                  end
               endcase

               clkCounter++;
            end

            DECODEINSTUCTION: begin       //Breakes opCode into more readable chunks
               operation = opCode[31:24];
               destAddress = opCode[23:16];
               src1Address = opCode[15:8];
               src2Address = opCode[7:0];
               currentOperation = EXCUTEINSTUCTION;
            end

            EXCUTEINSTUCTION: begin
               case (operation)

                  STOP: $stop;

                  MATRIXMULTIPLY: begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           address = 16'h 0000 + src2Address;
                        end

                        5: begin    //Get src2 Data
                           src2Data = MemDataOut;
                           nRead = 1;
                        end
                        //End get data from main memory

                        //Begin put data in MatrixALU
                        6:begin  //Write src1 to ALU
                           address = 16'b 0010_0000_0000_0000;
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        7:begin  //write data2 to ALU
                           address = 16'b 0010_0000_0000_0001;
                           ExeDataOut = src2Data;
                        end

                        8:begin  //Preform math. At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0000_0011;
                        end

                        9:begin  //Get the Result
                           nRead = 0;
                           address = 16'b 0010_0000_0000_0010;
                        end

                        11:begin //Write Result to Engin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        12:begin //Write Result to Memory
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        13:begin //End current instuction
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 15)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin //controls the clockCount
                        clkCounter++;
                     end

                  end //MatrixMultiply

                  MATRIXADD:begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           address = 16'h 0000 + src2Address;

                        end

                        5: begin    //Get src2 Data
                           src2Data = MemDataOut;
                           nRead = 1;
                        end
                        //End get data from main memory

                        //Begin put data in MatrixALU
                        6:begin
                           address = 16'b 0010_0000_0001_0000;  //Matrix add src1 Address
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        7:begin  //write data2 to ALU
                           address = 16'b 0010_0000_0001_0001;
                           ExeDataOut = src2Data;
                        end

                        8:begin //Command ALU to do Math. At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0001_0011;
                        end

                        9:begin  //Request Result
                           nRead = 0;
                           address = 16'b 0010_0000_0001_0010;
                        end

                        11:begin //Write result to Engin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        12:begin //Write Result to  Memory
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        13:begin //End operation
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 15)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin    //Does this every time
                        clkCounter++;
                     end

                  end//MatrixADD

                  MATRIXSUB:begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           address = 16'h 0000 + src2Address;
                        end

                        5: begin    //Get src2 Data
                           src2Data = MemDataOut;
                           nRead = 1;
                        end
                        //End get data from main memory

                        //Begin put data in MatrixALU
                        6:begin
                           address = 16'b 0010_0000_0010_0000;  //Matrix add src1 Address
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        7:begin  //write data2 to ALU
                           address = 16'b 0010_0000_0010_0001;
                           ExeDataOut = src2Data;
                        end

                        8:begin //Command ALU to do Addition on the data it has, At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0010_0011;
                        end

                        9:begin
                           nRead = 0;
                           address = 16'b 0010_0000_0010_0010;//Result Address
                        end

                        11:begin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        12:begin
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        13:begin
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 15)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin    //Does this every time
                        clkCounter++;
                     end

                  end

                  MATRIXTRANSPOSE:begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        //End get data from main memory
                        //Begin put data in MatrixALU
                        3:begin
                           address = 16'b 0010_0000_0011_0000;  //Matrix add src1 Address
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        5:begin //Command ALU to do Addition on the data it has, At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0011_0011;
                        end

                        6:begin
                           nRead = 0;
                           address = 16'b 0010_0000_0011_0010;//Result Address
                        end

                        7:begin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        8:begin
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        10:begin
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 12)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin    //Does this every time
                        clkCounter++;
                     end

                  end

                  MATRIXSCALE:begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           address = 16'h 0000 + src2Address;
                        end

                        5: begin    //Get src2 Data
                           src2Data = MemDataOut;
                           nRead = 1;
                        end
                        //End get data from main memory

                        //Begin put data in MatrixALU
                        6:begin
                           address = 16'b 0010_0000_0100_0000;  //Matrix add src1 Address
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        7:begin  //write data2 to ALU
                           address = 16'b 0010_0000_0100_0001;
                           ExeDataOut = src2Data;
                        end

                        8:begin //Command ALU to do Addition on the data it has, At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0100_0011;
                        end

                        9:begin
                           nRead = 0;
                           address = 16'b 0010_0000_0100_0010;//Result Address
                        end

                        11:begin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        12:begin
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        13:begin
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 15)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin    //Does this every time
                        clkCounter++;
                     end//if

                  end

                  MATRIXSCALEIMMEDIATE:begin
                     case (clkCounter)
                        //Begin Get data from main Mem
                        1: begin //prepare to get src1 data
                           nRead = 0;
                           address = 16'h 0000 + src1Address;
                        end

                        3: begin    //Get src1 data and prepare to get src2 data
                           src1Data = MemDataOut;
                           src2Data = src2Address;
                        end

                        5: begin    //Get src2 Data
                           nRead = 1;
                        end
                        //End get data from main memory

                        //Begin put data in MatrixALU
                        6:begin
                           address = 16'b 0010_0000_0101_0000;  //Matrix add src1 Address
                           ExeDataOut = src1Data;
                           nWrite = 0;
                        end

                        7:begin  //write data2 to ALU
                           address = 16'b 0010_0000_0101_0001;
                           ExeDataOut = src2Data;
                        end

                        8:begin //Command ALU to do Addition on the data it has, At this point,could put diffrent data into ALU
                           nWrite = 1;
                           address = 16'b 0010_0000_0101_0011;
                        end

                        9:begin
                           nRead = 0;
                           address = 16'b 0010_0000_0101_0010;//Result Address
                        end

                        11:begin
                           Result = MatrixDataOut;
                           nRead = 1;
                        end

                        12:begin
                           ExeDataOut = Result;
                           nWrite = 0;
                           address = 16'h 0000 + destAddress;
                        end

                        13:begin
                           nWrite = 1;
                           currentOperation = CLEAR;
                        end

                        default:begin  //OPeration has failed, continue to next one
                           if(clkCounter > 15)begin
                              currentOperation = CLEAR;
                           end
                        end

                     endcase

                     if (clkCounter != 0) begin    //Does this every time
                        clkCounter++;
                     end//if

                  end
                  //
                  // INTADD:begin
                  //    case (clkCounter)
                  //       //Begin Get data from main Mem
                  //       1: begin //prepare to get src1 data
                  //          nRead = 0;
                  //          address = 16'h 0000 + src1Address;
                  //       end
                  //
                  //       3: begin    //Get src1 data and prepare to get src2 data
                  //          src1Data = MemDataOut;
                  //          address = 16'h 0000 + src2Address;
                  //
                  //       end
                  //
                  //       5: begin    //Get src2 Data
                  //          src2Data = MemDataOut;
                  //          nRead = 1;
                  //       end
                  //       //End get data from main memory
                  //
                  //       //Begin put data in IntegerALU
                  //       6:begin
                  //          address = 16'b 0011_0000_0000_0000;  //Int  add src1 Address
                  //          ExeDataOut = src1Data;
                  //          nWrite = 0;
                  //       end
                  //
                  //       7:begin  //write data2 to ALU
                  //          address = 16'b 0011_0000_0000_0001;
                  //          ExeDataOut = src2Data;
                  //       end
                  //
                  //       8:begin //Command ALU to do Math. At this point,could put diffrent data into ALU
                  //          nWrite = 1;
                  //          address = 16'b 0011_0000_0000_0011;
                  //       end
                  //
                  //       9:begin  //Request Result
                  //          nRead = 0;
                  //          address = 16'b 0011_0000_0000_0010;
                  //       end
                  //
                  //       11:begin //Write result to Engin
                  //          Result = IntDataOut;
                  //          nRead = 1;
                  //       end
                  //
                  //       12:begin //Write Result to  Memory
                  //          ExeDataOut = Result;
                  //          nWrite = 0;
                  //          address = 16'h 0000 + destAddress;
                  //       end
                  //
                  //       13:begin //End operation
                  //          nWrite = 1;
                  //          currentOperation = CLEAR;
                  //       end
                  //
                  //       default:begin  //OPeration has failed, continue to next one
                  //          if(clkCounter > 15)begin
                  //             currentOperation = CLEAR;
                  //          end
                  //       end
                  //
                  //    endcase
                  //
                  //    if (clkCounter != 0) begin    //Does this every time
                  //       clkCounter++;
                  //    end
                  //
                  // end
                  //
                  // INTSUB: begin
                  //    case (clkCounter)
                  //       //Begin Get data from main Mem
                  //       1: begin //prepare to get src1 data
                  //          nRead = 0;
                  //          address = 16'h 0000 + src1Address;
                  //       end
                  //
                  //       3: begin    //Get src1 data and prepare to get src2 data
                  //          src1Data = MemDataOut;
                  //          address = 16'h 0000 + src2Address;
                  //
                  //       end
                  //
                  //       5: begin    //Get src2 Data
                  //          src2Data = MemDataOut;
                  //          nRead = 1;
                  //       end
                  //       //End get data from main memory
                  //
                  //       //Begin put data in IntegerALU
                  //       6:begin
                  //          address = 16'b 0011_0000_0001_0000;  //Int subtract src1 Address
                  //          ExeDataOut = src1Data;
                  //          nWrite = 0;
                  //       end
                  //
                  //       7:begin  //write data2 to ALU
                  //          address = 16'b 0011_0000_0001_0001;
                  //          ExeDataOut = src2Data;
                  //       end
                  //
                  //       8:begin //Command ALU to do Math. At this point,could put diffrent data into ALU
                  //          nWrite = 1;
                  //          address = 16'b 0011_0000_0001_0011;
                  //       end
                  //
                  //       9:begin  //Request Result
                  //          nRead = 0;
                  //          address = 16'b 0011_0000_0001_0010;
                  //       end
                  //
                  //       11:begin //Write result to Engin
                  //          Result = IntDataOut;
                  //          nRead = 1;
                  //       end
                  //
                  //       12:begin //Write Result to  Memory
                  //          ExeDataOut = Result;
                  //          nWrite = 0;
                  //          address = 16'h 0000 + destAddress;
                  //       end
                  //
                  //       13:begin //End operation
                  //          nWrite = 1;
                  //          currentOperation = CLEAR;
                  //       end
                  //
                  //       default:begin  //OPeration has failed, continue to next one
                  //          if(clkCounter > 15)begin
                  //             currentOperation = CLEAR;
                  //          end
                  //       end
                  //
                  //    endcase
                  //
                  //    if (clkCounter != 0) begin    //Does this every time
                  //       clkCounter++;
                  //    end
                  // end
                  //
                  // INTMULTIPLY:begin
                  //    case (clkCounter)
                  //       //Begin Get data from main Mem
                  //       1: begin //prepare to get src1 data
                  //          nRead = 0;
                  //          address = 16'h 0000 + src1Address;
                  //       end
                  //
                  //       3: begin    //Get src1 data and prepare to get src2 data
                  //          src1Data = MemDataOut;
                  //          address = 16'h 0000 + src2Address;
                  //
                  //       end
                  //
                  //       5: begin    //Get src2 Data
                  //          src2Data = MemDataOut;
                  //          nRead = 1;
                  //       end
                  //       //End get data from main memory
                  //
                  //       //Begin put data in IntegerALU
                  //       6:begin
                  //          address = 16'b 0011_0000_0010_0000;  //Int multiply src1 Address
                  //          ExeDataOut = src1Data;
                  //          nWrite = 0;
                  //       end
                  //
                  //       7:begin  //write data2 to ALU
                  //          address = 16'b 0011_0000_0010_0001;
                  //          ExeDataOut = src2Data;
                  //       end
                  //
                  //       8:begin //Command ALU to do Math. At this point,could put diffrent data into ALU
                  //          nWrite = 1;
                  //          address = 16'b 0011_0000_0010_0011;
                  //       end
                  //
                  //       9:begin  //Request Result
                  //          nRead = 0;
                  //          address = 16'b 0011_0000_0010_0010;
                  //       end
                  //
                  //       11:begin //Write result to Engin
                  //          Result = IntDataOut;
                  //          nRead = 1;
                  //       end
                  //
                  //       12:begin //Write Result to  Memory
                  //          ExeDataOut = Result;
                  //          nWrite = 0;
                  //          address = 16'h 0000 + destAddress;
                  //       end
                  //
                  //       13:begin //End operation
                  //          nWrite = 1;
                  //          currentOperation = CLEAR;
                  //       end
                  //
                  //       default:begin  //OPeration has failed, continue to next one
                  //          if(clkCounter > 15)begin
                  //             currentOperation = CLEAR;
                  //          end
                  //       end
                  //
                  //    endcase
                  //
                  //    if (clkCounter != 0) begin    //Does this every time
                  //       clkCounter++;
                  //    end
                  // end
                  //
                  // INTDIV:begin
                  //    case (clkCounter)
                  //       //Begin Get data from main Mem
                  //       1: begin //prepare to get src1 data
                  //          nRead = 0;
                  //          address = 16'h 0000 + src1Address;
                  //       end
                  //
                  //       3: begin    //Get src1 data and prepare to get src2 data
                  //          src1Data = MemDataOut;
                  //          address = 16'h 0000 + src2Address;
                  //
                  //       end
                  //
                  //       5: begin    //Get src2 Data
                  //          src2Data = MemDataOut;
                  //          nRead = 1;
                  //       end
                  //       //End get data from main memory
                  //
                  //       //Begin put data in IntegerALU
                  //       6:begin
                  //          address = 16'b 0011_0000_0011_0000;  //Int div src1 Address
                  //          ExeDataOut = src1Data;
                  //          nWrite = 0;
                  //       end
                  //
                  //       7:begin  //write data2 to ALU
                  //          address = 16'b 0011_0000_0011_0001;
                  //          ExeDataOut = src2Data;
                  //       end
                  //
                  //       8:begin //Command ALU to do Math. At this point,could put diffrent data into ALU
                  //          nWrite = 1;
                  //          address = 16'b 0011_0000_0011_0011;
                  //       end
                  //
                  //       9:begin  //Request Result
                  //          nRead = 0;
                  //          address = 16'b 0011_0000_0011_0010;
                  //       end
                  //
                  //       11:begin //Write result to Engin
                  //          Result = MatrixDataOut;
                  //          nRead = 1;
                  //       end
                  //
                  //       12:begin //Write Result to  Memory
                  //          ExeDataOut = Result;
                  //          nWrite = 0;
                  //          address = 16'h 0000 + destAddress;
                  //       end
                  //
                  //       13:begin //End operation
                  //          nWrite = 1;
                  //          currentOperation = CLEAR;
                  //       end
                  //
                  //       default:begin  //OPeration has failed, continue to next one
                  //          if(clkCounter > 15)begin
                  //             currentOperation = CLEAR;
                  //          end
                  //       end
                  //
                  //    endcase
                  //
                  //    if (clkCounter != 0) begin    //Does this every time
                  //       clkCounter++;
                  //    end
                  // end //INTDIV

               endcase//operation
            end //EXCUTEINSTUCTION

            CLEAR:begin
               PC++;
               nWrite = 1;
               nRead = 1;
               ExeDataOut = 256'h x;
               clkCounter = 0;
            end

            //if program messes up, the default action is to ignore the current operation, reset any onboard data except for the
            // program counter, then start with the next instuction.
            // Essentaly acts as a reset
            default:begin
               PC++;
               nWrite = 1;
               nRead = 1;
               ExeDataOut = 256'b x;
               address = 0;
               clkCounter = 0;
               destAddress = 0;
               Result = 0;
               src1Data = 0;
               src1Address = 0;
               src2Data = 0;
               src2Address = 0;
               currentOperation = 0;
               operation = 0;
               opCode = 0;
            end

         endcase //currentOperation
      end ////if(nReset != 0 && complete == 0)
   end //always_ff @(posedge Clk)

endmodule

///////////////////////////////////////
// FILE: MatrixALU.sv                //
// LastEdited 11/9/2021              //
// Created by: JESUS RIVERA III      //
///////////////////////////////////////
//  InsturctionMem->ExcutionEngin->Comunitcate opCode
//    -> comunicate data from excute to MatrixALU-> preform operations
//    -> matrixDataOut to ExcutionEngin ->ExcutionEnginResult to Main Mem
//    -> Get next instuction...cont...
//
//
///////////////////////////////////////
//Address determins what operatin the ALU is preforming
// Bits 3:0 are internal memory
// Bits 7:4 are the 6 Matrix operations
// 16'h 2000_0000_0001_0000 is matrix add, src1
// 16'h 2000_0000_0001_0001 is matrix add, src2
// 16'h 2000_0000_0001_0002 is matrix add, Result
//
//
//Scale and SCALEIMMEDIATE could use the same exact code
module MatrixALU (Clk, ExeDataOut,MatrixDataOut, address, nRead, nWrite, nReset,);
   parameter MULTIPLY = 4'h 00;
   parameter ADD = 4'h 01;
   parameter SUBTRACT = 4'h 02;
   parameter TRANSPOSE = 4'h 03;
   parameter SCALE = 4'h 04;
   parameter SCALEIMMEDIATE =4'h 05;
   input logic Clk, nRead, nWrite, nReset;
   input logic [255:0] ExeDataOut;
   output logic [255:0] MatrixDataOut;

   reg [3:0][3:0][15:0]src1Data;
   reg [3:0][3:0][15:0]src2Data;
   reg [3:0][3:0][15:0] result;

   always @ (posedge Clk or negedge nReset ) begin
      if (nReset == 0) begin

      end
      if (address[15:12]== 4'h 2000 && nReset != 0) begin
         case (address[7:4])
            MULTIPLY:begin
               //nothing yet
            end

            ADD:begin
               if (address[3:0] == 3) begin //Do the addition operation
                  for (int i = 0; i < 4; ++) begin
                     for (int j = 0;  < 4; ++) begin
                        result[i][j] = src1Data[i][j] + src2[i][j];
                     end
                  end
               end

               if (nWrite == 0 && nRead != 0) begin //Get data from Excution
                  case (address[3:0])
                     0:src1Data = ExeDataOut;
                     1:src2Data = ExeDataOut;
                     default://Nothing yet, Error code eventualy ;
                  endcase
               end

               if (nRead == 0 && nWrite != 0) begin //Data out to Excution
                  if (address[3:0] == 4'b 0010) begin
                     MatrixDataOut = result;
                  end
               end

            end

            SUBTRACT:begin
               //nothing yet
            end

            TRANSPOSE:begin
               //NOthing yet
            end

            SCALE:begin
               //Nothing yet
            end

            SCALEIMMEDIATE: begin
               //nothing yet
            end
            default://Does nothing for now, will determ and code for errors later  ;
         endcase
      end
   end

endmodule

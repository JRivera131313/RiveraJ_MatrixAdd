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
module MatrixALU (Clk, ExeDataOut,MatrixDataOut, address, nRead, nWrite, nReset);
   parameter MULTIPLY = 4'h 0;
   parameter ADD = 4'h 1;
   parameter SUBTRACT = 4'h 2;
   parameter TRANSPOSE = 4'h 3;
   parameter SCALE = 4'h 4;
   parameter SCALEIMMEDIATE =4'h 5;

   input logic Clk, nRead, nWrite, nReset;
   input logic [15:0] address;
   input logic [255:0] ExeDataOut;
   output logic [255:0] MatrixDataOut;

   reg [3:0][3:0][15:0]src1Data;
   reg [3:0][3:0][15:0]src2Data;
   reg [3:0][3:0][15:0] result;

   always @ (posedge Clk or negedge nReset ) begin
      if (nReset == 0) begin

      end
      if (address[15:12]== 4'h 2 && nReset != 0) begin

         if (nWrite == 0 && nRead != 0) begin //Get data from Excution
            case (address[3:0])
               0:src1Data = ExeDataOut;
               1:src2Data = ExeDataOut;
               default: ;//Nothing yet, Error code eventualy ;
            endcase
         end

         if (nRead == 0 && nWrite != 0) begin //Data out to Excution
            if (address[3:0] == 4'b 0010) begin
               MatrixDataOut = result;
            end
         end

         if (address[3:0] == 4'h 3) begin
            case (address[7:4])
               MULTIPLY:begin
                  //nothing yet
               end

               ADD:begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] + src2Data[i][j];
                        $display ("Result [%d] [%d] is :%d\n",i,j,result[i][j]);
                     end
                  end
               end

               SUBTRACT:begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] - src2Data[i][j];
                        $display ("Result [%d] [%d] is :%d\n",i,j,result[i][j]);
                     end
                  end
               end

               TRANSPOSE: begin
                  //nothing yet
               end

               SCALE: begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] * src2Data;
                        $display ("Result [%d] [%d] is :%d\n",i,j,result[i][j]);
                     end
                  end
               end

               default: ;//Does nothing for now, will determ and code for errors later  ;
            endcase
         end

      end
   end

endmodule

///////////////////////////////////////
// FILE: IntegerALU.sv                //
// LastEdited 11/11/2021              //
// Created by: JESUS RIVERA III      //
///////////////////////////////////////
//  InsturctionMem->ExcutionEngin->Comunitcate opCode
//    -> comunicate data from excute to IntegerALU-> preform operations
//    -> IntDataOut to ExcutionEngin ->ExcutionEnginResult to Main Mem
//    -> Get next instuction...cont...
//
//
///////////////////////////////////////
//Address determins what operatin the ALU is preforming
// Bits 3:0 are internal memory
// Bits 7:4 are the 6 integer operations
//
//
//
//Scale and SCALEIMMEDIATE could use the same exact code
module IntegerALU (Clk, ExeDataOut,IntDataOut, address, nRead, nWrite, nReset);
   parameter ADD = 4'h 0;
   parameter SUBTRACT = 4'h 1;
   parameter MULTIPLY = 4'h 2;
   parameter DIVIDE = 4'h 3;

   input logic Clk, nRead, nWrite, nReset;
   input logic [15:0] address;
   input logic [255:0] ExeDataOut;

   output logic [255:0] IntDataOut;

   reg [255:0] src1Data;
   reg [255:0] src2Data;
   reg [255:0] result;

   always @ (posedge Clk or negedge nReset ) begin
      if (nReset == 0) begin
         src1Data = 0;
         src2Data = 0;
         result = 0;
         IntDataOut = 256'd x;
      end
      if (address[15:12]== 4'h 3 && nReset != 0) begin

         if (nWrite == 0 && nRead != 0) begin //Get data from Excution
            case (address[3:0])
               0:src1Data = ExeDataOut[15:0];
               1:src2Data = ExeDataOut[15:0];
               default: ;//Nothing yet, Error code eventualy ;
            endcase
         end

         if (nRead == 0 && nWrite != 0) begin //Data out to Excution
            if (address[3:0] == 4'b 0010) begin
               IntDataOut = result;
            end
         end

         if (address[3:0] == 4'h 3) begin
            case (address[7:4])
               MULTIPLY:begin
                  result = src1Data * src2Data;
                  $display("Integer Multiply %d x %d = %d ",src1Data,src2Data,result);
                  $display("Integer Multiply Result is: %h",result);
               end

               ADD:begin
                  result = src1Data + src2Data;
                  $display("Integer Add %d + %d = %d ",src1Data,src2Data,result);
                  $display("Integer Add Result is: %h",result);
               end

               SUBTRACT:begin
                  result = src1Data - src2Data;
                  $display("Integer Subtract %d x %d = %d ",src1Data,src2Data,result);
                  $display("Integer Subtract  Result is: %h",result);
               end

               DIVIDE: begin
                  result = src1Data / src2Data;
                  $display("Integer Divide %d / %d = %d ",src1Data,src2Data,result);
                  $display("Integer Divide Result is: %h",result);
               end


               default: ;//Does nothing for now, will determ and code for errors later  ;

            endcase
         end

      end
   end

endmodule

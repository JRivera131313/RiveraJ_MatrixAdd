///////////////////////////////////////
// FILE: MatrixALU.sv                //
// LastEdited 11/17/2021              //
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
module MatrixAlu (Clk, MatrixDataOut, ExeDataOut, address, nRead, nWrite, nReset);
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
                  result = 0;
                  for (int Row = 0; Row < 4; Row++) begin
                     for (int Colum = 0; Colum < 4; Colum++) begin
                        for (int kounter = 0; kounter < 4; kounter++) begin
                           result[Row][Colum] = result [Row][Colum] + (src1Data[Row][kounter] * src2Data[kounter][Colum]);
                        end
                     end
                  end
                  $display("\n Begin Matraix MULTIPLY");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("Matrix 2 is:");
                  $display("{%d,%d,%d,%d}",src2Data[3][3],src2Data[3][2],src2Data[3][1],src2Data[3][0]);
                  $display("{%d,%d,%d,%d}",src2Data[2][3],src2Data[2][2],src2Data[2][1],src2Data[2][0]);
                  $display("{%d,%d,%d,%d}",src2Data[1][3],src2Data[1][2],src2Data[1][1],src2Data[1][0]);
                  $display("{%d,%d,%d,%d}",src2Data[0][3],src2Data[0][2],src2Data[0][1],src2Data[0][0]);

                  $display("Matrix 1 * Matrix 2 =:");
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);

                  $display("Matrix Multiply Result is: %h",result);
               end

               ADD:begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] + src2Data[i][j];
                     end
                  end
                  $display("\n Begin Matraix Add");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("Matrix 2 is:");
                  $display("{%d,%d,%d,%d}",src2Data[3][3],src2Data[3][2],src2Data[3][1],src2Data[3][0]);
                  $display("{%d,%d,%d,%d}",src2Data[2][3],src2Data[2][2],src2Data[2][1],src2Data[2][0]);
                  $display("{%d,%d,%d,%d}",src2Data[1][3],src2Data[1][2],src2Data[1][1],src2Data[1][0]);
                  $display("{%d,%d,%d,%d}",src2Data[0][3],src2Data[0][2],src2Data[0][1],src2Data[0][0]);

                  $display("Matrix 1 + Matrix 2 =:");
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);

                  $display("Matrix Add Result is(hex): %h",result);
               end

               SUBTRACT:begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] - src2Data[i][j];
                     end
                  end
                  $display("\n Begin Matraix SUBTRACT");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("Matrix 2 is:");
                  $display("{%d,%d,%d,%d}",src2Data[3][3],src2Data[3][2],src2Data[3][1],src2Data[3][0]);
                  $display("{%d,%d,%d,%d}",src2Data[2][3],src2Data[2][2],src2Data[2][1],src2Data[2][0]);
                  $display("{%d,%d,%d,%d}",src2Data[1][3],src2Data[1][2],src2Data[1][1],src2Data[1][0]);
                  $display("{%d,%d,%d,%d}",src2Data[0][3],src2Data[0][2],src2Data[0][1],src2Data[0][0]);

                  $display("Matrix 1 - Matrix 2 =:");
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);
                  $display(" Matrix Subtract  Result is: %h",result);
               end

               TRANSPOSE: begin
                  result = 0;
                  for (int Row = 0; Row < 4; Row++) begin
                     for (int Colum = 0; Colum < 4; Colum++) begin
                        result[Row][Colum] = src1Data[Colum][Row];
                     end
                  end
                  $display("\n Begin Matraix TRANSPOSE");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("Trasnpose Matrix 1 =:");
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);
                  $display("Matrix 1 Transpose Result is: %h",result);
               end

               SCALE: begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] * src2Data;
                     end
                  end
                  $display("\n Begin Matraix SCALE");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("The Scale factor is%d.",src2Data);

                  $display("Matrix 1 *%d =",src2Data);
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);

                  $display ("Matrix Scale Result is :%h\n",result);
               end

               SCALEIMMEDIATE: begin
                  for (int i = 0; i < 4; i++) begin
                     for (int j = 0; j < 4; j++) begin
                        result[i][j] = src1Data[i][j] * src2Data;
                     end
                  end
                  $display("\n Begin Matraix SCALEIMMEDIATE");
                  $display("Matrix 1 is:");
                  $display("{%d,%d,%d,%d}",src1Data[3][3],src1Data[3][2],src1Data[3][1],src1Data[3][0]);
                  $display("{%d,%d,%d,%d}",src1Data[2][3],src1Data[2][2],src1Data[2][1],src1Data[2][0]);
                  $display("{%d,%d,%d,%d}",src1Data[1][3],src1Data[1][2],src1Data[1][1],src1Data[1][0]);
                  $display("{%d,%d,%d,%d}\n",src1Data[0][3],src1Data[0][2],src1Data[0][1],src1Data[0][0]);

                  $display("The Immediate Scale factor is%d.",src2Data);

                  $display("Matrix 1 *%d =",src2Data);
                  $display("{%d,%d,%d,%d}",result[3][3],result[3][2],result[3][1],result[3][0]);
                  $display("{%d,%d,%d,%d}",result[2][3],result[2][2],result[2][1],result[2][0]);
                  $display("{%d,%d,%d,%d}",result[1][3],result[1][2],result[1][1],result[1][0]);
                  $display("{%d,%d,%d,%d}",result[0][3],result[0][2],result[0][1],result[0][0]);

                  $display ("Matrix ScaleImmediate Result is :%h\n",result);
               end
               default: ;//Does nothing for now, will determ and code for errors later  ;
            endcase
         end

      end
   end

endmodule

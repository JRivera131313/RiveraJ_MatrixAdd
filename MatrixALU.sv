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
module MatrixALU (Clk, ExeDataOut,MatrixDataOut, address, nRead, nWrite, nReset,);

endmodule

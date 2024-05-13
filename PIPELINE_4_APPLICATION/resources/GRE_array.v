`define WIDTH_PIPELINE 128 

module GRE_array(
    input Clk,Rst,write_enable,flush,
    input     [180:0] in,
    output reg[180:0] out
    );

    always@(posedge Clk,posedge Rst)
    begin
       if(Rst) begin out = 0; end
        else 
        begin
            if(write_enable)//whether write to an pipeline register is permitted
            begin
                if(flush)//whether it is to be flushed 
                    out=0;
                else
                    out =in;
            end
        end
   end

   
endmodule
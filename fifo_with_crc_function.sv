virtual class fifo;   
  pure virtual function int write(); 
  pure virtual function int read();
  pure virtual function bit fifo_full();
  pure virtual function bit fifo_empty();
 endclass
 
    class fifo_imp extends fifo;
      static int counter;
      bit [16-1:0] data_in;
      bit [16:0] new_data_in; // data_in with crc bit
      
      function int write(); 
       bit crc_bit;
       int wr_enb = 1;  
       counter = counter+1;    
       std::randomize(data_in);
       return data_in;
  endfunction
    
    function int read();
      int rd_enb = 1;
      counter = counter - 1;
      return 1;
    endfunction
      
      function bit fifo_full();
        bit full_signal;
        if(counter == 32)
           full_signal = 1;
        return full_signal;
      endfunction
      
      function bit fifo_empty();
        bit empty_signal;
        if(counter == 0)
          empty_signal = 1;
        return empty_signal;
      endfunction
endclass
    
    class fifo_peak extends fifo_imp;
      function int read_data(ref bit [16:0] array[$]);
        read_data = array.pop_front();
      endfunction
    endclass      
      
 module test;
   bit [16:0] array[$];
   bit [16-1:0] data_in;
   bit [16:0] data_out;
   bit [16:0] data_in_with_crc;
   bit CRC;
   
   fifo_imp input_fifo= new();
   fifo_peak output_fifo = new();
   
   initial begin
     
     $display("-----Performing write operation 40 times---");
     repeat(40) begin
     if(input_fifo.fifo_full()) begin
     $display("FIFO is full");
       end
       else begin
     if(input_fifo.fifo_empty())
     $display("FIFO is empty");
     data_in = input_fifo.write();
     data_in_with_crc = crc_generator(data_in);
     array.push_back(data_in_with_crc);
         $display("write pointer is at %0d",input_fifo.counter);
     end 
     end
     $display("data that is written in order = %0p",array);


     
     $display("----Performing read operation 3 times------");
     repeat(3) begin
     if(input_fifo.fifo_empty())
     $display("FIFO is empty");
      else begin
     input_fifo.read();
     data_out = output_fifo.read_data(array);
       $display("data being read %0d" ,data_out); 
       CRC = ^data_out;
       $display("CRC = %0d",CRC);
     end
     end
     
     $display("-----Performing write operation 1 time---");
     if(input_fifo.fifo_full()) begin
     $display("FIFO is full");
     end
     else begin
     if(input_fifo.fifo_empty())
     $display("FIFO is empty");
     data_in = input_fifo.write();
     data_in_with_crc = crc_generator(data_in);
     array.push_back(data_in_with_crc);
     $display("write pointer is at %0d",input_fifo.counter);
     end
     $display("data that is written in order = %0p",array);
     
     $display("----Performing read operation 35 time------");
     repeat(35) begin
     if(input_fifo.fifo_empty())
     $display("FIFO is empty");
     else begin
     input_fifo.read();
     data_out = output_fifo.read_data(array);
     $display("data being read %0d" ,data_out); 
     end
   end
  end
 endmodule
     
    function int crc_generator(bit [16-1:0] data_in);
      bit crc_bit;
      bit [16:0] new_data_in;
      crc_bit = ^data_in;
      new_data_in = {crc_bit, data_in};
      return new_data_in;
    endfunction

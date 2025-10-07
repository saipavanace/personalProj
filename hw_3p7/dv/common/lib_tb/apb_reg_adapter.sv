
import uvm_pkg::*;

class apb_reg_adapter extends uvm_reg_adapter;
   `uvm_object_param_utils( apb_reg_adapter )
 
   function new( string name = "" );
      super.new( name );
      supports_byte_enable = 0;
      provides_responses   = 0;
   endfunction: new
 
   virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );

      apb_pkt_t m_pkt = apb_pkt_t::type_id::create("m_pkt");
        
      if (rw.kind == UVM_READ )       m_pkt.pwrite = 0;
      else if (rw.kind == UVM_WRITE ) m_pkt.pwrite = 1;
      else                            m_pkt.pwrite = 0;


      if ( rw.kind == UVM_WRITE )  m_pkt.pwdata = rw.data;

      m_pkt.paddr = rw.addr;
      m_pkt.pwdata = rw.data;
      m_pkt.prdata = rw.data;
      m_pkt.psel = 1;

      //`uvm_info("apb_reg_adapter: reg2bus", $sformatf("\nDEBUG_apb_reg_adapter: reg2bus rw.kind = %0d, m_pkt.paddr=%0x, m_pkt.pwdata=%0x, m_pkt.prdata=%0x.....\n", rw.kind, m_pkt.paddr, m_pkt.pwdata, m_pkt.prdata), UVM_LOW);

    return m_pkt;

   endfunction: reg2bus
 
   virtual function void bus2reg( uvm_sequence_item bus_item,
                                  ref uvm_reg_bus_op rw );
      apb_pkt_t m_pkt;
 
      if (!$cast(m_pkt, bus_item))
      begin
         `uvm_fatal( get_name(), "bus_item is not of the apb_pkt_t type.")
         return;
      end
 
      //`uvm_info("apb_reg_adapter: bus2reg", $sformatf("\nDEBUG_apb_reg_adapter: bus2reg rw.kind = %0d, m_pkt.paddr=%0x, m_pkt.pwdata=%0x, m_pkt.prdata=%0x.....\n", rw.kind, m_pkt.paddr, m_pkt.pwdata, m_pkt.prdata), UVM_LOW);

      if (m_pkt.pwrite === 1)
      begin
          rw.kind = UVM_WRITE;
          rw.data = m_pkt.pwdata;
      end
      else if (m_pkt.pwrite === 0)
      begin
          rw.kind = UVM_READ;
          rw.data = m_pkt.prdata;
      end
      else
      begin
          `uvm_error( get_name(), $sformatf("m_pkt.pwrite=%0b", m_pkt.pwrite))
          return;
      end 


      rw.status = UVM_IS_OK;
      rw.addr = m_pkt.paddr;

   endfunction: bus2reg
 
endclass: apb_reg_adapter


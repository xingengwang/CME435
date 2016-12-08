library verilog;
use verilog.vl_types.all;
entity sbiu_core is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        rdy             : out    vl_logic;
        frame           : in     vl_logic;
        adr_data        : in     vl_logic_vector(7 downto 0);
        bus_req         : out    vl_logic;
        bus_gnt         : in     vl_logic;
        valid           : out    vl_logic;
        wait_sig        : in     vl_logic;
        src_adr_out     : out    vl_logic_vector(7 downto 0);
        dst_adr_out     : out    vl_logic_vector(7 downto 0);
        data_out        : out    vl_logic_vector(7 downto 0)
    );
end sbiu_core;

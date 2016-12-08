library verilog;
use verilog.vl_types.all;
entity ds_intf_if is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic
    );
end ds_intf_if;

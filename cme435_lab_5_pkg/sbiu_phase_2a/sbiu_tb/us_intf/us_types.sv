parameter US_BUS_WIDTH = 8;

typedef logic [US_BUS_WIDTH-1:0] us_data_t;
typedef enum bit [US_BUS_WIDTH-1:0] {TX_DATA=0, CMD=1, HBEAT=2} us_pkt_type_t;


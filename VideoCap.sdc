create_clock -period 25MHz -name {clk} [get_ports {clk}]
derive_pll_clocks
create_clock -period 50MHz -name {VI_CLK} [get_ports {VI_CLK}]

#set_false_path -from [get_keepers {reset:u_board_reset|r_cnt[2]}]

#set_false_path -from [get_keepers {stream_cap:u_stream|r_y_act*}] -to [get_keepers {sdram_ctrl:u_sdram|r_addr*}]
#set_false_path -from [get_keepers {video:u_vo|video_uni:u_uni|r_y*}]
#set_false_path -from [get_keepers {video:u_vo|sync_gen:u_sync_h|r_is_active}]

set_false_path -from [get_keepers {stream_cap:u_stream|vcap_regs:u_regs|r_*}]
set_false_path -from [get_keepers {video:u_vo|vctrl_regs:u_vregs|r_*}]

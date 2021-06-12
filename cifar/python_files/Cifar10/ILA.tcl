for {set i 0} {$i < 50} {incr i} {
	run_hw_ila hw_ila_1
	wait_on_hw_ila hw_ila_1
	upload_hw_ila_data hw_ila_1
	write_hw_ila_data -csv_file C:/Users/admin/Desktop/ilas/msg_$i.csv hw_ila_data_1
}
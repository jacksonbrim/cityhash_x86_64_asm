file out/cityhash
break _start 
break cityhash64 
break cityhash64.loop
break cityhash64.return_above_64_bytes
break cityhash64.return_below_64_bytes
break cityhash64.return_0_to_32_bytes
break cityhash64.return_0_to_16_bytes
break hashlen33to64
break hashlen33to64.v_set
break hashlen33to64.w_set
break hashlen33to64.y_set
break hashlen33to64.x_set
break hashlen17to32
break hashlen0to16

run "This is a 40 character long test string."

continue
continue

adb tcpip 5555
adb connect 192.168.85.37:5555
nohup scrcpy --video-bit-rate 40M --turn-screen-off > /home/leorio/log/scrcpy.log 2>&1 &

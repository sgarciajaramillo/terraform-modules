Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname ${fgt_id}
end
config system admin
edit "admin"
set password ${fgt_admin_password}
next
end
config system interface
edit port1
set alias public
set mode static
set ip ${Port1IP}
set allowaccess ping https ssh fgfm
set mtu-override enable
set mtu 9001
next
edit port2
set alias private
set mode static
set ip ${Port2IP}
set allowaccess ping
set mtu-override enable
set mtu 9001
next
edit port3
set alias hasync
set mode static
set ip ${Port3IP}
set allowaccess ping
set mtu-override enable
set mtu 9001
next
edit port4
set alias hamgmt
set mode static
set ip ${Port4IP}
set allowaccess ping https ssh
set mtu-override enable
set mtu 9001
next
end
config router static
edit 1
set device port1
set gateway ${PublicSubnetRouterIP}
next
edit 2
set device port2
set dst ${PrivateSubnet}
set gateway ${PrivateSubnetRouterIP}
next
edit 3
set device port2
set dst ${Private2Subnet}
set gateway ${PrivateSubnetRouterIP}
next
edit 4
set device port2
set dst ${spoke1_cidr}
set gateway ${tgw_gw}
next
edit 5
set device port2
set dst ${spoke2_cidr}
set gateway ${tgw_gw}
next
end
config firewall address
edit toSpoke1
set subnet ${spoke1_cidr}
next
edit toSpoke2
set subnet ${spoke2_cidr}
next
edit toMgmt
set subnet ${mgmt_cidr}
next
end
config firewall addrgrp
edit to-WEST
set member toSpoke1 toSpoke2 toMgmt
end
config firewall policy
edit 1
set name East-West
set srcintf port2
set dstintf port2
set srcaddr all
set dstaddr to-WEST
set action accept
set schedule always
set service ALL
set logtraffic all
next
edit 2
set name South-North
set srcintf port2
set dstintf port1
set srcaddr all
set dstaddr to-WEST
set dstaddr-negate enable
set action accept
set schedule always
set service ALL
set logtraffic all
set nat enable
end
config system ha
set group-name fortinet
set group-id 1
set password ${fgt_ha_password}
set mode a-p
set hbdev port3 50
set session-pickup enable
set ha-mgmt-status enable
config ha-mgmt-interface
edit 1
set interface port4
set gateway ${mgmt_gw}
next
end
set override disable
set priority ${fgt_priority}
set unicast-hb enable
set unicast-hb-peerip ${fgt-remote-heartbeat}
end

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${fgt_byol_license}

--===============0086047718136476635==--
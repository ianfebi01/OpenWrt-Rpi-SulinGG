#!/bin/bash
#=================================================
# File name: init-settings.sh
# Description: This script will be executed during the first boot
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

# Disable opkg signature check
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
# Interface
uci set network.wan=interface
uci set network.wan.ifname='eth1'
uci set network.wan.force_link='1'
uci set network.wan.proto='none'
uci commit
# wireless
uci set wireless.@wifi-device[0].disabled="0"
uci set wireless.@wifi-iface[0].disabled="0"
uci set wireless.@wifi-iface[0].ssid="ianfebi01_5G_Raspi"
uci set wireless.@wifi-iface[0].key="jenengmu"
uci set wireless.@wifi-iface[0].encryption="psk2"
uci set wireless.@wifi-device[0].country="ID"
uci set wireless.@wifi-device[0].channel="auto"
uci set wireless.@wifi-device[1].country="ID"
uci set wireless.@wifi-device[1].channel="auto"
uci commit wireless
# Set Timezone to Asia/Jakarta
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci commit
# Set argon as default theme
#uci set argon.@global[0].mode='light'
#uci set luci.main.mediaurlbase='/luci-static/argon'
#uci commit
# Enable /etc/config/xmm-modem
uci set xmm-modem.@xmm-modem[0].enable='1'
uci commit
# Remove watchcat default config
uci delete watchcat.@watchcat[0]
uci commit
# zerotier
uci set zerotier.openwrt_network=zerotier
uci add_list zerotier.openwrt_network.join='db64858fed2b36f4'
uci set zerotier.openwrt_network.enabled='1'
uci commit
# add cron job for modem rakitan
echo '#auto renew ip lease for modem rakitan' >> /etc/crontabs/root
echo '#30 3 * * * echo AT+CFUN=4 | atinout - /dev/ttyUSB1 - && ifdown mm && sleep 3 && ifup mm' >> /etc/crontabs/root
echo '#30 3 * * * ifdown fibocom && sleep 3 && ifup fibocom' >> /etc/crontabs/root
/etc/init.d/cron restart
# remove huawei me909s usb-modeswitch
sed -i -e '/12d1:15c1/,+5d' /etc/usb-mode.json
# remove dw5821e usb-modeswitch
sed -i -e '/413c:81d7/,+5d' /etc/usb-mode.json
# File manager & Openclass
uci set uhttpd.main.ubus_prefix='/ubus'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci set uhttpd.main.index_page='cgi-bin/luci'
uci add_list uhttpd.main.index_page='index.html'
uci add_list uhttpd.main.index_page='index.php'
uci commit uhttpd
/etc/init.d/uhttpd restart
/etc/init.d/uhttpd reload

cat <<'EOF' >/usr/lib/lua/luci/view/openclash/oceditor.htm
<%+header%>
<div class="cbi-map">
<iframe id="oceditor" style="width: 100%; min-height: 650px; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("oceditor").src = window.location.protocol + "//" + window.location.host + "/tinyfm/tinyfm.php?p=etc/openclash";
</script>
<%+footer%>
EOF

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'

# Disable IPV6 ula prefix
sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Check file system during boot
uci set fstab.@global[0].check_fs=1
uci commit

exit 0


local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPContentTypeHeader('text/plain')

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

for _, ifname in ipairs({"enp1s0", "ens5", "ens4"}) do
   interface.select(ifname)

   -- or interface.getHostsInfo ?
   local ipver_filter = 4
   local hosts_stats = interface.getLocalHostsInfo(
      false,
      "column_mac", --sort
      10000, --limit
      0, --skip
      true, --asc
      -- the rest are filters; see https://www.ntop.org/guides/ntopng/api/lua_c/interface/interface_hosts.html?highlight=getlocalhostsinfo#_CPPv412getHostsInfob6stringiib6string6stringiii6stringiiiibbbbb6string
      nil, nil, nil, nil, nil, nil, nil, ipver_filter, nil, nil, false, false, false, false, false)

   print('hosts_count{ifname="'..ifname..'"} '..hosts_stats["numHosts"].."\n")

   for key, value in pairs(hosts_stats.hosts) do
      local mac = value.mac:lower()

      -- ntop gives some hosts from other interfaces, I don't know why. Filed https://github.com/ntop/ntopng/issues/5633
      if ifname == "enp1s0" and not value["ip"]:starts("10.1.") then goto continue end
      if ifname == "ens5" and not value["ip"]:starts("10.2.") then goto continue end
      if ifname == "ens4" and not value["ip"]:starts("192.168.") then goto continue end


      function printMetric(name, value)
         print(string.format('%s{iface="%s",mac="%s"} %f\n', name, ifname, mac, value))
      end

      local info_label = ""
      if(value["ip"] ~= nil) then
         info_label = hostinfo2label(value)
      end

      print(string.format('host_names{iface="%s",mac="%s",ip="%s",label="%s",info_label="%s"} 1.0\n',
                          ifname, mac, value.ip, ip2label(value.ip), info_label))

      printMetric("host_os", value.os)

      local host = interface.getHostInfo(hosts_stats.hosts[key].ip, hosts_stats.hosts[key].vlan)
      if(host ~= nil) then
         printMetric("host_dev_type", host.devtype)
      end

      printMetric("host_is_dhcp", ternary(value.dhcpHost, 1, 0))
      printMetric("host_vlan", value["vlan"])
      printMetric("host_seen_first", value["seen.first"])
      printMetric("host_seen_last", value["seen.last"])
      printMetric("host_throughput_bps", value["throughput_bps"])
      printMetric("host_active_flows_as_client", value["active_flows.as_client"])
      printMetric("host_active_flows_as_server", value["active_flows.as_server"])
      printMetric("host_bytes_sent", value["bytes.sent"])
      printMetric("host_bytes_received", value["bytes.rcvd"])

      print("\n")
      ::continue::
   end
end

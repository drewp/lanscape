-- this is an old copy from /opt/ntop-plugins/lanscape/main.lua

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPContentTypeHeader('text/plain')

for _, ifname in ipairs({"enp1s0", "ens5", "ens4"}) do
   interface.select(ifname)

   -- or interface.getHostsInfo ?
   local hosts_stats = interface.getLocalHostsInfo(
      false,
      "column_mac", --sort
      10000, --limit
      0, --skip
      true, --asc
      -- the rest are filters; see https://www.ntop.org/guides/ntopng/api/lua_c/interface/interface_hosts.html?highlight=getlocalhostsinfo#_CPPv412getHostsInfob6stringiib6string6stringiii6stringiiiibbbbb6string
      nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, false, false, false, false, false)

   print('hosts_count{ifname="'..ifname..'"} '..hosts_stats["numHosts"].."\n")

   for key, value in pairs(hosts_stats.hosts) do
      local mac = value.mac

      function printMetric(name, value)
         print(name..'{iface="'..ifname..'",mac="'..mac..'"} '..value.."\n")
      end

      printMetric("host_ip", value.ip)
      printMetric("host_ip_label", ip2label(value["ip"]))

      if(value["ip"] ~= nil) then
         local label = hostinfo2label(value)

         if label ~= value["ip"] then
            printMetric("host_info_label", label)
         end
      end

      if(value["name"] == nil) then
         local hinfo = hostkey2hostinfo(key)
         printMetric("host_label", hostinfo2label(hinfo))
      end

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
   end
end


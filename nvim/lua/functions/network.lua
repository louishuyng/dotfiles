local os_extend = require 'utils.os_extend'
local M = {}

function M.show_local_ip()
  local local_ip = os_extend.capture(
    'ifconfig | grep inet | grep broadcast | cut -d " " -f 2')

  require("notify")("My local ip: " .. local_ip, "info")
end

function M.show_public_ip()
  local local_ip = os_extend.capture(
    'dig +short myip.opendns.com @resolver1.opendns.com')

  require("notify")("My public ip: " .. local_ip, "info")
end

return M

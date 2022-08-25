get_credo_token() {
  local op_id=$(curl -sk 'https://mycredo.ge:8443/api/Auth/Initiate' \
    -H 'content-type: application/json' \
    --data-raw $"{\"username\":\"$CREDO_LOGIN\",\"password\":\"$CREDO_PWD\",\"channel\":508,\"loggedInWith\":\"4\",\"WebDevicePublicId\":\"ffc8fce4-5cbc-4a3a-b814-a8c33b16c85b\",\"deviceName\":\"Chrome\"}" |
    jq -r .data.operationId)

  curl -sk 'https://mycredo.ge:8443/api/Auth/confirm' \
    -H 'content-type: application/json' \
    --data-raw "{\"OperationId\":\"$op_id\",\"TraceId\":\"VM8B4VMA0Z/UVWt236QFj2bjLgUZYN9nNXRmprBG4pU=\"}" |
    jq -r .data.operationData.token
}

download_credo_xlsx() {
  local currency="${1:-GEL}"
  local token="${2:-$(get_credo_token)}"

  curl -sk 'https://mycredo.ge:8443/graphql' \
    -H "authorization: Bearer $token" \
    -H 'content-type: application/json' \
    --data-raw "{\"variables\":{\"exportToExcel\":{\"accountNumber\":\"$CREDO_ACC\",\"startDate\":\"20100101\",\"endDate\":\"20500101\",\"currency\":\"$currency\"}},\"query\":\"mutation(\$exportToExcel:ExportToExcelInputGType!){exportToExcel(exportToExcel:\$exportToExcel)}\"}" |
    jq -r .data.exportToExcel | base64 -d
}

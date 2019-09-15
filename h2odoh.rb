# H2O HTTP/2 web server as DNS-over-HTTP service
# v.20190908 (c)2018-2019 Max Kostikov, W: https://kostikov.co, E: max@kostikov.co

proc {|env|
    if env['HTTP_ACCEPT'] == "application/dns-message"
        case env['REQUEST_METHOD']
            when "GET"
                req = env['QUERY_STRING'].gsub(/^dns=/,'')
                # base64URL decode
                req = req.tr("-_", "+/")
                if !req.end_with?("=") && req.length % 4 != 0
                    req = req.ljust((req.length + 3) & ~3, "=")
                end
                req = req.unpack1("m")
            when "POST"
                req = env['rack.input'].read
            else
                req = ""
        end
        if req.empty?
            [400, { 'content-type' => 'text/plain' }, [ "Bad Request" ]]
        else
            # --- ask DNS server
            sock = UDPSocket.new
            sock.connect("localhost", 53)
            sock.send(req, 0)
            str = sock.recv(65535)
            sock.close
            # --- find lowest TTL in response
            nans = str[6, 2].unpack1('n') # number of answers
            if nans > 0 # no DNS failure
                shift = 12
                ttl = 0
                while nans > 0
                    # process domain name compression
                    if str[shift].unpack1("C") < 192
                        shift = str.index("\x00", shift) + 5
                        if ttl == 0 # skip question section
                            next
                        end
                    end
                    shift += 6
                    curttl = str[shift, 4].unpack1('N')
                    shift += str[shift + 4, 2].unpack1('n') + 6 # responce data size
                    if ttl == 0 or ttl > curttl
                        ttl = curttl
                    end
                    nans -= 1
                end
                cc = 'max-age=' + ttl.to_s
            else
                cc = 'no-cache'
            end
            [200, { 'content-type' => 'application/dns-message', 'content-length' => str.size, 'cache-control' => cc }, [ str ] ]
        end
    else
        [415, { 'content-type' => 'text/plain' }, [ "Unsupported Media Type" ]]
    end
}

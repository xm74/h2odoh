# h2odoh
This is simple DNS-over-HTTPS service implementation with [H2O](https://github.com/h2o/h2o) HTTP/2 server. Code written using embedded mruby so the only thing you need to run own DoH service is H2O. 

By default it use DNS resolver (Unbound is recommended) running on localhost port 53.

Requires [Socket mrbgem](https://github.com/iij/mruby-socket) build into H2O code. At this moment this gem is in H2O 2.3.0-beta2 but it might be easly added to any version by cloning in `deps` directory before build.

Additional details can be found in article "[Own DNS-over-HTTPS server with H2O web-server](https://kostikov.co/%D1%81%D0%B2%D0%BE%D0%B9-dns-over-https-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80-%D0%BD%D0%B0-%D0%B1%D0%B0%D0%B7%D0%B5-%D0%B2%D0%B5%D0%B1-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0-h2o)" (Russian only).

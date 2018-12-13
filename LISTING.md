## Repository tree

**Symbol** | **Legend**
:-: | ---
🔂 |  Packages that have similar ebuild in main tree, but for personal reasons, we maintain our own versions.
⚠ | [Masked packages](profiles/package.mask), probably insecure/unstable/experimental.

This is a list of supported packages and their associated description:

> **Note:** You will find many packages in tree that are not listed here,
> those packages are temporary ones. We have them because they are a dependency
> for other packages and/or because the package in main tree is too old for our
> needs. You shouldn't rely on them too much, as they can be dropped without notice.

**Package** | **Description**
--- | ---
app-admin/**[consul](app-admin/consul)** 🔂 | A tool for service discovery, monitoring and configuration
app-admin/**[doctl](app-admin/doctl)** | A command line tool for DigitalOcean services
app-admin/**[gollum](app-admin/gollum)** | An n:m message multiplexer written in Go
app-admin/**[gopass](app-admin/gopass)** 🔂 | The slightly more awesome standard unix password manager for teams
app-admin/**[pick](app-admin/pick)** | A minimal password manager written in Go
app-admin/**[terraform](app-admin/terraform)** 🔂 | A tool for building, changing, and combining infrastructure safely/efficiently
app-admin/**[vault](app-admin/vault)** 🔂 | A tool for managing secrets
app-admin/**[vault-client](app-admin/vault-client)** | A CLI to HashiCorp's Vault inspired by pass
app-backup/**[duplicacy](app-backup/duplicacy)** | A new generation cloud backup tool
app-backup/**[restic](app-backup/restic)** 🔂 | A backup program that is fast, efficient and secure
app-benchmarks/**[bombardier](app-benchmarks/bombardier)** | Fast cross-platform HTTP benchmarking tool written in Go
app-benchmarks/**[dnsperfbench](app-benchmarks/dnsperfbench)** | A command line tool to compare performance of DNS resolvers
app-benchmarks/**[fortio](app-benchmarks/fortio)** | A load testing CLI, advanced echo server, and web UI in Go
app-benchmarks/**[hey](app-benchmarks/hey)** 🔂 | HTTP load generator, ApacheBench (ab) replacement
app-benchmarks/**[pewpew](app-benchmarks/pewpew)** | Flexible HTTP command line stress tester for websites and web services
app-benchmarks/**[vegeta](app-benchmarks/vegeta)** | HTTP load testing tool and library. It's over 9000!
app-crypt/**[certspotter](app-crypt/certspotter)** | A Certificate Transparency log monitor from SSLMate
app-crypt/**[enchive](app-crypt/enchive)** | A tool to encrypt files to yourself for long-term archival
app-crypt/**[kbfs](app-crypt/kbfs)** 🔂 | Keybase Filesystem (KBFS)
app-crypt/**[keybase](app-crypt/keybase)** 🔂 | Client for Keybase
app-crypt/**[minisign](app-crypt/minisign)** | A dead simple tool to sign files and verify digital signatures
app-crypt/**[mkcert](app-crypt/mkcert)** 🔂 | A simple tool for making locally-trusted development certificates
app-crypt/**[ssh-vault](app-crypt/ssh-vault)** | Encrypt/Decrypt using SSH private keys
app-editors/**[atom](app-editors/atom)** 🔂 | A hackable text editor for the 21st Century
app-editors/**[micro](app-editors/micro)** | A modern and intuitive terminal-based text editor
app-editors/**[oni](app-editors/oni)** | Code editor with a modern twist on modal editing, powered by Neovim
app-emulation/**[docker](app-emulation/docker)** 🔂 ⚠ | The core functions you need to create Docker images and run Docker containers
app-forensics/**[gitleaks](app-forensics/gitleaks)** | Audit git repos for secrets
app-metrics/**[alertmanager](app-metrics/alertmanager)** 🔂 | Handles alerts sent by client applications such as the Prometheus
app-metrics/**[apache_exporter](app-metrics/apache_exporter)** | Exports apache mod_status statistics via HTTP for Prometheus consumption
app-metrics/**[blackbox_exporter](app-metrics/blackbox_exporter)** 🔂 | Prometheus exporter for blackbox probing via HTTP, HTTPS, DNS, TCP and ICMP
app-metrics/**[collectd_exporter](app-metrics/collectd_exporter)** | A server that accepts collectd stats for Prometheus consumption
app-metrics/**[consul_exporter](app-metrics/consul_exporter)** | Export Consul service health to Prometheus
app-metrics/**[dovecot_exporter](app-metrics/dovecot_exporter)** | A Prometheus metrics exporter for the Dovecot mail server
app-metrics/**[elasticsearch_exporter](app-metrics/elasticsearch_exporter)** 🔂 | Elasticsearch stats exporter for Prometheus
app-metrics/**[graphite_exporter](app-metrics/graphite_exporter)** | A server that accepts Graphite metrics for Prometheus consumption
app-metrics/**[haproxy_exporter](app-metrics/haproxy_exporter)** | Scrapes HAProxy stats and exports them via HTTP for Prometheus consumption
app-metrics/**[influxdb_exporter](app-metrics/influxdb_exporter)** | A server that accepts InfluxDB metrics for Prometheus consumption
app-metrics/**[memcached_exporter](app-metrics/memcached_exporter)** | Exports metrics from memcached servers for consumption by Prometheus
app-metrics/**[mongodb_exporter](app-metrics/mongodb_exporter)** | A Prometheus exporter for MongoDB
app-metrics/**[mysqld_exporter](app-metrics/mysqld_exporter)** 🔂 | Prometheus exporter for MySQL server metrics
app-metrics/**[nginx-vts-exporter](app-metrics/nginx-vts-exporter)** 🔂 | A server that scrapes Nginx vts stats and exports them for Prometheus
app-metrics/**[node_exporter](app-metrics/node_exporter)** 🔂 | Prometheus exporter for hardware and OS metrics exposed by *NIX kernels
app-metrics/**[openvpn_exporter](app-metrics/openvpn_exporter)** 🔂 | A Prometheus exporter for OpenVPN
app-metrics/**[php-fpm_exporter](app-metrics/php-fpm_exporter)** | A Prometheus exporter that connects directly to PHP-FPM
app-metrics/**[phpfpm_exporter](app-metrics/phpfpm_exporter)** | A Prometheus exporter for PHP-FPM
app-metrics/**[postfix_exporter](app-metrics/postfix_exporter)** 🔂 | A Prometheus metrics exporter for the Postfix mail server
app-metrics/**[postgres_exporter](app-metrics/postgres_exporter)** 🔂 | PostgreSQL stats exporter for Prometheus
app-metrics/**[process-exporter](app-metrics/process-exporter)** | A Prometheus exporter that mines /proc to report on selected processes
app-metrics/**[prometheus](app-metrics/prometheus)** 🔂 | The Prometheus monitoring system and time series database
app-metrics/**[pushgateway](app-metrics/pushgateway)** 🔂 | Push acceptor for ephemeral and batch jobs to expose their metrics to Prometheus
app-metrics/**[redis_exporter](app-metrics/redis_exporter)** 🔂 | A server that export Redis metrics for Prometheus consumption
app-metrics/**[script_exporter](app-metrics/script_exporter)** | A Prometheus exporter for shell script exit status and duration
app-metrics/**[sql_exporter](app-metrics/sql_exporter)** | Flexible SQL Exporter for Prometheus
app-metrics/**[ssl_exporter](app-metrics/ssl_exporter)** | Exports Prometheus metrics for SSL certificates
app-metrics/**[statsd_exporter](app-metrics/statsd_exporter)** | Receives StatsD-style metrics and exports them as Prometheus metrics
app-metrics/**[transmission-exporter](app-metrics/transmission-exporter)** | Transmission Exporter for Prometheus
app-metrics/**[unbound_exporter](app-metrics/unbound_exporter)** | A Prometheus exporter for Unbound
app-metrics/**[uwsgi_exporter](app-metrics/uwsgi_exporter)** 🔂 | uWSGI metrics exporter for prometheus.io
app-metrics/**[varnish_exporter](app-metrics/varnish_exporter)** | Varnish exporter for Prometheus
app-misc/**[asciinema-rs](app-misc/asciinema-rs)** | Terminal recording and playback client for asciinema.org, written in Rust
app-misc/**[bat](app-misc/bat)** | A 'cat' clone with syntax highlighting and Git integration
app-misc/**[corgi](app-misc/corgi)** | A CLI workflow manager that helps with your repetitive command usages
app-misc/**[genact](app-misc/genact)** | A nonsense activity generator
app-misc/**[jid](app-misc/jid)** | JSON incremental digger
app-misc/**[pet](app-misc/pet)** 🔂 | Simple command-line snippet manager, written in Go
app-misc/**[vanity-monero](app-misc/vanity-monero)** | Generate vanity address for CryptoNote currency
app-misc/**[watchexec](app-misc/watchexec)** | Executes commands in response to file modifications
app-misc/**[wtf](app-misc/wtf)** | A personal information dashboard for your terminal
app-shells/**[antibody](app-shells/antibody)** | The fastest shell plugin manager
app-shells/**[fzf](app-shells/fzf)** 🔂 | A general-purpose command-line fuzzy finder
app-shells/**[peco](app-shells/peco)** 🔂 | Simplistic interactive filtering tool
app-shells/**[powerline-rs](app-shells/powerline-rs)** | A powerline-shell rewritten in Rust, inspired by powerline-go
app-vim/**[vim-go](app-vim/vim-go)** 🔂 | vim plugin: Go development plugin for Vim
dev-db/**[influxdb](dev-db/influxdb)** 🔂 | Scalable datastore for metrics, events, and real-time analytics
dev-db/**[pgweb](dev-db/pgweb)** | Web-based PostgreSQL database browser written in Go
dev-util/**[drone](dev-util/drone)** 🔂 | Drone is a Continuous Delivery platform built on Docker
dev-util/**[drone-cli](dev-util/drone-cli)** 🔂 | Command line client for the Drone continuous integration server
dev-util/**[electron-bin](dev-util/electron-bin)** 🔂 | Cross platform application development framework based on web technologies
dev-util/**[gitlab-runner](dev-util/gitlab-runner)** | The official GitLab Runner, written in Go
dev-util/**[node-prune](dev-util/node-prune)** | Remove unnecessary files from node_modules (.md, .ts, ...)
dev-vcs/**[fac](dev-vcs/fac)** | Easy-to-use CUI for fixing git conflicts
dev-vcs/**[gitkraken-bin](dev-vcs/gitkraken-bin)** | The intuitive, fast, and beautiful cross-platform Git client
dev-vcs/**[grv](dev-vcs/grv)** | A terminal based interface for viewing Git repositories
dev-vcs/**[hub](dev-vcs/hub)** | A command-line wrapper for git that makes you better at GitHub
dev-vcs/**[lab](dev-vcs/lab)** | Lab wraps Git or Hub to easily interact with repositories on GitLab
mail-filter/**[rspamd](mail-filter/rspamd)** 🔂 | Rapid spam filtering system
media-video/**[peek](media-video/peek)** 🔂 | Simple animated GIF screen recorder with an easy to use interface
net-analyzer/**[amass](net-analyzer/amass)** | In-Depth DNS Enumeration and Network Mapping
net-analyzer/**[aquatone](net-analyzer/aquatone)** | A tool for visual inspection of websites across a large amount of hosts
net-analyzer/**[chronograf](net-analyzer/chronograf)** 🔂 | Open source monitoring and visualization UI for the TICK stack
net-analyzer/**[dirhunt](net-analyzer/dirhunt)** | A web crawler optimized for search and analyze directories
net-analyzer/**[kapacitor](net-analyzer/kapacitor)** 🔂 | A framework for processing, monitoring, and alerting on time series data
net-analyzer/**[telegraf](net-analyzer/telegraf)** 🔂 | An agent for collecting, processing, aggregating, and writing metrics
net-dns/**[acme-dns](net-dns/acme-dns)** | A simplified DNS server with a RESTful HTTP API to provide ACME DNS challenges
net-dns/**[dnscrypt-proxy](net-dns/dnscrypt-proxy)** 🔂 | A tool for securing communications between a client and a DNS resolver
net-dns/**[dnscrypt-wrapper](net-dns/dnscrypt-wrapper)** | A server-side DNSCrypt proxy
net-dns/**[knot](net-dns/knot)** 🔂 | High-performance authoritative-only DNS server
net-dns/**[knot-resolver](net-dns/knot-resolver)** | A caching full DNS resolver implementation written in C and LuaJIT
net-dns/**[unbound](net-dns/unbound)** 🔂 | A validating, recursive and caching DNS resolver
net-firewall/**[firehol](net-firewall/firehol)** 🔂 | A firewall for humans...
net-im/**[dino](net-im/dino)** 🔂 | A modern Jabber/XMPP Client using GTK+/Vala
net-im/**[matterircd](net-im/matterircd)** | Connect to your Mattermost or Slack using your IRC-client of choice
net-im/**[mattermost-desktop](net-im/mattermost-desktop)** 🔂 | Native desktop application for Mattermost
net-im/**[profanity](net-im/profanity)** | A console based XMPP client inspired by Irssi
net-im/**[riot-desktop](net-im/riot-desktop)** | A glossy Matrix collaboration client for desktop
net-im/**[signal-desktop](net-im/signal-desktop)** 🔂 | Signal Private Messenger for the Desktop
net-im/**[slack-term](net-im/slack-term)** | A Slack client for your terminal
net-libs/**[nodejs](net-libs/nodejs)** 🔂 | A JavaScript runtime built on Chrome's V8 JavaScript engine
net-misc/**[cointop](net-misc/cointop)** | A terminal based UI application for tracking cryptocurrencies
net-misc/**[curlie](net-misc/curlie)** | The power of curl, the ease of use of HTTPie
net-misc/**[electron-cash](net-misc/electron-cash)** 🔂 | Lightweight Bitcoin Cash client
net-misc/**[gotty-client](net-misc/gotty-client)** | A terminal client for GoTTY
net-misc/**[piknik](net-misc/piknik)** | Copy/paste anything over the network
net-misc/**[ssf](net-misc/ssf)** | A network toolkit for TCP/UDP port forwarding, SOCKS proxy and remote shell
net-misc/**[ssh-chat](net-misc/ssh-chat)** | A chat over SSH server written in Go
net-misc/**[tinyssh](net-misc/tinyssh)** | A small SSH server with state-of-the-art cryptography
net-p2p/**[bitcoin-abc](net-p2p/bitcoin-abc)** | A full node Bitcoin Cash implementation with GUI, daemon and utils
net-p2p/**[bitcoin-unlimited](net-p2p/bitcoin-unlimited)** | A full node Bitcoin Cash implementation with GUI, daemon and utils
net-p2p/**[bitcoinxt](net-p2p/bitcoinxt)** | A full node Bitcoin Cash implementation with GUI, daemon and utils
net-p2p/**[dash-core](net-p2p/dash-core)** | A peer-to-peer privacy-centric digital currency
net-p2p/**[go-ipfs](net-p2p/go-ipfs)** | IPFS implementation written in Go
net-p2p/**[monero](net-p2p/monero)** | The secure, private and untraceable cryptocurrency
net-p2p/**[monero-gui](net-p2p/monero-gui)** ⚠ | The secure, private and untraceable cryptocurrency (with GUI wallet)
net-p2p/**[parity](net-p2p/parity)** | Fast, light, and robust Ethereum client
net-p2p/**[zcash](net-p2p/zcash)** | Cryptocurrency that offers privacy of transactions
net-proxy/**[ergo](net-proxy/ergo)** | The reverse proxy agent for local domain management
net-proxy/**[fabio](net-proxy/fabio)** | A load balancing and TCP router for deploying applications managed by consul
net-proxy/**[shadowsocks2](net-proxy/shadowsocks2)** | A fresh implementation of Shadowsocks in Go
net-proxy/**[shadowsocks-go](net-proxy/shadowsocks-go)** | A Go port of Shadowsocks
net-proxy/**[shadowsocks-rust](net-proxy/shadowsocks-rust)** | A Rust port of Shadowsocks
net-proxy/**[toxiproxy](net-proxy/toxiproxy)** | A TCP proxy to simulate network and system conditions
net-proxy/**[traefik](net-proxy/traefik)** | A modern HTTP reverse proxy and load balancer made to deploy microservices
net-vpn/**[onioncat](net-vpn/onioncat)** | An IP-Transparent Tor Hidden Service Connector
sys-apps/**[bane](sys-apps/bane)** | AppArmor profile generator for docker containers
sys-apps/**[nvm](sys-apps/nvm)** | A simple bash script to manage multiple active node.js versions
sys-apps/**[yarn](sys-apps/yarn)** 🔂 | Fast, reliable, and secure node dependency management
sys-auth/**[yubikey-touch-detector](sys-auth/yubikey-touch-detector)** | A tool that can detect when your YubiKey is waiting for a touch
sys-fs/**[gocryptfs](sys-fs/gocryptfs)** | Encrypted overlay filesystem written in Go
sys-fs/**[tmsu](sys-fs/tmsu)** 🔂 | Files tagger and virtual tag-based filesystem
sys-process/**[gotop](sys-process/gotop)** | A terminal based graphical activity monitor inspired by gtop and vtop
www-apps/**[cryptpad](www-apps/cryptpad)** | The zero knowledge realtime collaborative editor
www-apps/**[filebrowser](www-apps/filebrowser)** | A stylish web file manager
www-apps/**[gitea](www-apps/gitea)** 🔂 | Gitea - Git with a cup of tea
www-apps/**[gogs](www-apps/gogs)** | A painless self-hosted Git service
www-apps/**[gotty](www-apps/gotty)** | A simple command line tool that turns your CLI tools into web applications
www-apps/**[grafana](www-apps/grafana)** 🔂 | Grafana is an open source metric analytics & visualization suite
www-apps/**[hiawatha-monitor](www-apps/hiawatha-monitor)** 🔂 | Monitoring application for www-servers/hiawatha
www-apps/**[hugo](www-apps/hugo)** 🔂 | A static HTML and CSS website generator written in Go
www-apps/**[mattermost-server](www-apps/mattermost-server)** | Open source Slack-alternative in Golang and React (Team Edition)
www-apps/**[mattermost-server-ee](www-apps/mattermost-server-ee)** | Open source Slack-alternative in Golang and React (Enterprise Edition)
www-apps/**[modoboa](www-apps/modoboa)** | A mail hosting and management platform with a modern and simplified Web UI
www-apps/**[modoboa-dmarc](www-apps/modoboa-dmarc)** | A set of tools to use DMARC through Modoboa
www-client/**[ungoogled-chromium](www-client/ungoogled-chromium)** | Modifications to Chromium for removing Google integration and enhancing privacy
www-client/**[ungoogled-chromium-bin](www-client/ungoogled-chromium-bin)** | Modifications to Chromium for removing Google integration and enhancing privacy
www-misc/**[httplab](www-misc/httplab)** | An interactive web server that let you inspect HTTP requests and forge responses
www-misc/**[wuzz](www-misc/wuzz)** | Interactive cli tool for HTTP inspection
www-plugins/**[browserpass](www-plugins/browserpass)** 🔂 | WebExtension host binary for app-admin/pass, a UNIX password manager
www-servers/**[algernon](www-servers/algernon)** | Pure Go web server with Lua, Markdown, QUIC and Pongo2 support
www-servers/**[caddy](www-servers/caddy)** 🔂 | Fast, cross-platform HTTP/2 web server with automatic HTTPS
www-servers/**[h2o](www-servers/h2o)** 🔂 | An optimized HTTP server with support for HTTP/1.x and HTTP/2
www-servers/**[hiawatha](www-servers/hiawatha)** 🔂 | Advanced and secure webserver
www-servers/**[rest-server](www-servers/rest-server)** | A high performance HTTP server that implements restic's REST backend API
x11-misc/**[noti](x11-misc/noti)** | Trigger notifications when a process completes
x11-misc/**[yagostatus](x11-misc/yagostatus)** | Yet Another i3status replacement written in Go

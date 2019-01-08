# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
aho-corasick-0.6.8
ansi_term-0.10.2
ansi_term-0.11.0
arrayvec-0.4.7
ascii-0.7.1
assert_matches-1.3.0
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
base-x-0.2.3
base64-0.6.0
base64-0.9.2
bincode-0.8.0
bit-set-0.4.0
bit-vec-0.4.4
bitflags-0.7.0
bitflags-0.9.1
bitflags-1.0.4
byteorder-1.2.6
bytes-0.4.10
cc-1.0.25
cesu8-1.1.0
cfg-if-0.1.5
chrono-0.4.6
cid-0.2.3
clap-2.32.0
cloudabi-0.0.3
cmake-0.1.33
combine-3.5.2
crossbeam-0.3.2
crossbeam-deque-0.2.0
crossbeam-deque-0.6.1
crossbeam-epoch-0.3.1
crossbeam-epoch-0.5.2
crossbeam-utils-0.2.2
crossbeam-utils-0.5.0
crunchy-0.1.6
crunchy-0.2.1
ct-logs-0.2.0
daemonize-0.3.0
difference-1.0.0
docopt-0.8.3
edit-distance-2.0.1
either-1.5.0
elastic-array-0.10.0
env_logger-0.5.13
error-chain-0.11.0
error-chain-0.12.0
ethabi-5.1.2
ethabi-contract-5.1.1
ethabi-derive-5.1.3
ethbloom-0.5.0
ethereum-types-0.4.0
ethereum-types-serialize-0.2.1
fdlimit-0.1.1
fixed-hash-0.2.2
fixedbitset-0.1.9
fnv-1.0.6
fs-swap-0.2.4
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.24
futures-cpupool-0.1.8
gcc-0.3.54
getopts-0.2.18
globset-0.2.1
hamming-0.1.3
hashdb-0.3.0
heapsize-0.4.2
heck-0.3.0
hex-0.2.0
home-0.3.3
httparse-1.3.2
humantime-1.1.1
hyper-0.11.27
hyper-rustls-0.11.0
idna-0.1.5
igd-0.7.0
integer-encoding-1.0.5
interleaved-ordered-0.1.1
iovec-0.1.2
ipnetwork-0.12.8
itertools-0.5.10
itoa-0.4.3
jni-0.10.2
jni-sys-0.3.0
keccak-hash-0.1.2
kernel32-sys-0.2.2
kvdb-0.1.0
kvdb-memorydb-0.1.0
kvdb-rocksdb-0.1.4
language-tags-0.2.2
lazy_static-0.2.11
lazy_static-1.1.0
lazycell-1.1.0
libc-0.2.43
libloading-0.5.0
linked-hash-map-0.4.2
linked-hash-map-0.5.1
local-encoding-0.2.0
lock_api-0.1.3
log-0.3.9
log-0.4.5
lru-cache-0.1.1
matches-0.1.8
memchr-2.0.2
memmap-0.6.2
memoffset-0.2.1
memory_units-0.3.0
memorydb-0.3.0
mime-0.3.9
mime_guess-2.0.0-alpha.6
mio-0.6.16
mio-uds-0.6.7
miow-0.2.1
miow-0.3.3
multibase-0.6.0
multihash-0.7.0
nan-preserving-float-0.1.0
net2-0.2.33
nodrop-0.1.12
num-0.1.42
num-bigint-0.1.44
num-integer-0.1.39
num-iter-0.1.37
num-traits-0.1.43
num-traits-0.2.5
num_cpus-1.8.0
number_prefix-0.2.8
ole32-sys-0.2.0
order-stat-0.1.3
ordered-float-0.5.1
ordermap-0.3.5
owning_ref-0.3.3
parity-bytes-0.1.0
parity-crypto-0.1.0
parity-path-0.1.1
parity-rocksdb-0.5.0
parity-rocksdb-sys-0.5.3
parity-snappy-0.1.0
parity-snappy-sys-0.1.1
parity-wasm-0.31.3
parity-wordlist-1.2.0
parking_lot-0.6.4
parking_lot_core-0.3.1
patricia-trie-0.3.0
percent-encoding-1.0.1
petgraph-0.4.13
phf-0.7.23
phf_codegen-0.7.23
phf_generator-0.7.23
phf_shared-0.7.23
plain_hasher-0.2.0
pretty_assertions-0.1.2
primal-0.2.3
primal-bit-0.2.4
primal-check-0.2.3
primal-estimate-0.2.1
primal-sieve-0.2.9
proc-macro2-0.2.3
proc-macro2-0.3.8
proc-macro2-0.4.19
protobuf-1.7.4
pulldown-cmark-0.0.3
pwasm-utils-0.6.1
quick-error-1.2.2
quote-0.4.2
quote-0.5.2
quote-0.6.8
rand-0.3.22
rand-0.4.3
rand-0.5.5
rand_core-0.2.1
rayon-1.0.2
rayon-core-1.4.1
redox_syscall-0.1.40
redox_termios-0.1.1
regex-0.2.11
regex-1.0.5
regex-syntax-0.5.6
regex-syntax-0.6.2
relay-0.1.1
remove_dir_all-0.5.1
rlp-0.2.4
rlp-0.3.0
rpassword-1.0.2
rprompt-1.0.3
rust-crypto-0.2.36
rustc-demangle-0.1.9
rustc-hex-1.0.0
rustc-hex-2.0.1
rustc-serialize-0.3.24
rustc_version-0.2.3
rustls-0.11.0
ryu-0.2.6
safemem-0.2.0
same-file-1.0.3
scoped-tls-0.1.2
scopeguard-0.3.3
sct-0.2.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.78
serde_derive-1.0.78
serde_ignored-0.0.4
serde_json-1.0.27
sha1-0.2.0
shell32-sys-0.1.2
siphasher-0.1.3
siphasher-0.2.3
skeptic-0.4.0
slab-0.2.0
slab-0.3.0
slab-0.4.1
smallvec-0.4.5
smallvec-0.6.5
socket2-0.3.8
stable_deref_trait-1.1.1
strsim-0.6.0
strsim-0.7.0
syn-0.12.15
syn-0.13.11
syn-0.15.4
target_info-0.1.0
tempdir-0.3.7
tempfile-2.2.0
term_size-0.3.1
termcolor-1.0.3
termion-1.5.1
textwrap-0.10.0
textwrap-0.9.0
thread-id-3.3.0
thread_local-0.3.6
threadpool-1.7.1
time-0.1.40
timer-0.2.0
tiny-keccak-1.4.2
tokio-0.1.8
tokio-codec-0.1.0
tokio-core-0.1.17
tokio-current-thread-0.1.1
tokio-executor-0.1.4
tokio-fs-0.1.3
tokio-io-0.1.8
tokio-reactor-0.1.5
tokio-retry-0.1.1
tokio-rustls-0.4.0
tokio-service-0.1.0
tokio-tcp-0.1.1
tokio-threadpool-0.1.6
tokio-timer-0.1.2
tokio-timer-0.2.6
tokio-udp-0.1.2
tokio-uds-0.1.7
tokio-uds-0.2.1
toml-0.4.6
trace-time-0.1.1
transaction-pool-1.13.3
transient-hashmap-0.4.1
trie-standardmap-0.1.1
triehash-0.3.0
try-lock-0.1.0
ucd-util-0.1.1
uint-0.4.1
unicase-1.4.2
unicase-2.1.0
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-segmentation-1.2.1
unicode-width-0.1.5
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.1
utf8-ranges-1.0.1
vec_map-0.8.1
vergen-0.1.1
version_check-0.1.4
void-1.0.2
walkdir-2.2.5
want-0.0.4
wasmi-0.3.0
webpki-0.17.0
webpki-roots-0.13.0
winapi-0.2.8
winapi-0.3.5
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.1
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.1
ws2_32-sys-0.2.1
xdg-2.1.0
xml-rs-0.7.0
xmltree-0.7.0
"

inherit cargo systemd user

DESCRIPTION="Fast, light, and robust Ethereum client"
HOMEPAGE="https://parity.io"
ARCHIVE_URI="https://github.com/paritytech/${PN}-ethereum/archive/v${PV}.tar.gz -> ${P}.tar.gz"
# shellcheck disable=SC2086
SRC_URI="${ARCHIVE_URI} $(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon"

DOCS=( {CHANGELOG,README,SECURITY}.md )

S="${WORKDIR}/parity-ethereum-${PV}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

pkg_setup() {
	if use daemon; then
		enewgroup parity
		enewuser parity -1 -1 /var/lib/parity parity
	fi
}

# shellcheck disable=SC2046,SC2153
src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	cargo build $(usex debug '' --release) --features final || die
	cargo build $(usex debug '' --release) -p evmbin || die
	cargo build $(usex debug '' --release) -p ethstore-cli || die
	cargo build $(usex debug '' --release) -p ethkey-cli || die
}

src_install() {
	dobin target/release/{ethkey,ethstore,parity{,-evm}}
	einstalldocs

	if use daemon; then
		keepdir /var/log/parity
		fowners parity:parity /var/log/parity

		insinto /etc/parity
		doins "${FILESDIR}"/config.toml

		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_dounit "scripts/${PN}.service"
	fi
}

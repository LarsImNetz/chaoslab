# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
aho-corasick-0.6.8
ansi_term-0.10.2
ansi_term-0.11.0
arrayref-0.3.5
arrayvec-0.4.7
ascii-0.7.1
assert_matches-1.3.0
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
base-x-0.2.3
base64-0.9.3
bincode-0.8.0
bit-set-0.4.0
bit-vec-0.4.4
bitflags-0.7.0
bitflags-0.9.1
bitflags-1.0.4
block-buffer-0.3.3
byte-tools-0.2.0
byteorder-1.2.6
bytes-0.4.10
cc-1.0.25
cesu8-1.1.0
cfg-if-0.1.5
chrono-0.4.6
cid-0.3.0
clap-2.32.0
cloudabi-0.0.3
cmake-0.1.35
combine-3.6.1
crossbeam-0.4.1
crossbeam-channel-0.2.6
crossbeam-deque-0.2.0
crossbeam-deque-0.5.2
crossbeam-deque-0.6.1
crossbeam-epoch-0.3.1
crossbeam-epoch-0.5.2
crossbeam-epoch-0.6.1
crossbeam-utils-0.2.2
crossbeam-utils-0.5.0
crossbeam-utils-0.6.2
crunchy-0.1.6
crunchy-0.2.1
ct-logs-0.4.0
daemonize-0.3.0
difference-1.0.0
digest-0.7.6
docopt-0.8.3
edit-distance-2.0.1
either-1.5.0
elastic-array-0.10.0
env_logger-0.4.3
env_logger-0.5.13
error-chain-0.12.0
ethabi-6.1.0
ethabi-contract-6.0.0
ethabi-derive-6.0.2
ethbloom-0.5.0
ethereum-types-0.4.0
ethereum-types-serialize-0.2.1
failure-0.1.3
failure_derive-0.1.3
fake-simd-0.1.2
fdlimit-0.1.1
fixed-hash-0.2.2
fixedbitset-0.1.9
fnv-1.0.6
fs-swap-0.2.4
fs_extra-1.1.0
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.25
futures-cpupool-0.1.8
fxhash-0.2.1
gcc-0.3.55
generic-array-0.9.0
getopts-0.2.18
globset-0.4.2
h2-0.1.12
hamming-0.1.3
hashdb-0.3.0
heck-0.3.0
hex-0.2.0
home-0.3.3
http-0.1.13
httparse-1.3.3
humantime-1.1.1
hyper-0.11.27
hyper-0.12.11
hyper-rustls-0.14.0
idna-0.1.5
if_chain-0.1.3
igd-0.7.0
indexmap-1.0.2
integer-encoding-1.0.5
interleaved-ordered-0.1.1
iovec-0.1.2
ipnetwork-0.12.8
itertools-0.5.10
itertools-0.7.8
itoa-0.4.3
jemalloc-sys-0.1.8
jemallocator-0.1.9
jni-0.10.2
jni-sys-0.3.0
keccak-hash-0.1.2
kernel32-sys-0.2.2
kvdb-0.1.0
kvdb-memorydb-0.1.0
kvdb-rocksdb-0.1.4
language-tags-0.2.2
lazy_static-1.1.0
lazycell-1.2.0
libc-0.2.43
libloading-0.5.0
linked-hash-map-0.4.2
linked-hash-map-0.5.1
local-encoding-0.2.0
lock_api-0.1.4
log-0.3.9
log-0.4.5
lru-cache-0.1.1
lunarity-lexer-0.1.0
matches-0.1.8
memchr-2.1.0
memmap-0.6.2
memoffset-0.2.1
memory_units-0.3.0
memorydb-0.3.0
mime-0.3.12
mime_guess-2.0.0-alpha.6
mio-0.6.16
mio-named-pipes-0.1.6
mio-uds-0.6.7
miow-0.2.1
miow-0.3.3
multibase-0.6.0
multihash-0.8.0
nan-preserving-float-0.1.0
net2-0.2.33
nodrop-0.1.12
num-0.1.42
num-bigint-0.1.44
num-integer-0.1.39
num-iter-0.1.37
num-traits-0.1.43
num-traits-0.2.6
num_cpus-1.8.0
number_prefix-0.2.8
ole32-sys-0.2.0
order-stat-0.1.3
ordered-float-0.5.2
ordermap-0.3.5
owning_ref-0.3.3
parity-bytes-0.1.0
parity-crypto-0.2.0
parity-path-0.1.1
parity-rocksdb-0.5.0
parity-rocksdb-sys-0.5.3
parity-snappy-0.1.0
parity-snappy-sys-0.1.1
parity-tokio-ipc-0.1.0
parity-wasm-0.31.3
parity-wordlist-1.2.1
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
proc-macro2-0.4.20
protobuf-1.7.4
pulldown-cmark-0.0.3
pwasm-utils-0.6.1
quick-error-1.2.2
quote-0.6.8
rand-0.3.22
rand-0.4.3
rand-0.5.5
rand_core-0.2.2
rand_core-0.3.0
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
ring-0.13.2
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
rustls-0.13.1
ryu-0.2.6
safemem-0.3.0
same-file-1.0.3
scoped-tls-0.1.2
scopeguard-0.3.3
sct-0.4.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.80
serde_derive-1.0.80
serde_json-1.0.32
sha1-0.2.0
sha1-0.5.0
sha2-0.7.1
shell32-sys-0.1.2
siphasher-0.1.3
siphasher-0.2.3
skeptic-0.4.0
slab-0.2.0
slab-0.3.0
slab-0.4.1
smallvec-0.6.5
socket2-0.3.8
stable_deref_trait-1.1.1
string-0.1.1
strsim-0.6.0
strsim-0.7.0
syn-0.15.11
synstructure-0.10.1
target_info-0.1.0
tempdir-0.3.7
term_size-0.3.1
termcolor-1.0.4
termion-1.5.1
textwrap-0.10.0
textwrap-0.9.0
thread-id-3.3.0
thread_local-0.3.6
threadpool-1.7.1
time-0.1.40
timer-0.2.0
tiny-keccak-1.4.2
tokio-0.1.11
tokio-codec-0.1.1
tokio-core-0.1.17
tokio-current-thread-0.1.3
tokio-executor-0.1.5
tokio-fs-0.1.3
tokio-io-0.1.9
tokio-named-pipes-0.1.0
tokio-reactor-0.1.6
tokio-retry-0.1.1
tokio-rustls-0.7.2
tokio-service-0.1.0
tokio-tcp-0.1.2
tokio-threadpool-0.1.7
tokio-timer-0.1.2
tokio-timer-0.2.7
tokio-udp-0.1.2
tokio-uds-0.2.2
toml-0.4.8
toolshed-0.4.0
trace-time-0.1.1
transaction-pool-1.13.3
transient-hashmap-0.4.1
trie-standardmap-0.1.1
triehash-0.3.0
try-lock-0.1.0
try-lock-0.2.2
typenum-1.10.0
ucd-util-0.1.1
uint-0.4.1
unicase-1.4.2
unicase-2.2.0
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-segmentation-1.2.1
unicode-width-0.1.5
unicode-xid-0.1.0
unreachable-1.0.0
untrusted-0.6.2
url-1.7.1
utf8-ranges-1.0.1
validator-0.8.0
validator_derive-0.8.0
vec_map-0.8.1
vergen-0.1.1
version_check-0.1.5
void-1.0.2
walkdir-2.2.5
want-0.0.4
want-0.0.6
wasmi-0.3.0
webpki-0.18.1
webpki-roots-0.15.0
winapi-0.2.8
winapi-0.3.6
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

DEPEND=">=virtual/rust-1.30.1"

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

	cargo build -j $(makeopts_jobs) $(usex debug '' --release) --features final || die

	local x
	for x in evmbin ethstore-cli ethkey-cli; do
		cargo build -j $(makeopts_jobs) $(usex debug '' --release) -p ${x} || die
	done
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

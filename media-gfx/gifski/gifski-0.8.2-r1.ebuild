# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Partially generated with
# curl -s https://raw.githubusercontent.com/ImageOptim/gifski/0.8.2/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.4
ansi_term-0.10.2
arrayvec-0.4.7
atty-0.2.6
backtrace-0.3.5
backtrace-sys-0.1.16
bindgen-0.32.3
bitflags-0.9.1
bitflags-1.0.1
cc-1.0.4
cexpr-0.2.3
cfg-if-0.1.2
clang-sys-0.21.2
clap-2.30.0
color_quant-1.0.0
crossbeam-deque-0.2.0
crossbeam-epoch-0.3.0
crossbeam-utils-0.2.2
either-1.4.0
env_logger-0.4.3
error-chain-0.11.0
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
gif-0.9.2
gif-dispose-2.1.0
glob-0.2.11
imagequant-2.11.9
imagequant-sys-2.11.9
imgref-1.3.3
kernel32-sys-0.2.2
lazy_static-0.2.11
lazy_static-1.0.0
libc-0.2.37
libloading-0.4.3
lodepng-2.1.2
log-0.3.9
log-0.4.1
lzw-0.10.0
memchr-1.0.2
memchr-2.0.1
memoffset-0.2.1
nodrop-0.1.12
nom-3.2.1
num_cpus-1.8.0
openmp-sys-0.1.3
pbr-1.0.0
peeking_take_while-0.1.2
pkg-config-0.3.9
proc-macro2-0.2.3
quote-0.4.2
rand-0.4.2
rayon-0.9.0
rayon-core-1.4.0
redox_syscall-0.1.37
redox_termios-0.1.1
regex-0.2.6
regex-syntax-0.4.2
resize-0.3.0
rgb-0.8.7
rustc-demangle-0.1.7
scopeguard-0.3.3
strsim-0.7.0
termion-1.5.1
textwrap-0.9.0
thread_local-0.3.5
time-0.1.39
unicode-width-0.1.4
unicode-xid-0.1.0
unreachable-1.0.0
utf8-ranges-1.0.0
vec_map-0.8.0
void-1.0.2
which-1.0.5
wild-0.1.1
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="GIF encoder based on libimagequant"
HOMEPAGE="https://gif.ski"
# shellcheck disable=SC2086
SRC_URI="https://github.com/ImageOptim/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="video openmp"

RDEPEND="media-gfx/libimagequant[openmp?]
	video? ( <media-video/ffmpeg-4 )"
DEPEND="${RDEPEND}
	sys-devel/clang:5
	>=virtual/rust-1.23.0"

pkg_setup() {
	# shellcheck disable=SC2086
	# Unfortunately 'network-sandbox' needs to be
	# disabled because Cargo fetches a few dependencies.
	has network-sandbox $FEATURES && \
		die "media-gfx/gifski requires 'network-sandbox' to be disabled in FEATURES"
}

src_prepare() {
	sed -i ":openmp-static:openmp:" Cargo.toml || die
	default
}

src_compile() {
	# shellcheck disable=SC2153
	export CARGO_HOME="${ECARGO_HOME}"

	# shellcheck disable=SC2207
	# build up optional flags
	local options=(
		$(usex video 'video' '')
		$(usex openmp 'openmp' '')
	)

	LIBCLANG_PATH="/usr/lib/llvm/5/$(get_libdir)" \
		cargo build -v "$(usex debug '' --release)" \
		--features "${options[*]}" || die
}

src_install() {
	dobin target/release/gifski
}

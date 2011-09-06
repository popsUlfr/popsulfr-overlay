# Based on ffmpeg ebuild
# Copyright 2010 Enno Gröper
# Distributed under the terms of the GNU General Public License v2

EAPI=2
SCM=subversion
ESVN_REPO_URI="http://svn.quickcamteam.net/svn/qct/webcam-tools/trunk"

inherit cmake-utils ${SCM}

DESCRIPTION="libwebcam is designed to simplify the development of webcam
applications (uvc based)"
HOMEPAGE="http://www.quickcamteam.net/software/libwebcam"
PREFIX="/usr"
LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

src_prepare() {
	epatch ${FILESDIR}/no-packaging.patch
}

src_configure() {
	local mycmakeargs="
		-DUVCVIDEO_INCLUDE_PATH=/usr/src/linux/include"
	cmake-utils_src_configure
}

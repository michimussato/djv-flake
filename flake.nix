# # export NIXPKGS_ALLOW_INSECURE=1
# nix build --option sandbox false
# nix run github:michimussato/djv-flake --verbose --option sandbox false

{
  description = "DJV Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:

    let
      # https://discourse.nixos.org/t/allow-insecure-packages-in-flake-nix/34655/8
      pkgs = import nixpkgs {
        system = "x86_64-linux";
#        inherit system;
        config = {
          permittedInsecurePackages = [
            "openexr-2.5.10"
            "ilmbase-2.5.10"
          ];
        };
      };
      # pkgs = nixpkgs.legacyPackages.x86_64-linux;
      default-version = "3.7.5";
    in

    rec {
#      nixpkgs.config = {
#        allowUnfree = true;
#        permittedInsecurePackages = [
#          "openexr-2.5.10"
#        ];
#      };

      packages.x86_64-linux.default = packages.x86_64-linux."djv-${default-version}";

      packages.x86_64-linux."djv-3.7.5" = pkgs.stdenv.mkDerivation {
        # package name
        pname = "djv";
        # package version
        version = "3.7.5";

        # https://noogle.dev/f/builtins/fetchGit/
        src = builtins.fetchGit {
          url = "https://github.com/grizzlypeak3d/djv.git";
          rev = "4d90982b4085adf4d150f1bf0b0b4a5490b023d5";
          submodules = true;
          shallow = true;
        };

        # ISSUES
        ## Running phase: qtPreHook
        ## Error: wrapQtAppsHook is not used, and dontWrapQtApps is not set.
        ## - https://github.com/NixOS/nixpkgs/pull/255091
        ## -> dontWrapQtApps = true;

      #  # unpackPhase
      #  dontUnpack = true;
      #  # patchPhase
      #  dontPatch = true;
      #  # configurePhase
      #  dontWrapQtApps = true;
      #  buildPhase = ''
      #    pwd
      #    echo $src
      #    echo $out
      #    ls -al .
      #  '';
      #  # checkPhase
      #  installPhase = '''';
      #  # fixupPhase
      #  # installCheckPhase
      #  # distPhase

        # unpackPhase = true;
        # nix-build --option sandbox false
        buildCommand = ''
          echo "src = $src"
          echo "out = $out"
          env

          echo "tree src = "
          # tree $src

          # ls -al $src
          # echo "NIX_SSL_CERT_FILE: $NIX_SSL_CERT_FILE"
          # ls -al $src/etc/Linux
          # ls -al $src
          sh $src/etc/Linux/sbuild.sh $src Release
          # touch ./etc/Config/local.cmake
          # echo "set(TLRENDER_FFMPEG_MINIMAL OFF CACHE BOOL \"\")" >> ./etc/Config/local.cmake
          # cat ./etc/Config/local.cmake
          # mkdir -p $out
          # cp -r $src/ $out
          # ls -al $out
          # # chmod +x $src/sbuild-linux.sh
          # pushd $out
          # #export CMAKE_INSTALL_PREFIX=$out
          # #export CMAKE_PREFIX_PATH=$out
          # sh $src/sbuild-linux.sh . Release default

          mkdir -p $out
          # Can we set
          # export CMAKE_INSTALL_PREFIX=$out
          # export CMAKE_PREFIX_PATH=$out
          # ?
          # These hava all the same values:
          # PWD=/nix/var/nix/builds/nix-3014615-662604354
          # TMP=/nix/var/nix/builds/nix-3014615-662604354
          # TEMPDIR=/nix/var/nix/builds/nix-3014615-662604354
          # TMPDIR=/nix/var/nix/builds/nix-3014615-662604354
          # TEMP=/nix/var/nix/builds/nix-3014615-662604354
          # NIX_BUILD_TOP=/nix/var/nix/builds/nix-3014615-662604354
          # cmake -S /nix/store/j2bryr4053p207cj6cnn7vaiia2dcxjy-source/deps/tlRender/deps/ftk/etc/SuperBuild -B ftk-Release -C /nix/store/j2bryr4053p207cj6cnn7vaiia2dcxjy-source/etc/Config/default.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/nix/var/nix/builds/nix-3014615-662604354/install-Release -DCMAKE_PREFIX_PATH=/nix/var/nix/builds/nix-3014615-662604354/install-Release
          cp -a $NIX_BUILD_TOP/install-Release/. $out
        '';

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          # [...]
          # fatal: unable to access 'https://github.com/madler/zlib.git/': SSL certificate OpenSSL verify result: unable to get local issuer certificate (20)
          # [...]
          # https://github.com/NixOS/nixpkgs/issues/409848
          # echo "NIX_SSL_CERT_FILE: $NIX_SSL_CERT_FILE"
          cacert
          # Disable sandbox so that extra repos can be cloned (requires git)
          git

          perl
        ];

        buildInputs = with pkgs; [

          cmake
          pkg-config
          # [...]
          # fatal: unable to access 'https://github.com/madler/zlib.git/': SSL certificate OpenSSL verify result: unable to get local issuer certificate (20)
          # [...]
          # https://github.com/NixOS/nixpkgs/issues/409848
          # echo "NIX_SSL_CERT_FILE: $NIX_SSL_CERT_FILE"
          cacert
          # Disable sandbox so that extra repos can be cloned (requires git)
          git

          perl

          # CMake Error at cmake/macros.cmake:415 (message):
          #   SDL could not find X11 or Wayland development libraries on your system.
          #   This means SDL will not be able to create windows on a typical unix
          #   operating system.  Most likely, this is not wanted.
          #
          #   On Linux, install the packages listed at
          #   https://wiki.libsdl.org/SDL3/README-linux#build-dependencies
          #
          #   If you really don't need desktop windows, the documentation tells you how
          #   to skip this check.
          #   https://github.com/libsdl-org/SDL/blob/main/docs/README-cmake.md#cmake-fails-to-build-without-x11-or-wayland-support
          #
          # Call Stack (most recent call first):
          #   CMakeLists.txt:4376 (SDL_PrintSummary)
          pkg-config
          libX11
          wayland-protocols
          xwayland
          libpng

          xorg-server
          libGLU
          mesa
          mesa_glu
          alsa-lib
          libpulseaudio
          libva
          libdrm
          libxkbcommon
          egl-x11
          egl-wayland
          egl-wayland2
          libdecor
          libxcursor
          xinput


          bash
          ncurses5
          xmessage

          libGLU
          libGL
          alsa-lib
          fontconfig
          zlib
          libpng
          dbus
          nss
          nspr
          expat
          pciutils
          libxkbcommon
          libudev0-shim
          tbb
          xwayland
          qt5.qtwayland
          nettools  # needed by licensing tools
          bintools  # needed for ld and other tools, so ctypes can find/load sos from python
          ocl-icd  # needed for opencl
          numactl  # needed by hfs ocl backend
          zstd  # needed from 20.0

          libice
          libsm
          libxmu
          libxi
          libxext
          libx11
          libxrender
          libxcursor
          libxfixes
          libxcomposite
          libxdamage
          libxtst
          libxcb
          libxscrnsaver
          libxrandr
          libxcb-util
          libxcb-image
          libxcb-render-util
          libxcb-cursor
          libxcb-keysyms
          libxcb-wm

          libdrm
          libxshmfence
          libxkbfile
          pipewire

          libxinerama
          libxrandr

          tree
          bzip2
          feather-tk
          ffmpeg_7
          freetype
          glfw
          imath
          tlrender
          libjpeg
          libGL
          libpng
          libtiff
          lunasvg
          minizip-ng
          nativefiledialog-extended
          nlohmann_json
          opencolorio
          openexr_2
          openssl
          opentimelineio
          plutovg
          SDL2
          xz
          zlib
          zstd
        ];

        # GLFW requires a working X11 session.
        doCheck = false;

        meta = {
          description = "Professional review software for VFX, animation, and film production. Defaults to version ${default-version}.";
          homepage = "https://github.com/grizzlypeak3d/DJV";
          platforms = with pkgs.lib.platforms; linux;  # ++ darwin;
          maintainers = "michimussato@etik.com";
          license = pkgs.lib.licenses.bsd3;
          mainProgram = "djv";
        };
      };
  };
}
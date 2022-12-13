FROM ocaml/opam:ubuntu-20.04-ocaml-4.14

SHELL ["/bin/bash", "-c"]

WORKDIR /home/opam

RUN echo "export PATH=$HOME/.local/bin:\$PATH" >> ~/.bashrc

RUN sudo apt-get update \
 && export OWL_CFLAGS="-g -O3 -Ofast -funroll-loops -ffast-math -DSFMT_MEXP=19937 -fno-strict-aliasing -Wno-tautological-constant-out-of-range-compare" \
 && export OWL_AEOS_CFLAGS="-g -O3 -Ofast -funroll-loops -ffast-math -DSFMT_MEXP=19937 -fno-strict-aliasing" \
 && export EIGENCPP_OPTFLAGS="-Ofast -funroll-loops -ffast-math" \
 && export EIGEN_FLAGS="-O3 -Ofast -funroll-loops -ffast-math" \
 && if [[ "$TARGETPLATFORM" == "linux/amd64" ]]; then \
        export OWL_CFLAGS="$OWL_CFLAGS -mfpmath=sse -msse2"; \
    fi \
 && sudo apt-get install -y time libsundials-dev entr libopenblas-dev liblapacke-dev pkg-config zlib1g-dev python3 \
 && opam install -y dune linenoise sundialsml owl lwt \
 && eval $(opam env) \
 && sudo mkdir -p /src \
 && sudo chown $(whoami):$(whoami) /src \
 && cd /src \
 && git clone https://github.com/miking-lang/miking.git \
 && cd /src/miking \
 && git checkout 6628246936d9323b05175c2ab92f5026c232021c \
 && make install test test-sundials clean

ENV PATH="$HOME/.local/bin:$PATH"

CMD ["mi"]

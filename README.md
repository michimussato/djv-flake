<!-- TOC -->
* [Flake DJV](#flake-djv)
  * [Update locally cached Flake](#update-locally-cached-flake)
<!-- TOC -->

---

# Flake DJV

References:
- [grizzlypeak3d/DJV](https://github.com/grizzlypeak3d/DJV)
- [Docs](https://grizzlypeak3d.github.io/DJV/index.html)
- [Grizzly Peak 3D](https://grizzlypeak3d.com/)

```shell
nix run github:michimussato/djv-flake/main --verbose --option sandbox false
```

## Update locally cached Flake

```shell
nix flake update --flake github:michimussato/djv-flake
```

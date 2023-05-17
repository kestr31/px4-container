# Experimental Gazebo Garden-Based SITL Container

> STILL IN EARLY DEVELOPMENT STAGE

## Deplopying a SITL Development Environment

- **Generic Linux:**

```shell
docker-compose --env-file run.env up
```

- **WSL2(Windows 11):**

> In order to properly use WSLg on WSL2, OS must be Windows 11.

```shell
docker-compose -f docker-compose.wslg.yml --env-file run.env up
```

## WSLg D3D12 Acceleration Problem

- OGRE2 has a problem in GPU acceleration using WSLg.
  - This is because D3D12 of WSLg does not supports OpenGL 4.3
- There are two solutions:
  - To set `LIBGL_ALWAYS_SOFTWARE=1` on environment variable
  - To use Gazebo with OGRE1 (Run with `--render-engine ogre`)

> For easy transition, use `scipts/setRenderEngineOgre.sh`

# Troubleshooting References

- https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md
- https://github.com/gazebosim/gz-sim/issues/920
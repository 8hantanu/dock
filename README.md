# dock
**Instant developer environment setup**

## build

```
docker build -t dock_img .
```

## run

```
docker run -it --name dock -v $PROJ_PATH:/home/user/proj dock_img
```

## attach

```
docker attach dock
```

**Note**: Use sudo when needed.

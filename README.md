# dock ⚓

**Instant developer environment setup**

## build 🏗️

```
sudo docker build -t dock_img .
```

## run 🚀

```
sudo docker run -it --name dock -v $PROJ_PATH:/home/user/proj dock_img
```

## attach 🔗

```
sudo docker attach dock
```

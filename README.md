# dock ⚓

**Instant developer environment setup**

## build 🏗️

```bash
sudo docker build -t dock_img .
```

**Note:** Get latest ubuntu image if doesn't exist
```bash
docker pull ubuntu:latest
```


## run 🚀

```bash
sudo docker run -it --name dock -v $PROJ_PATH:/home/user/proj dock_img
```

## attach 🔗

```bash
sudo docker attach dock
```

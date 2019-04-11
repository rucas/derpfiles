# osx

## Install

```sh
$ ./start.sh
```

## Finding a defaults setting

(info)[https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/]

```sh
$ defaults read > before
$ defaults read > after
$ diff before after

```
